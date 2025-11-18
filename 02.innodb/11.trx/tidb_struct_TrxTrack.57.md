#1.struct TrxTrack

```cpp
/** Mapping read-write transactions from id to transaction instance, for
creating read views and during trx id lookup for MVCC and locking. */
struct TrxTrack {
        explicit TrxTrack(trx_id_t id, trx_t* trx = NULL)
                :
                m_id(id),
                m_trx(trx)
        {
                // Do nothing
        }

        trx_id_t        m_id;
        trx_t*          m_trx;
};
```

#2. TrxIdSet

```cpp
//typedef std::unordered_set<TrxTrack, TrxTrackHash, TrxTrackHashCmp> TrxIdSet;
typedef std::set<TrxTrack, TrxTrackCmp, ut_allocator<TrxTrack> >
        TrxIdSet;

```

#3. rw_trx_sets

```cpp
struct trx_sys_t
{
...
        TrxIdSet        rw_trx_sets[RW_TRX_PARTITION_INSTANCE];
                                        /*!< Instead of storing trx_id and trx in rw_trx
                                          set, we store mapping information in rw_trx_sets
                                          according trx->id. */
...
}
```