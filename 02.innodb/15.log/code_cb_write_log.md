#1.cb_write_log

```cpp

log_files_write_buffer
--write_blocks(log, write_buf, write_size, real_offset, new_write_lsn, cb_write_log)
----gaia_fil_redo_io
------write_args->cb_write_log = cb_write_log_func;
------afs_log_writer->pwrite(buf, len, 0, offset, &write_args->written_count, write_callback, write_args);
--------write_callback(write_args)
----------cb_arg->cb_write_log
```

#2. log\_files\_write\_buffer

```cpp
log_start_background_threads
--log_writer
----log_writer_write_buffer
------log_files_write_buffer
```

