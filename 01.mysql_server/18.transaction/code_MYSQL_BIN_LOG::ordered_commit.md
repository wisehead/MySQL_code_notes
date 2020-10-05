#1.MYSQL_BIN_LOG::ordered_commit

```cpp
MYSQL_BIN_LOG::ordered_commit()           ← 执行事务顺序提交，binlog group commit的主流程
 |
 |-##################                     ← 进入Stage_manager::FLUSH_STAGE阶段
 |-change_stage(..., &LOCK_log)
 | |-stage_manager.enroll_for()           ← 将当前线程加入到m_queue[FLUSH_STAGE]中
 | |
 | |                                      ← (follower)返回true
 | |-mysql_mutex_lock()                   ← (leader)对LOCK_log加锁，并返回false
 |
 |-finish_commit()                        ← (follower)对于follower则直接返回
 | |-ha_commit_low()
 |
 |-process_flush_stage_queue()            ← (leader)对于follower则直接返回
 | |-fetch_queue_for()                    ← 通过stage_manager获取队列中的成员
 | | |-fetch_and_empty()                  ← 获取元素并清空队列
 | |-ha_flush_log()
 | |-flush_thread_caches()                ← 对于每个线程做该操作
 | |-my_b_tell()                          ← 判断是否超过了max_bin_log_size，如果是则切换binlog文件
 |
 |-flush_cache_to_file()                  ← (follower)将I/O Cache中的内容写到文件中
 |-RUN_HOOK()                             ← 调用HOOK函数，也就是binlog_storage->after_flush()
 |
 |-##################                     ← 进入Stage_manager::SYNC_STAGE阶段
 |-change_stage()
 |-sync_binlog_file()
 | |-mysql_file_sync()
 |   |-my_sync()
 |     |-fdatasync()                      ← 调用系统API写入磁盘，也可以是fsync()
 |
 |-##################                     ← 进入Stage_manager::COMMIT_STAGE阶段
 |-change_stage()                         ← 该阶段会受到binlog_order_commits参数限制
 |-process_commit_stage_queue()           ← 会遍厉所有线程，然后调用如下存储引擎接口
 | |-ha_commit_low()
 |   |-ht->commit()                       ← 调用存储引擎handlerton->commit()
 |   |                                    ← ### 注意，实际调用如下的两个函数
 |   |-binlog_commit()
 |   |-innobase_commit()
 |-process_after_commit_stage_queue()     ← 提交之后的后续处理，例如semisync
 | |-RUN_HOOK()                           ← 调用transaction->after_commit
 |
 |-stage_manager.signal_done()            ← 通知其它线程事务已经提交
 |
 |-finish_commit()
 
```