#1.srv_sys_space.open_or_create

系统表空间

```cpp

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
    //  1- 全是0？
    //  2- 验证文件第一个数据页的 page no 是否是0（如果是表空间第二个文件的第一个数据页？）
    //  3- 是否所有文件的 space id 都相同，等于 TRX_SYS_SPACE
    |- validate_first_page / restore_from_doublewrite
  // 构造 fil_space_t 代表系统表空间
  |- fil_space_create
  // 对每一个文件，创建 fil_node_t 来代表，并将其加入到 file_space_t.files 数组中
  |- fil_node_create
// 暂不清楚
dict_persist_init
```