#1.struct mtr_t

```cpp
struct mtr_t {
    /** State variables of the mtr */
    struct Impl {
        mtr_buf_t    m_memo;  /** memo stack for locks etc. */
        //管理锁信息。这是一个以栈方式管理锁的结构体
        mtr_buf_t    m_log; /** mini-transaction log *///管理日志信息
        bool        m_made_dirty;/** true if mtr has made at least one buffer
                    pool page dirty */
        bool        m_inside_ibuf; /** true if inside ibuf changes */
        bool        m_modifications; /** true if the mini-transaction modified buffer pool pages */
        ib_uint32_t m_n_log_recs; /** Count of how many page initial log records
         have been written to the mtr log */
        mtr_log_t    m_log_mode;//Mini Transaction提供了四种类型，缺省是MTR_LOG_ALL，
表示记录所有修改数据的操作（该不该记日志、什么要记下来对于日志技术来讲很重要，如何记日志(页面级
还是元组级)是整体设计时就该确定的问题，影响到了后续的复制同步技术）
...
        fil_space_t*    m_user_space; //指向被mini-transaction修改的用户表空间
        fil_space_t*    m_undo_space; //指向被mini-transaction修改的UNDO日志表空间
        fil_space_t*    m_sys_space;  //指向被mini-transaction修改的系统表空间，这三个
                                       表空间是事务持久化到外存的联系纽带
        /** State of the transaction */
        mtr_state_t    m_state;  //标识Mini Transaction的状态，只有四种情况，分别是初
                                   始、活动、正在提交、完成提交四种状态
        mtr_t*        m_mtr;/** Owning mini-transaction */
    };
...
}
```