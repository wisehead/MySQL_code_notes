#1.class ReadView

```cpp

/** Read view lists the trx ids of those transactions for which a consistent
    read should not see the modifications to the database. */
class ReadView {  //快照，即活动事务的事务id的范围，是一个区间。可以看作事务生命长河中的一
段，不同的快照就是不同的一段
    /** This is similar to a std::vector but it is not a drop in replacement. It
 is specific to ReadView. */
    class ids_t {...};
public:
...
    /** Check whether the changes by id are visible.
    @param[in]    id    transaction id to check against the view
    @param[in]    name    table name
    @return whether the view sees the modifications of id. */
    bool changes_visible(   //元组的可见性判断。重要函数，详细内容参见12.2节
        trx_id_t id, const table_name_t& name) const MY_ATTRIBUTE((warn_unused_
　　　　　result)) {...}
...
private:
...
    /** The read should not see any transaction with trx id >= this
        value. In other words, this is the "high water mark". */
    trx_id_t    m_low_limit_id;
　　//一个快照，有左右边界，左边界是最小值，右边界是最大值。此变量是右边界
    /** The read should see all trx ids which are strictly
        smaller (<) than this value.  In other words, this is the low water mark". */
    trx_id_t    m_up_limit_id;  //此变量是左边界，小于此值，表示事务发生的更早
    /** trx id of creating transaction, set to TRX_ID_MAX for free views. */
    trx_id_t    m_creator_trx_id;  //正在创建事务的事务id
    /** Set of RW transactions that was active when this snapshot was taken */
    ids_t       m_ids;  //快照创建时，处于活动即尚未完成的读写事务的集合
    /** The view does not need to see the undo logs for transactions whose
    transaction number is strictly
        smaller (<) than this value: they can be removed in purge if not needed
         by other views */
    trx_id_t   m_low_limit_no;
...
};
```