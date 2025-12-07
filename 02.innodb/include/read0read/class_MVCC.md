#1.class MVCC

```cpp

/** The MVCC read view manager */
class MVCC {  //MVCC类，是一个管理者，管理“read view”对象，即管理快照
...
    /** Allocate and create a view.
    @param view    view owned by this class created for the caller. Must be freed
    by calling close()
    @param trx     transaction creating the view */
    void view_open(ReadView*& view, trx_t* trx); //创建一个read view
    /** Close a view created by the above function.
    @para view          view allocated by trx_open.
    @param own_mutex    true if caller owns trx_sys_t::mutex */
    void view_close(ReadView*& view, bool own_mutex); //关闭一个read view
    /** Release a view that is inactive but not closed. Caller must own the trx_
sys_t::mutex.
    @param view        View to release */
    void view_release(ReadView*& view); //是否一个read view
    /** Clones the oldest view and stores it in view. No need to call view_close().
    The caller owns the view that is passed in. It will also move the closed
    views from the m_views list to the m_free list.
    This function is called by Purge to create it view.
    @param view        Preallocated view, owned by the caller */
    void clone_oldest_view(ReadView* view);
    /** @return the number of active views */
    ulint size() const;
    /** @return true if the view is active and valid */
    static bool is_view_active(ReadView* view)
    {
        ut_a(view != reinterpret_cast<ReadView*>(0x1));
        return(view != NULL && !(intptr_t(view) & 0x1));
    }
    /**  Set the view creator transaction id. Note: This shouldbe set only
    for views created by RW transactions. */
    static void set_view_creator_trx_id(ReadView* view, trx_id_t id);
...
private:
    typedef UT_LIST_BASE_NODE_T(ReadView) view_list_t;
    /** Free views ready for reuse. */
    view_list_t        m_free; //被释放了的read view列表，准备重用，避免因创建而浪费时间
    /** Active and closed views, the closed views will have the creator trx id
   set to TRX_ID_MAX */
    view_list_t        m_views;
};
```