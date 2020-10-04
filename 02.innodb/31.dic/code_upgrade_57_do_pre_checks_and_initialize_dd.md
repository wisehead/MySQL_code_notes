#1.upgrade_57::do_pre_checks_and_initialize_dd

重启动流程

Data Dictionary 重启过程有三个阶段

1. Preparation phase

2. Scaffolding phase

函数 create_dd_schema / create_tables 完成。只是把相应的 dd:Schema 和 dd:Table 对象存储到 storage adapter 的 core storage 里（一个缓存）。这里的目的是使用这些 fake metadata 来打开磁盘上真正的 data dictionary 表，打开的过程需要这些初级的 metadata。fake metadata 生成的方式是执行 SQL，例如 

```SQL
CREATE TABLE innodb_ddl_log(\n  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,\n 
thread_id BIGINT UNSIGNED NOT NULL,\n  type INT UNSIGNED NOT NULL,\n  space_id INT UNSIGNED,
\n  page_no INT UNSIGNED,\n  index_"...}
```

3. Synchronization phase

函数 sync_meta_data 完成。使用第2步里 fake metadata，来打开 data dictionary 表。
在 open_table_def 里会使用 dd:Table 对象填充 TABLE_SHARE 对象。在 MySQL 5.6 中，TABLE_SHARE 对象里的信息是通过打开 frm 文件中的内容来填充的。并且注意，在第3步里从磁盘上生成真正的 data dictionary 中每张表的 dd:Table 对象时使用的是 dd::cache::Storage_adapter::instance()→get，并且设置 bypass_core_registry 为 true。意味着会调用 DDSE（InnoDB）handler 接口真正的从磁盘上读出。

我们来分析重启的代码，从 upgrade_57::do_pre_checks_and_initialize_dd 开始


```cpp
upgrade_57::do_pre_checks_and_initialize_dd
 |- DDSE_dict_init
 |- restart_dictionary
  |- bootstrap::restart
    |- store_predefined_tablespace_metadata
    |- create_dd_schema
    |- initialize_dd_properties
    |- create_tables
    |- sync_meta_data
    |- DDSE_dict_recover
    |- ...

```