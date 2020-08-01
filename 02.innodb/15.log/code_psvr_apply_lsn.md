#1.apply_lsn

```cpp
queue->log_apply_lsn、
prpl_sys->shred_lsn

```
##1.1 prpl_log_apply_worker_thread

```cpp
//如果queue中没有日志
queue->log_apply_lsn.store(shred_lsn);
```
