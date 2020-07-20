#.create table in V8.0

```cpp

Sql_cmd_create_table::execute
-->mysql_create_table
  -->mysql_create_table_no_lock
     -->create_table_impl
        -->rea_create_base_table
           -->ha_create_table
              -->ha_create
                 -->ha_innobase::create
                    -->innobase_basic_ddl::create_impl
                       -->create_table_info_t::create_table
                       {
                          ......
                       }
  
  -->trans_commit_implicit
     -->ha_commit_trans
        -->MYSQL_BIN_LOG::prepare
           -->ha_prepare_low  //所有事务引擎prepare
              {
                binlog_prepare
                innobase_xa_prepare
              }
        -->MYSQL_BIN_LOG::commit
           -->MYSQL_BIN_LOG::ordered_commit
              -->MYSQL_BIN_LOG::process_flush_stage_queue
                 -->MYSQL_BIN_LOG::flush_thread_caches
                    -->binlog_cache_mngr::flush
                       -->binlog_cache_data::flush
                          -->MYSQL_BIN_LOG::write_gtid
                             -->Log_event::write
                                -->MYSQL_BIN_LOG::Binlog_ofile::write  //写binlog-gtid
  
                          -->MYSQL_BIN_LOG::write_cache
                             --> MYSQL_BIN_LOG::do_write_cache
                                 -->Binlog_cache_storage::copy_to
                                    -->stream_copy
                                       -->Binlog_event_writer::write
                                          -->MYSQL_BIN_LOG::Binlog_ofile::write //写binlog-ddl语句
              -->MYSQL_BIN_LOG::sync_binlog_file
              -->MYSQL_BIN_LOG::process_commit_stage_queue
                 -->ha_commit_low
                    {
                       binlog_commit
                       innobase_commit
                       -->trx_commit_for_mysql
                          -->trx_commit
                              -->trx_commit_low
                                 -->trx_commit_in_memory
                                    -->trx_undo_insert_cleanup
                    }
  
  -->innobase_post_ddl(ht->post_ddl(thd))
     -->Log_DDL::post_ddl
        -->replay_by_thread_id
        
```