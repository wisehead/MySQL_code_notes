
# MySQL · 源码分析 · Query Cache并发处理

*   [当期文章](#)

## MySQL · 源码分析 · Query Cache并发处理

## Query cache 的并发处理

上期介绍了Query cache的一个基本工作原理，请参考[MySQL · 源码分析 · Query Cache内部剖析](http://mysql.taobao.org/monthly/2016/07/09/)。本期将对Query cache的并发处理过程进行一个剖析。

当前Query cache是所有session共享的，也就是说同一条SELECT语句 + database + flag（包含影响执行结果的所有环境变量）构成的Key如果已经存储在Query cache中了，任何session都可以从Query cache中获取想要的结果集。所有session共享Query cache，那如何处理并发呢？当前Query cache只支持查询，插入，删除操作，不支持更新。下面我们将对这三种操作的并发原理进行分析。

在对三种操作进行分析之前，我们先来看看Query cache 并发处理的方式。Query cache的并发处理，同样是利用锁。对于Query cache对象自身的所有操作使用一把mutex锁来进行并发控制。Query\_cache在其初始化，即调用Query\_cache::init的时候，会初始化如下锁变量：

```plain
void Query_cache::init()
{
  mysql_mutex_init(key_structure_guard_mutex,
            &structure_guard_mutex, MY_MUTEX_INIT_FAST);
  mysql_cond_init(key_COND_cache_status_changed,
            &COND_cache_status_changed, NULL);
    m_cache_lock_status= Query_cache::UNLOCKED;
  ……
}
```

**说明**：

`key_structure_guard_mutex`以及`key_COND_cache_status_changed`这两个变量是用来处理Query cache与PSI(Performance schema instrumentation interface)相关的并发控制，这里我们不对其进行介绍，如果有兴趣可以参考PSI的相关介绍。

另外一个mutex变量`structure_guard_mutex`用来控制Query cache的并发访问，同时它也用来配合**mysql\_cond\_t** `key_COND_cache_status_changed`来控制对Query cache锁的超时处理。我们会在稍后介绍加锁处理的地方进行具体描述。

`m_cache_lock_status`控制当前Query cache所处的状态。该变量有3个值：

<table><tbody><tr><td><strong>UNLOCKED</strong></td><td>表明当前Query cache处于未被使用状态。该状态下我们使用mutex来控制Query cache的并发访问。</td></tr><tr><td><strong>LOCKED_NO_WAIT</strong></td><td>表明当前的Query cache正处于Flush或者是正在关闭使用Query cache的状态。</td></tr><tr><td><strong>LOCKED</strong></td><td>表明当前的Query cache正在被使用。此时我们利用mysql_cond_t来进行加锁，同时支持锁定超时。</td></tr></tbody></table>

Query cache中一个重要的控制并发的函数是`Query_cache::try_lock`，也就是加锁过程，算法实现如下：

```plain
bool Query_cache::try_lock(bool use_timeout)
{
  mysql_mutex_lock(&structure_guard_mutex); //首先试图获取mutex
  while(1)
  {
    if (m_cache_lock_status == Query_cache::UNLOCKED)
    {
      m_cache_lock_status= Query_cache::LOCKED; //如果Query cache未被锁定，那么我们修改其状态为锁定状态。利用mutex进行加锁。
      break;
    }
    else if (m_cache_lock_status == Query_cache::LOCKED_NO_WAIT)
    {
      interrupt= TRUE; //这里表示Query cache正在被Flush或者处于关闭状态，没有必要再加锁继续进行操作。遇到这种状态，需要加锁的操作将直接返回。
      break;
    }
    else
    {
      if (use_timeout) //这个参数是控制是否需要超时处理。
      {
        set_timespec_nsec(waittime,(ulong)(50000000L));  // 50微秒超时
        int res= mysql_cond_timedwait(&COND_cache_status_changed,
                        &structure_guard_mutex, &waittime);
      }
      else
      {
        mysql_cond_wait(&COND_cache_status_changed, 
                        &structure_guard_mutex);
      }
    }
  }
}
```

Query cache的记录查询，插入都需要先使用`Query_cache::try_lock`加锁。使用`Query_cache::try_lock`加锁的主要原因是可以检查Query cache所处的锁定状态，如果Query cache正在FLUSH或者关闭，记录查询或者插入都将没有意义，因此检查到锁定状态为**Query\_cache::LOCKED\_NO\_WAIT**就可以直接返回了。

对于删除Query cache中的记录，操作前进行的锁定是`Query_cache::lock`。该函数与`Query_cache::try_lock`的唯一区别就是不再检查**Query\_cache::LOCKED\_NO\_WAIT**状态，一直等待直到获取Query cache锁。

### Query cache的记录查询

基本流程如下：(下面的函数定义写的都是伪代码，如需了解详情请参考MySQL源码)

```sql
Query_cache::send_result_to_client(…)
{
  If (!SELECT语句)
    return;
  if (try_lock()) 
    return;
  构造Query cache中Key值（Key值包含了query + database + flag（包含影响执行结果的所有环境变量））;
  query_block= 通过Key值查找Query cache中的Query_cache_block；

  if (!query_block) //未找到任何记录
    return；

  if (query_block->result_type == Query_cache_block::RESULT) // 这里的条件是用来判断与该条Query相关的结果集是否已经被完全的写入了Query cache中。如果结果集没有全部写入，显然我们也不能返回结果集。
  {
    RD_lock (query_block); //这个Query_cache_block的块锁应该没什么用处，因为所有操作都需要Query cache的全局mutex。
    if (表的权限检查成功)
      返回结果集；
    RD_unlock(query_block); //释放Query_cache_block的Read锁。
  }

  unlock(); // 释放Query cache的全局mutex。
}
```

### Query cache数据的插入

目前插入流程如下：

```php
Query_cache::store_query();
// 该函数首先生成Query_cache_block的header部分。
// header包含哪几部分请参考往期月报, MySQL · 源码分析 · Query Cache内部剖析。
// 生成的header会挂到thd->query_cacne_tld.first_query_block。
// thd->query_cacne_tld.first_query_block用来在接下来的Query_cache::insert()过程中判断是否当前session需要缓存结果集。

注意：Query cache目前实现中只有生成Query_cache_block header的session才可以为该block添加数据，
     其他session如果输入同样的执行语句，在调用Query_cache::store_query()会发现已经有session生成了header，就不会再重复生成header了。
     这样实现的目的是让一个session负责写入所有的结果集，可以避免其他session进行干扰。

Query_cache::insert(…) //负责将结果集缓存到Query_cache_block的数据部分。
{
  if (query_block= thd->query_cache_tls->first_query_block) //检查当前session是否需要缓存结果集
  {
    if (try_lock()) 
      return;
    RW_lock(query_block->query()->lock); //这里的写锁同样没有作用了，因为Query cache的mutex会对并发进行控制。
      append_result_data(); //将结果集缓存到Query_cache_block中。
    RW_unlock(query_block->query()->lock); //释放排他锁。
    unlock(); // 释放Query cache的全局排他锁。
  }
}
```

### Query cache的删除：

```sql
Query_cache::invalidate_table(…)
{
  lock(); 
  // 这里使用lock而非try_lock，是因为我们需要强制失效所有与table相关的Query_cache_block。
  // 而try_lock会在Query cache的状态为Query_cache::LOCKED_NO_WAIT的时候直接返回。
  invalidate_table_internal(); //失效所有与指定表相关的Query cache。
  unlock(); //释放全局mutex。
}
```

对于Query cache的失效部分，目前的处理方式非常暴力，任何对表数据的修改，包括UPDATE/INSERT/DELETE操作，都会将该表相关的所有Query cache记录实效掉，这种实效方式影响非常大。建议增加对于WHERE，HAVING等过滤条件的判断，如果Query cache中的记录涉及的结果集与当前UPDATE/INSERT/DELETE所涉及的数据没有交集，我们完全没有必要实效掉这样的记录。比如：

```sql
SELECT * FROM t WHERE t.a > 10;
```

我们对于这样一条SELECT语句进行结果集的缓存。对于如下的INSERT/UPDATE/DELETE 语句来说，我们完全没有必要去失效与这条SELECT语句相关的结果集缓存，因为下面这几条语句操作的数据集和SELECT的结果集没有发生任何交集。

```sql
INSERT INTO t (a) VALUES(1);
UPDATE t SET a=4 WHERE a < 5;
DELETE FROM t WHERE a < 5;
```

对于DDL其实我们也可以做的更好，比如对于下面这条SELECT语句的结果集缓存记录来说：

```sql
SELECT a FROM t WHERE t.a > 10;
```

如果对于下面的DDL，完全可以不去失效SELECT语句的结果集缓存记录。

```sql
ALTER TABLE t ADD COLUMN c INT;
```

总而言之，Query cache的并发处理的粒度比较大，几乎所有的操作都需要拿到Query cache的全局mutex。如果可以对Query cache的全局状态变量使用Free lock，只对于存储分配使用mutex，对Query\_cache\_block进行加锁处理会对性能有所改进。