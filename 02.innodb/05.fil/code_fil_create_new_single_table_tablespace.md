#1.fil_create_new_single_table_tablespace


```cpp
caller:
--dict_build_table_def_step

fil_create_new_single_table_tablespace
--fil_make_ibd_name
--pfs_os_file_create_func
--os_file_set_size
--fsp_header_init_fields
--buf_flush_init_for_writing
--os_file_write(path, file, page, 0, UNIV_PAGE_SIZE);//第0个page
--os_file_flush
--fil_space_create
```

#2.fil_space_create

```cpp
fil_space_create
--
```