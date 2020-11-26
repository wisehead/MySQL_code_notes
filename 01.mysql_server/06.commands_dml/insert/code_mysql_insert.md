#1.mysql_insert

```cpp
bool mysql_insert(THD *thd,
                   TABLE_LIST *table_list,      // 该INSERT要用到的表
                   List<Item> &fields,             // 使用的项
                   ....) {
    open_and_lock_tables(thd, table_list); // 这里的锁只是防止表结构修改
    mysql_prepare_insert(...);
    foreach value in values_list {
        write_record(...);
    }
} //里面还有很多处理trigger，错误，view之类的杂七杂八的东西，我们都忽略。
```

#2. write_record

```cpp
int write_record(THD *thd, TABLE *table,COPY_INFO *info) {  // 写数据记录
    if (info->handle_duplicates == DUP_REPLACE || info->handle_duplicates == DUP_UPDATE) { //如果是REPLACE或UPDATE则替换数据
        table->file->ha_write_row(table->record[0]);
        table->file->ha_update_row(table->record[1], table->record[0]));
    } else {
        table->file->ha_write_row(table->record[0]);
    }
}
```

#3.handler::ha_write_row

```cpp
nt handler::ha_write_row(uchar *buf) { //这是啥? Handler API !
    write_row(buf);   // 调用具体的实现
    binlog_log_row(table, 0, buf, log_func));  // 写binlog
}

handler::ha_write_row
--ha_tokudb::write_row
```