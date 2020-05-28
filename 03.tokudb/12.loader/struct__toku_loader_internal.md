#1.struct __toku_loader_internal

```cpp
struct __toku_loader_internal {
    DB_ENV *env;
    DB_TXN *txn;
    FTLOADER ft_loader;
    int N;
    DB **dbs; /* [N] */
    DB *src_db;
    uint32_t *db_flags;
    uint32_t *dbt_flags;
    uint32_t loader_flags;
    void (*error_callback)(DB *db, int i, int err, DBT *key, DBT *val, void *error_extra);
    void *error_extra;
    int  (*poll_func)(void *poll_extra, float progress);
    void *poll_extra;
    char *temp_file_template;
    DBT err_key;   /* error key */
    DBT err_val;   /* error val */
    int err_i;     /* error i   */
    int err_errno;
    char **inames_in_env; /* [N]  inames of new files to be created */
};

* env：全局的db_env
* txn：创建loader上下文指定的事务
* N指的是新建索引个数
* src_db是源索引，一般是NULL
* dbs是新建索引数组，共N个
* db_flags是数组，表示每个新建索引的put_flags，pk的put_flags是在set_main_dict_put_flags生成；非pk索引的一般是0
* dbt_flags也是数组，一般是DB_DBT_REALLOC
* loader_flags：可能是LOADER_COMPRESS_INTERMEDIATES表示临时文件保存的中间结果需要压缩，一般是0
* temp_file_template：临时文件的文件名模板
* err_key：记录loader->put失败的key
* err_val：记录loader->put失败的value
* err_i：未使用，本意是希望记录loader->put在写哪个dictionary失败的。loader是pipleline方式实现的，而在loader->put阶段无法确定是在哪个dictionary失败的
* err_errno：记录loader->put失败的errno
* inames_in_env：每个新建索引对应的文件名
```



