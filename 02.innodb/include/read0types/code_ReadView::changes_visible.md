#1.changes_visible


```cpp

class ReadView {  //快照，即活动事务的事务id的范围，是一个区间。可以看作事务生命长河中的一
段，不同的快照就是不同的一段
    /** This is similar to a std::vector but it is not a drop in replacement.
   It is specific to ReadView. */
    class ids_t {...};
public:
...
    /** Check whether the changes by id are visible.
    @param[in]    id    transaction id to check against the view
    @param[in]    name    table name
    @return whether the view sees the modifications of id. */
    bool changes_visible(   //元组的可见性判断。重要方法。
        trx_id_t id, const table_name_t& name) const MY_ATTRIBUTE((warn_unused_result))
    {
        ut_ad(id > 0);
        if (id < m_up_limit_id || id == m_creator_trx_id) {
        //小于快照的最小边界，则可见。意味着是快照之前发生的事务
            return(true);
        }
        check_trx_id_sanity(id, name);
        //检查事务id的合法性，放到此处判断，暗含着一个意思是：m_up_limit_id
        < trx_sys->max_trx_id
        if (id >= m_low_limit_id) {
        //大于快照的最大边界，一定不可见。意味着是快照之后发生的事务
            return(false);
        } else if (m_ids.empty()) {
        //生成快照时的正发生读写操作的事务集合，如为空，表示不存在读写事务，所以可见
            return(true);
        }
        const ids_t::value_type*    p = m_ids.data();
        //正发生读写操作的事务集合，每个快照都有一个其自己对应的这样一个状态集
        return(!std::binary_search(p, p + m_ids.size(), id)); //生成快照时的正发生读
        写操作的事务集合中不包括id指定的事务，则可见；包括则不可见。这时因为在创建快照的时候，
        读写集合中包括某个事务ID表明这个ID对应的事务正在运行中，没有提交，所以不可见。这一点，
        实现的正是读已提交的功能
    }
...
}
```