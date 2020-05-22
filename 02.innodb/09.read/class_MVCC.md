#1.class MVCC

```cpp
/** The MVCC read view manager */
class MVCC {
public:
private:
    typedef UT_LIST_BASE_NODE_T(ReadView) view_list_t;

    /** Free views ready for reuse. */
    view_list_t             m_free;

    /** Active and closed views, the closed views will have the
    creator trx id set to TRX_ID_MAX */
    view_list_t             m_views;
};
```