#1.xarecover_handlerton

```cpp
xarecover_handlerton(... xids ...)
  // 这里以innodb进行说明
| if (hton->state == SHOW_OPTION_YES && hton->recover)
    // 调用引擎插件的recover函数
    // innodb会解析redo log，读取出所有处于prepare状态的事务，返回事务的xid
    while ((got= hton->recover(hton, info->list, info->len)) > 0)
        // 遍历引擎插件返回的xid数组
        // innodb的redo log中处于prepare状态的事务xid
        for (int i= 0; i < got; i++)
            // 在最后一个binlog中读取的xid的hash桶（传入参数）查找xid
            // 如果找到了，说明该事务记录了binlog，则commit，找不到则rollback
            if ( my_hash_search(info->commit_list, (uchar *)&x, sizeof(x)) != 0 :
                hton->commit_by_xid(hton, info->list + i);
            else
                hton->rollback_by_xid(hton, info->list + i);
```