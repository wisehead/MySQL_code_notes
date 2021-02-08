#1.bootstrap::initialize

初始化流程


最开始的调用栈如上，在 dd::Dictionary_impl::init 中就会根据 enum_dd_init_type 来决定接下来调用的函数

*     DD_INITIALIZE：当以 --initialize-secure 或 --initialize-insecure 方式启动 MySQL 时，调用 bootstrap::initialize
*     DD_RESTART_OR_UPGRADE：MySQL 重启，调用upgrade_57::do_pre_checks_and_initialize_dd
*     DD_INITIALIZE_SYSTEM_VIEWS
*     DD_POPULATE_UPGRADE
*     DD_DELETE
*     DD_UPDATE_I_S_METADATA

注意这里会开启一个线程 key_thread_bootstrap 来执行 bootstrap::initialize 或 upgrade_57::do_pre_checks_and_initialize_dd 等等，并且同步的等待该线程执行完。在数据库第一次初始化时的流程为


```cpp

bootstrap::initialize
 |- DDSE_dict_init
 |- initialize_dictionary
  |- store_predefined_tablespace_metadata
  |- create_dd_schema
  |- initialize_dd_properties
  |- create_tables
  |- ...
```