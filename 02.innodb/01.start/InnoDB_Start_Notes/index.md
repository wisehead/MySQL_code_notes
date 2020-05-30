

# InnoDB（一）


本文基于 MySQL 8.0.18，描述 InnoDB 启动的整体流程（主要在 srv\_start）

## 扫描数据目录

```plain
// 使用构造函数初始化 Fil_system（主要是 m_shards）
fil_init
// 扫描数据目录
fil_scan_for_tablespaces
 |- Tablespace_dirs::scan
   |- duplicate_check(ibd_files/undo_files)
     // Mapping from tablespace ID to data filenames/undo files
     |- m_undo_paths / m_ibd_paths
```

这里会建立两个映射 m\_ibd\_paths / m\_undo\_paths

*   **扫描目录**：Crash Recoery 时，扫描目录下的所有文件（fil\_scan\_for\_tablespaces），从文件的第一个 Page读到该 tablespace 的 space\_id（Fil\_system::get\_tablespace\_id），建立<space\_id, filename>的映射 m\_ibd\_paths（files.add）
*   **维护集合**：前滚日志时，维护两个集合
    *   **deleted**：在 checkpoint 之后被删除的表空间，通过 _MLOG\_FILE\_DELETE_ 判断 
    *   **missing\_ids** ：在前滚过程之中，若发现在在日志里存在的 space\_id，但在目录下（即 m\_ibd\_paths / m\_undo\_paths）里没有，**不回放该日志**，将其 space\_id 加入到集合 missing\_ids（fil\_tablespace\_lookup\_for\_recovery）
*   **判断文件是否异常丢失**：missing\_ids 中存在，而 deleted 没有的 space\_id，则会出现 _Warnings_，说明表空间丢失

## 一些组件的初始化

```plain
// 初始化 AIO 组件
os_aio_init
// 初始化 Buffer Pool
buf_pool_init
fsp_init
// recovery system / transaction system / lock system
recv_sys_create / trx_sys_create / lock_sys_create
// 创建一些 IO 线程，用于异步的 IO 操作
os_thread_create(io_handler_thread) ...
// 初始化 page cleaner system
buf_flush_page_cleaner_init
```

## 系统表空间

```plain
// 打开或者创建系统表空间文件
srv_sys_space.open_or_create
  |- open_file / create_file
    |- Datafile::open_or_create
      |- os_file_create
    |- set_size / check_size
  |- read_lsn_and_check_flags
    // 初始化 double write structure
    |- buf_dblwr_init_or_load_pages
    // 读每一个文件的第一个数据页
    |- read_first_page
    // 验证数据页是否正常（必要的话，从 double write 里恢复第一个数据页再检查）
    //  1- 全是0？
    //  2- 验证文件第一个数据页的 page no 是否是0（如果是表空间第二个文件的第一个数据页？）
    //  3- 是否所有文件的 space id 都相同，等于 TRX_SYS_SPACE
    |- validate_first_page / restore_from_doublewrite
  // 构造 fil_space_t 代表系统表空间
  |- fil_space_create
  // 对每一个文件，创建 fil_node_t 来代表，并将其加入到 file_space_t.files 数组中
  |- fil_node_create
// 暂不清楚
dict_persist_init
```

## Redo log

这里分为两部分：

1.  新的实例，创建日志文件
2.  旧的实例，检查已有日志文件是否丢失，并打开文件

### 新实例

```plain
create_log_files
  // 根据 srv_n_log_files，创建几个日志文件：ib_logfile0，ib_logfile0 ...
  // 但注意，此时创建的第一个日志文件名是 ib_logfile101
  |- create_log_file
    // 创建文件，设置大小，关闭文件
    |- os_file_create
    |- os_file_set_size
    |- os_file_close
  // 创建 fil_space_t structure
  |- fil_space_create
  // 为每个日志文件创建 fil_node_t structure
  |- fil_node_create
  |- log_sys_init
  |- fil_open_log_and_system_tablespace_files / log_create_first_checkpoint / fil_flush_file_redo
```

### 旧实例

遍历已存在的日志文件：

*   如果没有 ib\_logfile0，调用 create\_log\_files 创建全新的一组日志文件
*   如果有 ib\_logfile0 / 没有 ib\_logfile1，启动失败





