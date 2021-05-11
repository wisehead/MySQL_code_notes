
# MySQL · 源码分析 · 常用SQL语句的MDL加锁源码分析

## 前言

MySQL5.5版本开始引入了MDL锁用来保护元数据信息，让MySQL能够在并发环境下多DDL、DML同时操作下保持元数据的一致性。本文用MySQL5.7源码分析了常用SQL语句的MDL加锁实现。

#### MDL锁粒度

MDL\_key由namespace、db\_name、name组成。

namespace包含：

*   GLOBAL。用于global read lock，例如FLUSH TABLES WITH READ LOCK。
    
*   TABLESPACE/SCHEMA。用于保护tablespace/schema。
    
*   FUNCTION/PROCEDURE/TRIGGER/EVENT。用于保护function/procedure/trigger/event。
    
*   COMMIT。主要用于global read lock后，阻塞事务提交。
    
*   USER\_LEVEL\_LOCK。用于[user level lock函数](https://dev.mysql.com/doc/internals/en/user-level-locks.html)的实现，GET\_LOCK(str,timeout)， RELEASE\_LOCK(str)。
    
*   LOCKING\_SERVICE。用于[locking service](https://dev.mysql.com/doc/refman/5.7/en/locking-service.html)的实现。
    

### MDL锁类型

*   MDL\_INTENTION\_EXCLUSIVE(IX) 意向排他锁，锁定一个范围，用在GLOBAL/SCHEMA/COMMIT粒度。
    
*   MDL\_SHARED(S) 用在只访问元数据信息，不访问数据。例如CREATE TABLE t LIKE t1;
    
*   MDL\_SHARED\_HIGH\_PRIO(SH) 也是用于只访问元数据信息，但是优先级比排他锁高，用于访问information\_schema的表。例如：select \* from information\_schema.tables;
    
*   MDL\_SHARED\_READ(SR) 访问表结构并且读表数据，例如：SELECT \* FROM t1; LOCK TABLE t1 READ LOCAL;
    
*   MDL\_SHARED\_WRITE(SW) 访问表结构且写表数据， 例如：INSERT/DELETE/UPDATE t1 … ;SELECT \* FROM t1 FOR UPDATE;LOCK TALE t1 WRITE
    
*   MDL\_SHARED\_WRITE\_LOW\_PRIO(SWLP) 优先级低于MDL\_SHARED\_READ\_ONLY。语句INSER/DELETE/UPDATE LOW\_PRIORITY t1 …; LOCK TABLE t1 WRITE LOW\_PRIORITY。
    
*   MDL\_SHARED\_UPGRADABLE(SU) 可升级锁，允许并发update/read表数据。持有该锁可以同时读取表metadata和表数据，但不能修改数据。可以升级到SNW、SNR、X锁。用在alter table的第一阶段，使alter table的时候不阻塞DML，防止其他DDL。
    
*   MDL\_SHARED\_READ\_ONLY(SRO) 持有该锁可读取表数据，同时阻塞所有表结构和表数据的修改操作，用于LOCK TABLE t1 READ。
    
*   MDL\_SHARED\_NO\_WRITE(SNW) 持有该锁可以读取表metadata和表数据，同时阻塞所有的表数据修改操作，允许读。可以升级到X锁。用在ALTER TABLE第一阶段，拷贝原始表数据到新表，允许读但不允许更新。
    
*   MDL\_SHARED\_NO\_READ\_WRITE(SNRW) 可升级锁，允许其他连接读取表结构但不可以读取数据，阻塞所有表数据的读写操作，允许INFORMATION\_SCHEMA访问和SHOW语句。持有该锁的的连接可以读取表结构，修改和读取表数据。可升级为X锁。使用在LOCK TABLE WRITE语句。
    
*   MDL\_EXCLUSIVE(X) 排他锁，持有该锁连接可以修改表结构和表数据，使用在CREATE/DROP/RENAME/ALTER TABLE 语句。
    

### MDL锁持有时间

*   MDL\_STATEMENT 语句中持有，语句结束自动释放
    
*   MDL\_TRANSACTION 事务中持有，事务结束时释放
    
*   MDL\_EXPLICIT 需要显示释放
    

### MDL锁兼容性

Scope锁活跃锁和请求锁兼容性矩阵如下。

```sql
         | Type of active   |
Request  |   scoped lock    |
type     | IS(*)  IX   S  X |
---------+------------------+
IS       |  +      +   +  + |
IX       |  +      +   -  - |
S        |  +      -   +  - |
X        |  +      -   -  - |

+号表示请求的锁可以满足。
-号表示请求的锁无法满足需要等待。
```

Scope锁等待锁和请求锁优先级矩阵

```sql
         |    Pending      |
Request  |  scoped lock    |
type     | IS(*)  IX  S  X |
---------+-----------------+
IS       |  +      +  +  + |
IX       |  +      +  -  - |
S        |  +      +  +  - |
X        |  +      +  +  + |
+号表示请求的锁可以满足。
-号表示请求的锁无法满足需要等待。
```

object上已持有锁和请求锁的兼容性矩阵如下。

```plain
Request   |  Granted requests for lock                  |
 type     | S  SH  SR  SW  SWLP  SU  SRO  SNW  SNRW  X  |
----------+---------------------------------------------+
S         | +   +   +   +    +    +   +    +    +    -  |
SH        | +   +   +   +    +    +   +    +    +    -  |
SR        | +   +   +   +    +    +   +    +    -    -  |
SW        | +   +   +   +    +    +   -    -    -    -  |
SWLP      | +   +   +   +    +    +   -    -    -    -  |
SU        | +   +   +   +    +    -   +    -    -    -  |
SRO       | +   +   +   -    -    +   +    +    -    -  |
SNW       | +   +   +   -    -    -   +    -    -    -  |
SNRW      | +   +   -   -    -    -   -    -    -    -  |
X         | -   -   -   -    -    -   -    -    -    -  |
```

object上等待锁和请求锁的优先级矩阵如下。

```plain
Request   |         Pending requests for lock          |
 type     | S  SH  SR  SW  SWLP  SU  SRO  SNW  SNRW  X |
----------+--------------------------------------------+
S         | +   +   +   +    +    +   +    +     +   - |
SH        | +   +   +   +    +    +   +    +     +   + |
SR        | +   +   +   +    +    +   +    +     -   - |
SW        | +   +   +   +    +    +   +    -     -   - |
SWLP      | +   +   +   +    +    +   -    -     -   - |
SU        | +   +   +   +    +    +   +    +     +   - |
SRO       | +   +   +   -    +    +   +    +     -   - |
SNW       | +   +   +   +    +    +   +    +     +   - |
SNRW      | +   +   +   +    +    +   +    +     +   - |
X         | +   +   +   +    +    +   +    +     +   + |
```

### 常用语句MDL锁加锁分析

使用performance\_schema可以辅助分析加锁。利用下面语句打开MDL锁分析，可以看到在只有当前session访问的时候，SELECT语句对metadata\_locks表加了TRANSACTION周期的SHARED\_READ锁，即锁粒度、时间范围和锁类型分别为：TABLE, TRANSACTION, SHARED\_READ，在代码位置sql\_parse.cc:5996初始化锁。。后面的锁分析也按照锁粒度-时间范围-锁类型介绍。

```sql
UPDATE performance_schema.setup_consumers SET ENABLED = 'YES' WHERE NAME ='global_instrumentation';
UPDATE performance_schema.setup_instruments SET ENABLED = 'YES' WHERE NAME ='wait/lock/metadata/sql/mdl';
select * from performance_schema.metadata_locks\G*************************** 1. row ***************************          OBJECT_TYPE: TABLE        OBJECT_SCHEMA: performance_schema          OBJECT_NAME: metadata_locksOBJECT_INSTANCE_BEGIN: 46995934864720            LOCK_TYPE: SHARED_READ        LOCK_DURATION: TRANSACTION          LOCK_STATUS: GRANTED               SOURCE: sql_parse.cc:5996      OWNER_THREAD_ID: 26       OWNER_EVENT_ID: 163
```

使用performance\_schema很难完整分析语句执行中所有的加锁过程，可以借助gdb分析，在 MDL\_context::acquire\_lock设置断点。

下面会结合performance\_schema和gdb分析常用语句的MDL加锁源码实现。

#### FLUSH TABLES WITH READ LOCK

语句执行会加锁GLOBAL-EXPLICIT-SHARED和COMMIT-EXPLICIT-SHARED。

```markdown
select * from performance_schema.metadata_locks\G
*************************** 1. row ***************************
          OBJECT_TYPE: GLOBAL
        OBJECT_SCHEMA: NULL
          OBJECT_NAME: NULL
OBJECT_INSTANCE_BEGIN: 46996001973424
            LOCK_TYPE: SHARED
        LOCK_DURATION: EXPLICIT
          LOCK_STATUS: GRANTED
               SOURCE: lock.cc:1110
      OWNER_THREAD_ID: 27
       OWNER_EVENT_ID: 92
*************************** 2. row ***************************
          OBJECT_TYPE: COMMIT
        OBJECT_SCHEMA: NULL
          OBJECT_NAME: NULL
OBJECT_INSTANCE_BEGIN: 46996001973616
            LOCK_TYPE: SHARED
        LOCK_DURATION: EXPLICIT
          LOCK_STATUS: GRANTED
               SOURCE: lock.cc:1194
      OWNER_THREAD_ID: 27
       OWNER_EVENT_ID: 375
```

相关源码实现剖析。当FLUSH语句是FLUSH TABLES WITH READ LOCK的时候，lex->type会添加REFRESH\_TABLES和REFRESH\_READ\_LOCK标记，当没有指定表即进入reload\_acl\_and\_cache函数，通过调用lock\_global\_read\_lock和make\_global\_read\_lock\_block\_commit加对应锁，通过对应的锁来阻止元数据修改和表数据更改。DDL语句执行时会请求GLOBAL的INTENTION\_EXCLUSIVE锁，事务提交和外部XA需要记录binlog的语句执行会请求COMMIT的INTENTION\_EXCLUSIVE锁。

```php
sql/sql_yacc.yy
flush_options:
          table_or_tables
          {
            Lex->type|= REFRESH_TABLES;
            /*
              Set type of metadata and table locks for
              FLUSH TABLES table_list [WITH READ LOCK].
            */
            YYPS->m_lock_type= TL_READ_NO_INSERT;
            YYPS->m_mdl_type= MDL_SHARED_HIGH_PRIO;
          }
          opt_table_list {}
          opt_flush_lock {}
        | flush_options_list
        ;


opt_flush_lock:
          /* empty */ {}
        | WITH READ_SYM LOCK_SYM
          {
            TABLE_LIST *tables= Lex->query_tables;
            Lex->type|= REFRESH_READ_LOCK;

sql/sql_parse.cc
  ...
  case SQLCOM_FLUSH:
    if (first_table && lex->type & REFRESH_READ_LOCK)//当指定表的时候，对指定表加锁。
    {
      if (flush_tables_with_read_lock(thd, all_tables))
    }
    ...
    if (!reload_acl_and_cache(thd, lex->type, first_table, &write_to_binlog))

sql/sql_reload.cc
reload_acl_and_cache
{
  if (options & (REFRESH_TABLES | REFRESH_READ_LOCK))
  {
    if ((options & REFRESH_READ_LOCK) && thd)
    {
      ...
      if (thd->global_read_lock.lock_global_read_lock(thd))//当未指定表的时候，加全局锁
        return 1;
      ...
      if (thd->global_read_lock.make_global_read_lock_block_commit(thd))//当未指定表的时候，加COMMIT锁
}

//对GLOBAL加EXPLICIT的S锁。
sql/lock.cc
bool Global_read_lock::lock_global_read_lock(THD *thd)
{
  ...
  MDL_REQUEST_INIT(&mdl_request,
                 MDL_key::GLOBAL, "", "", MDL_SHARED, MDL_EXPLICIT);
  ...
}
//对COMMIT加EXPLICIT的S锁。
bool Global_read_lock::make_global_read_lock_block_commit(THD *thd)
{
  ...
  MDL_REQUEST_INIT(&mdl_request,
                 MDL_key::COMMIT, "", "", MDL_SHARED, MDL_EXPLICIT);
  ...
}

sql/handler.cc
事务提交和外部XA事务的commit\rollback\prepare均需要加COMMIT的IX锁.
int ha_commit_trans(THD *thd, bool all, bool ignore_global_read_lock)
{
  ...
  if (rw_trans && !ignore_global_read_lock) //对于内部表slave status table的更新可以忽略global read lock
  {
    MDL_REQUEST_INIT(&mdl_request,
                 MDL_key::COMMIT, "", "", MDL_INTENTION_EXCLUSIVE,
                 MDL_EXPLICIT);

    DBUG_PRINT("debug", ("Acquire MDL commit lock"));
    if (thd->mdl_context.acquire_lock(&mdl_request,
                                  thd->variables.lock_wait_timeout))
  }
  ...
}
sql/xa.cc
bool Sql_cmd_xa_commit::trans_xa_commit(THD *thd)
{
  ...
  MDL_request mdl_request;
  MDL_REQUEST_INIT(&mdl_request,
                   MDL_key::COMMIT, "", "", MDL_INTENTION_EXCLUSIVE,
                   MDL_STATEMENT);
  if (thd->mdl_context.acquire_lock(&mdl_request,
                                    thd->variables.lock_wait_timeout))
  ...
}
bool Sql_cmd_xa_rollback::trans_xa_rollback(THD *thd)
{
  ...
  MDL_request mdl_request;
  MDL_REQUEST_INIT(&mdl_request,
                   MDL_key::COMMIT, "", "", MDL_INTENTION_EXCLUSIVE,
                   MDL_STATEMENT);
}
bool Sql_cmd_xa_prepare::trans_xa_prepare(THD *thd)
{
  ...
  MDL_request mdl_request;
  MDL_REQUEST_INIT(&mdl_request,
                   MDL_key::COMMIT, "", "", MDL_INTENTION_EXCLUSIVE,
                   MDL_STATEMENT);
}

//写入语句的执行和DDL执行需要GLOBAL的IX锁，这与S锁不兼容。
sql/sql_base.cc
bool open_table(THD *thd, TABLE_LIST *table_list, Open_table_context *ot_ctx)
{
  if (table_list->mdl_request.is_write_lock_request() &&
  {
    MDL_request protection_request;
    MDL_deadlock_handler mdl_deadlock_handler(ot_ctx);

    if (thd->global_read_lock.can_acquire_protection())
      DBUG_RETURN(TRUE);

    MDL_REQUEST_INIT(&protection_request,
                     MDL_key::GLOBAL, "", "", MDL_INTENTION_EXCLUSIVE,
                     MDL_STATEMENT);
  }
}
bool
lock_table_names(THD *thd,
                 TABLE_LIST *tables_start, TABLE_LIST *tables_end,
                 ulong lock_wait_timeout, uint flags)
{
  if (need_global_read_lock_protection)
  {
    /*
      Protect this statement against concurrent global read lock
      by acquiring global intention exclusive lock with statement
      duration.
    */
    if (thd->global_read_lock.can_acquire_protection())
      return true;
    MDL_REQUEST_INIT(&global_request,
                     MDL_key::GLOBAL, "", "", MDL_INTENTION_EXCLUSIVE,
                     MDL_STATEMENT);
    mdl_requests.push_front(&global_request);
  }
}
```

#### LOCK TABLE t READ \[LOCAL\]

LOCK TABLE t READ LOCAL会加锁TABLE-TRANSACTION-SHARED\_READ。

```markdown
select * from performance_schema.metadata_locks\G
*************************** 1. row ***************************
          OBJECT_TYPE: TABLE
        OBJECT_SCHEMA: test
          OBJECT_NAME: t
            LOCK_TYPE: SHARED_READ
        LOCK_DURATION: TRANSACTION
          LOCK_STATUS: GRANTED
               SOURCE: sql_parse.cc:5996
```

LOCK TABLE t READ会加锁TABLE-TRANSACTION-SHARED\_READ\_ONLY。

```markdown
select * from performance_schema.metadata_locks\G
*************************** 1. row ***************************
          OBJECT_TYPE: TABLE
        OBJECT_SCHEMA: test
          OBJECT_NAME: t
            LOCK_TYPE: SHARED_READ_ONLY
        LOCK_DURATION: TRANSACTION
          LOCK_STATUS: GRANTED
               SOURCE: sql_parse.cc:5996
```

这两个的区别是对于MyISAM引擎，LOCAL方式的加锁与insert写入不冲突，而没有LOCAL的时候SHARED\_READ\_ONLY会阻塞写入。不过对于InnoDB引擎两种方式是一样的，带有LOCAL的语句执行后面会升级为SHARED\_READ\_ONLY。

源码分析

```plain
table_lock:
          table_ident opt_table_alias lock_option
          {
            thr_lock_type lock_type= (thr_lock_type) $3;
            enum_mdl_type mdl_lock_type;

            if (lock_type >= TL_WRITE_ALLOW_WRITE)
            {
              /* LOCK TABLE ... WRITE/LOW_PRIORITY WRITE */
              mdl_lock_type= MDL_SHARED_NO_READ_WRITE;
            }
            else if (lock_type == TL_READ)
            {
              /* LOCK TABLE ... READ LOCAL */
              mdl_lock_type= MDL_SHARED_READ;
            }
            else
            {
              /* LOCK TABLE ... READ */
              mdl_lock_type= MDL_SHARED_READ_ONLY;
            }

            if (!Select->add_table_to_list(YYTHD, $1, $2, 0, lock_type,
                                           mdl_lock_type))
              MYSQL_YYABORT;
          }

lock_option:
          READ_SYM               { $$= TL_READ_NO_INSERT; }
        | WRITE_SYM              { $$= TL_WRITE_DEFAULT; }
        | LOW_PRIORITY WRITE_SYM
          {
            $$= TL_WRITE_LOW_PRIORITY;
            push_deprecated_warn(YYTHD, "LOW_PRIORITY WRITE", "WRITE");
          }
        | READ_SYM LOCAL_SYM     { $$= TL_READ; }
        ;

sql/sql_parse.cc
TABLE_LIST *st_select_lex::add_table_to_list(THD *thd,
               Table_ident *table,
               LEX_STRING *alias,
               ulong table_options,
               thr_lock_type lock_type,
               enum_mdl_type mdl_type,
               List<Index_hint> *index_hints_arg,
                                             List<String> *partition_names,
                                             LEX_STRING *option)
{
  // Pure table aliases do not need to be locked:
  if (!MY_TEST(table_options & TL_OPTION_ALIAS))
  {
    MDL_REQUEST_INIT(& ptr->mdl_request,
                     MDL_key::TABLE, ptr->db, ptr->table_name, mdl_type,
                     MDL_TRANSACTION);
  }                                             
}

//对于Innodb引擎
static bool lock_tables_open_and_lock_tables(THD *thd, TABLE_LIST *tables)
{
  ...
  else if (table->lock_type == TL_READ &&
           ! table->prelocking_placeholder &&
           table->table->file->ha_table_flags() & HA_NO_READ_LOCAL_LOCK)
  {
    /*
      In case when LOCK TABLE ... READ LOCAL was issued for table with
      storage engine which doesn't support READ LOCAL option and doesn't
      use THR_LOCK locks we need to upgrade weak SR metadata lock acquired
      in open_tables() to stronger SRO metadata lock.
      This is not needed for tables used through stored routines or
      triggers as we always acquire SRO (or even stronger SNRW) metadata
      lock for them.
    */
    bool result= thd->mdl_context.upgrade_shared_lock(
                                    table->table->mdl_ticket,
                                    MDL_SHARED_READ_ONLY,
                                    thd->variables.lock_wait_timeout);
  ...
}
```

#### LOCK TABLE t WITH WRITE

LOCK TABLE t WITH WRITE会加锁：GLOBAL-STATEMENT-INTENTION\_EXCLUSIVE，SCHEMA-TRANSACTION-INTENTION\_EXCLUSIVE，TABLE-TRANSACTION-SHARED\_NO\_READ\_WRITE。

```markdown
select OBJECT_TYPE,OBJECT_SCHEMA,OBJECT_NAME,LOCK_TYPE,LOCK_DURATION,SOURCE from performance_schema.metadata_locks\G
*************************** 1. row ***************************
          OBJECT_TYPE: GLOBAL
        OBJECT_SCHEMA: NULL
          OBJECT_NAME: NULL
            LOCK_TYPE: INTENTION_EXCLUSIVE
        LOCK_DURATION: STATEMENT
               SOURCE: sql_base.cc:5497
*************************** 2. row ***************************
          OBJECT_TYPE: SCHEMA
        OBJECT_SCHEMA: test
          OBJECT_NAME: NULL
            LOCK_TYPE: INTENTION_EXCLUSIVE
        LOCK_DURATION: TRANSACTION
               SOURCE: sql_base.cc:5482
*************************** 3. row ***************************
          OBJECT_TYPE: TABLE
        OBJECT_SCHEMA: test
          OBJECT_NAME: ti
            LOCK_TYPE: SHARED_NO_READ_WRITE
        LOCK_DURATION: TRANSACTION
               SOURCE: sql_parse.cc:5996
```

相关源码

```php
bool
lock_table_names(THD *thd,
                 TABLE_LIST *tables_start, TABLE_LIST *tables_end,
                 ulong lock_wait_timeout, uint flags)
{
  ...
  while ((table= it++))
  {
    MDL_request *schema_request= new (thd->mem_root) MDL_request;
    if (schema_request == NULL)
      return true;
    MDL_REQUEST_INIT(schema_request,
                     MDL_key::SCHEMA, table->db, "",
                     MDL_INTENTION_EXCLUSIVE,
                     MDL_TRANSACTION);
    mdl_requests.push_front(schema_request);
  }
  if (need_global_read_lock_protection)
  {
    /*
      Protect this statement against concurrent global read lock
      by acquiring global intention exclusive lock with statement
      duration.
    */
    if (thd->global_read_lock.can_acquire_protection())
      return true;
    MDL_REQUEST_INIT(&global_request,
                     MDL_key::GLOBAL, "", "", MDL_INTENTION_EXCLUSIVE,
                     MDL_STATEMENT);
    mdl_requests.push_front(&global_request);
  }
  ...
  // Phase 3: Acquire the locks which have been requested so far.
  if (thd->mdl_context.acquire_locks(&mdl_requests, lock_wait_timeout))
    return true;
}

在open_table中也会请求锁。

SHARED_NO_READ_WRITE的加锁源码参考LOCK TABLE WITH READ的源码分析。
```

*   SELECT查询语句的执行

SELECT语句的执行加锁TABLE-TRANSACTION-SHARED\_READ锁。

```markdown
select * from performance_schema.metadata_locks\G
*************************** 1. row ***************************
          OBJECT_TYPE: TABLE
        OBJECT_SCHEMA: test
          OBJECT_NAME: t1
            LOCK_TYPE: SHARED_READ
        LOCK_DURATION: TRANSACTION
          LOCK_STATUS: GRANTED
               SOURCE: sql_parse.cc:5996
```

源码分析：

```plain
class Yacc_state
{
  void reset()
  {
    yacc_yyss= NULL;
    yacc_yyvs= NULL;
    yacc_yyls= NULL;
    m_lock_type= TL_READ_DEFAULT;
    m_mdl_type= MDL_SHARED_READ;
    m_ha_rkey_mode= HA_READ_KEY_EXACT;
  }
}

调用add_table_to_list初始化锁，调用open_table_get_mdl_lock获取锁。

static bool
open_table_get_mdl_lock(THD *thd, Open_table_context *ot_ctx,
                        TABLE_LIST *table_list, uint flags,
                        MDL_ticket **mdl_ticket)
{
  bool result= thd->mdl_context.acquire_lock(mdl_request,
                                           ot_ctx->get_timeout());
}
```

#### INSERT/UPDATE/DELETE语句

在open table阶段会获取GLOBAL-STATEMENT-INTENTION\_EXCLUSIVE，TABLE-TRANSACTION-SHARED\_WRITE。

在commit阶段获取COMMIT-MDL\_EXPLICIT-INTENTION\_EXCLUSIVE锁。

```markdown
select OBJECT_TYPE,OBJECT_SCHEMA,OBJECT_NAME,LOCK_TYPE,LOCK_DURATION,SOURCE from performance_schema.metadata_locks\G
OBJECT_TYPE: GLOBAL
OBJECT_SCHEMA: NULL
OBJECT_NAME: NULL
  LOCK_TYPE: INTENTION_EXCLUSIVE
LOCK_DURATION: STATEMENT
     SOURCE: sql_base.cc:3190
*************************** 2. row ***************************
OBJECT_TYPE: TABLE
OBJECT_SCHEMA: test
OBJECT_NAME: ti
  LOCK_TYPE: SHARED_WRITE
LOCK_DURATION: TRANSACTION
     SOURCE: sql_parse.cc:5996
*************************** 3. row ***************************
OBJECT_TYPE: COMMIT
OBJECT_SCHEMA: NULL
OBJECT_NAME: NULL
  LOCK_TYPE: INTENTION_EXCLUSIVE
LOCK_DURATION: EXPLICIT
     SOURCE: handler.cc:1758
```

```plain
sql/sql_yacc.yy
insert_stmt:
          INSERT                       /* #1 */
          insert_lock_option           /* #2 */

          insert_lock_option:
                    /* empty */   { $$= TL_WRITE_CONCURRENT_DEFAULT; }
                  | LOW_PRIORITY  { $$= TL_WRITE_LOW_PRIORITY; }
                  | DELAYED_SYM
                  {
                    $$= TL_WRITE_CONCURRENT_DEFAULT;

                    push_warning_printf(YYTHD, Sql_condition::SL_WARNING,
                                        ER_WARN_LEGACY_SYNTAX_CONVERTED,
                                        ER(ER_WARN_LEGACY_SYNTAX_CONVERTED),
                                        "INSERT DELAYED", "INSERT");
                  }
                  | HIGH_PRIORITY { $$= TL_WRITE; }
                  ;

//DELETE语句
delete_stmt:
          DELETE_SYM
          opt_delete_options


//UPDATE
update_stmt:
  UPDATE_SYM            /* #1 */
  opt_low_priority      /* #2 */
  opt_ignore            /* #3 */
  join_table_list       /* #4 */
  SET                   /* #5 */
  update_list           /* #6 */

opt_low_priority:
          /* empty */ { $$= TL_WRITE_DEFAULT; }
        | LOW_PRIORITY { $$= TL_WRITE_LOW_PRIORITY; }
        ;

opt_delete_options:
          /* empty */                          { $$= 0; }
        | opt_delete_option opt_delete_options { $$= $1 | $2; }
        ;

opt_delete_option:
          QUICK        { $$= DELETE_QUICK; }
        | LOW_PRIORITY { $$= DELETE_LOW_PRIORITY; }
        | IGNORE_SYM   { $$= DELETE_IGNORE; }
        ;

sql/parse_tree_nodes.cc
bool PT_delete::add_table(Parse_context *pc, Table_ident *table)
{
  ...
  const enum_mdl_type mdl_type=
  (opt_delete_options & DELETE_LOW_PRIORITY) ? MDL_SHARED_WRITE_LOW_PRIO
                                             : MDL_SHARED_WRITE;
  ...
}

bool PT_insert::contextualize(Parse_context *pc)
{
  if (!pc->select->add_table_to_list(pc->thd, table_ident, NULL,
                                   TL_OPTION_UPDATING,
                                   yyps->m_lock_type,
                                   yyps->m_mdl_type,
                                   NULL,
                                   opt_use_partition))
   pc->select->set_lock_for_tables(lock_option);


}

bool PT_update::contextualize(Parse_context *pc)
{
  pc->select->set_lock_for_tables(opt_low_priority);
}

void st_select_lex::set_lock_for_tables(thr_lock_type lock_type)
{
  bool for_update= lock_type >= TL_READ_NO_INSERT;
  enum_mdl_type mdl_type= mdl_type_for_dml(lock_type);
  ...
  tables->mdl_request.set_type(mdl_type);
  ...
}

inline enum enum_mdl_type mdl_type_for_dml(enum thr_lock_type lock_type)
{
  return lock_type >= TL_WRITE_ALLOW_WRITE ?
         (lock_type == TL_WRITE_LOW_PRIORITY ?
          MDL_SHARED_WRITE_LOW_PRIO : MDL_SHARED_WRITE) :
         MDL_SHARED_READ;
}

最终调用open\_table加锁

bool open_table(THD *thd, TABLE_LIST *table_list, Open_table_context *ot_ctx)
{
  if (table_list->mdl_request.is_write_lock_request() &&
     ...
  {
     MDL_REQUEST_INIT(&protection_request,
                  MDL_key::GLOBAL, "", "", MDL_INTENTION_EXCLUSIVE,
                  MDL_STATEMENT);
     bool result= thd->mdl_context.acquire_lock(&protection_request,
                                                ot_ctx->get_timeout());
  }
  ...
  if (open_table_get_mdl_lock(thd, ot_ctx, table_list, flags, &mdl_ticket) ||
  ...
}

在commit阶段调用ha_commit_trans函数时加COMMIT的INTENTION_EXCLUSIVE锁，源码如FLUSH TABLES WITH READ LOCK所述。
```

如果INSERT/UPDATE/DELETE LOW\_PRIORITY语句TABLE上加MDL\_SHARED\_WRITE\_LOW\_PRIO锁。

#### ALTER TABLE ALGORITHM=COPY\[INPLACE\]

ALTER TABLE ALGORITHM=COPY

COPY方式ALTER TABLE在open\_table阶段加GLOBAL-STATEMENT-INTENTION\_EXCLUSIVE锁，SCHEMA-TRANSACTION-INTENTION\_EXCLUSIVE锁，TABLE-TRANSACTION-SHARED\_UPGRADABLE锁。

在拷贝数据前将TABLE-TRANSACTION-SHARED\_UPGRADABLE锁升级到SHARED\_NO\_WRITE。

拷贝完在交换表阶段将SHARED\_NO\_WRITE锁升级到EXCLUSIVE锁。

源码解析：

```php
GLOBAL、SCHEMA锁初始化位置和LOCK TABLE WRITE位置一致都是在lock_table_names函数中。在open_table中也会请求锁。

sql/sql_yacc.yy
alter:
          ALTER TABLE_SYM table_ident
          {
            THD *thd= YYTHD;
            LEX *lex= thd->lex;
            lex->name.str= 0;
            lex->name.length= 0;
            lex->sql_command= SQLCOM_ALTER_TABLE;
            lex->duplicates= DUP_ERROR;
            if (!lex->select_lex->add_table_to_list(thd, $3, NULL,
                                                    TL_OPTION_UPDATING,
                                                    TL_READ_NO_INSERT,
                                                    MDL_SHARED_UPGRADABLE))

bool mysql_alter_table(THD *thd, const char *new_db, const char *new_name,
                       HA_CREATE_INFO *create_info,
                       TABLE_LIST *table_list,
                       Alter_info *alter_info)
{
  //升级锁
  if (thd->mdl_context.upgrade_shared_lock(mdl_ticket, MDL_SHARED_NO_WRITE,
                                           thd->variables.lock_wait_timeout)
      || lock_tables(thd, table_list, alter_ctx.tables_opened, 0))
  ...
  if (wait_while_table_is_used(thd, table, HA_EXTRA_PREPARE_FOR_RENAME))

}


bool wait_while_table_is_used(THD *thd, TABLE *table,
                              enum ha_extra_function function)
{
  DBUG_ENTER("wait_while_table_is_used");
  DBUG_PRINT("enter", ("table: '%s'  share: 0x%lx  db_stat: %u  version: %lu",
                       table->s->table_name.str, (ulong) table->s,
                       table->db_stat, table->s->version));

  if (thd->mdl_context.upgrade_shared_lock(
             table->mdl_ticket, MDL_EXCLUSIVE,
             thd->variables.lock_wait_timeout))
```

ALTER TABLE INPLACE的加锁：

INPLACE方式在打开表的时候也是加GLOBAL-STATEMENT-INTENTION\_EXCLUSIVE锁，SCHEMA-TRANSACTION-INTENTION\_EXCLUSIVE锁，TABLE-TRANSACTION-SHARED\_UPGRADABLE锁。

在prepare前将TABLE-TRANSACTION-SHARED\_UPGRADABLE升级为TABLE-TRANSACTION-EXCLUSIVE锁。

在prepare后会再将EXCLUSIVE根据不同引擎支持情况降级为SHARED\_NO\_WRITE(不允许其他线程写入)或者SHARED\_UPGRADABLE锁（其他线程可以读写，InnoDB引擎）。

在commit前，TABLE上的锁会再次升级到EXCLUSIVE锁。

```php
sql/sql_table.cc
static bool mysql_inplace_alter_table(THD *thd,
                                      TABLE_LIST *table_list,
                                      TABLE *table,
                                      TABLE *altered_table,
                                      Alter_inplace_info *ha_alter_info,
                                      enum_alter_inplace_result inplace_supported,
                                      MDL_request *target_mdl_request,
                                      Alter_table_ctx *alter_ctx)
{
  ...
  else if (inplace_supported == HA_ALTER_INPLACE_SHARED_LOCK_AFTER_PREPARE ||
           inplace_supported == HA_ALTER_INPLACE_NO_LOCK_AFTER_PREPARE)
  {
    /*
      Storage engine has requested exclusive lock only for prepare phase
      and we are not under LOCK TABLES.
      Don't mark TABLE_SHARE as old in this case, as this won't allow opening
      of table by other threads during main phase of in-place ALTER TABLE.
    */
    if (thd->mdl_context.upgrade_shared_lock(table->mdl_ticket, MDL_EXCLUSIVE,
                                             thd->variables.lock_wait_timeout))
  ...
  if (table->file->ha_prepare_inplace_alter_table(altered_table,
                                                ha_alter_info))
  ...
  if ((inplace_supported == HA_ALTER_INPLACE_SHARED_LOCK_AFTER_PREPARE ||
     inplace_supported == HA_ALTER_INPLACE_NO_LOCK_AFTER_PREPARE) &&
    !(thd->locked_tables_mode == LTM_LOCK_TABLES ||
      thd->locked_tables_mode == LTM_PRELOCKED_UNDER_LOCK_TABLES) &&
    (alter_info->requested_lock != Alter_info::ALTER_TABLE_LOCK_EXCLUSIVE))
  {
    /* If storage engine or user requested shared lock downgrade to SNW. */
    if (inplace_supported == HA_ALTER_INPLACE_SHARED_LOCK_AFTER_PREPARE ||
        alter_info->requested_lock == Alter_info::ALTER_TABLE_LOCK_SHARED)
      table->mdl_ticket->downgrade_lock(MDL_SHARED_NO_WRITE);
    else
    {
      DBUG_ASSERT(inplace_supported == HA_ALTER_INPLACE_NO_LOCK_AFTER_PREPARE);
      table->mdl_ticket->downgrade_lock(MDL_SHARED_UPGRADABLE);
    }
  }
  ...
  // Upgrade to EXCLUSIVE before commit.
  if (wait_while_table_is_used(thd, table, HA_EXTRA_PREPARE_FOR_RENAME))
  ...
  if (table->file->ha_commit_inplace_alter_table(altered_table,
                                               ha_alter_info,
                                               true))
}
```

#### CREATE TABLE 加锁

CREATE TABLE先加锁GLOBAL-STATEMENT-INTENTION\_EXCLUSIVE，SCHEMA-MDL\_TRANSACTION-INTENTION\_EXCLUSIVE，TABLE-TRANSACTION-SHARED。

表不存在则升级表上的SHARED锁到EXCLUSIVE。

```plain
bool open_table(THD *thd, TABLE_LIST *table_list, Open_table_context *ot_ctx)
{
  ...
  if (!exists)
  {
    ...
    bool wait_result= thd->mdl_context.upgrade_shared_lock(
                         table_list->mdl_request.ticket,
                         MDL_EXCLUSIVE,
                         thd->variables.lock_wait_timeout);
    ...
  }
  ...
}
```

### DROP TABLE 加锁

drop table语句执行加锁GLOBAL-STATEMENT-INTENTION\_EXCLUSIVE，SCHEMA-MDL\_TRANSACTION-INTENTION\_EXCLUSIVE，TABLE-EXCLUSIVE。

```plain
drop:
          DROP opt_temporary table_or_tables if_exists
          {
            LEX *lex=Lex;
            lex->sql_command = SQLCOM_DROP_TABLE;
            lex->drop_temporary= $2;
            lex->drop_if_exists= $4;
            YYPS->m_lock_type= TL_UNLOCK;
            YYPS->m_mdl_type= MDL_EXCLUSIVE;
          }
```