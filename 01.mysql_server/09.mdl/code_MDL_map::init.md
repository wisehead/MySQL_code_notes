#1.MDL_map::init

```cpp
void MDL_map::init()/** Initialize the container for all MDL locks. */
//在mysqld启动时初始化MDL模块，作为全局信息
{
    MDL_key global_lock_key(MDL_key::GLOBAL, "", ""); //定义全局锁
    MDL_key commit_lock_key(MDL_key::COMMIT, "", ""); //定义全局提交锁
    m_global_lock= MDL_lock::create(&global_lock_key);
   //创建全局锁，在mdl_locks全局MDL_map对象中存在
    m_commit_lock= MDL_lock::create(&commit_lock_key);
   //创建全局提交锁，在mdl_locks全局MDL_map对象中存在
    m_unused_lock_objects= 0;
    //m_locks，无锁HASH（lock free），在mdl_locks全局MDL_map对象中存在，因无锁结构能
    大幅提高并发度，效率高
    lf_hash_init2(&m_locks, sizeof(MDL_lock), LF_HASH_UNIQUE,
                   0, 0, mdl_locks_key, &my_charset_bin, &murmur3_adapter,
                    &mdl_lock_cons, &mdl_lock_dtor, &mdl_lock_reinit);
}
```