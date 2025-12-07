#1.innobase_init

```cpp
innobase_init(  //InnoDB事务相关的函数在InnoDB引擎初始化的时候，被一齐设置，之后可以被
MySQL Server通过函数指针直接调用
    void    *p)    /*!< in: InnoDB handlerton */
{...
    innobase_hton->savepoint_set = innobase_savepoint; //保存点开始
    innobase_hton->savepoint_rollback = innobase_rollback_to_savepoint; //保存点回滚
    innobase_hton->savepoint_rollback_can_release_mdl =  //在回滚到保存点后是否允许安
全地当释放MDL锁（metadata lock）
                innobase_rollback_to_savepoint_can_release_mdl;
    innobase_hton->savepoint_release = innobase_release_savepoint; //释放保存点
    innobase_hton->commit = innobase_commit;//事务提交
    innobase_hton->rollback = innobase_rollback;//事务回滚
    innobase_hton->prepare = innobase_xa_prepare; //XA类型的事务的PREPARE阶段（2PC的第一阶段）
    innobase_hton->recover = innobase_xa_recover; //XA类型的事务的恢复
    innobase_hton->commit_by_xid = innobase_commit_by_xid;//XA类型的事务的第二阶段，
    执行COMMIT阶段（2PC的第二阶段）
    innobase_hton->rollback_by_xid = innobase_rollback_by_xid;//XA类型的事务的第二
    阶段，执行ROLLBACK阶段（2PC的第二阶段）
...
}
```