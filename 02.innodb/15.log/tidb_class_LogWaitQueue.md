#1.class LogWaitQueue

```cpp
class alignas(INNOBASE_CACHE_LINE_SIZE) LogWaitQueue
{
public:
    struct time_stats_t
    {
        /** avg rsp time in each statistical cycle */
        ulint       avg_time;

        /** avg rsp time2 in each statistical cycle */
        ulint       avg_time2;

        /** sum rsp time in each statistical cycle */
        uint64_t    sum_time;

        /** number of released slot in each statistical cycle */
        ulint       n_count;
    };
private:
    LogWaitSlot_t* m_data;
    LogWaitSlot_t* m_data_ptr;

    alignas(INNOBASE_CACHE_LINE_SIZE)
    uint64_t m_size;

    alignas(INNOBASE_CACHE_LINE_SIZE)
    std::atomic<uint64_t> m_in;

    alignas(INNOBASE_CACHE_LINE_SIZE)
    std::atomic<uint64_t> m_out;

    alignas(INNOBASE_CACHE_LINE_SIZE)
    std::atomic<uint64_t> m_entry_add;

    alignas(INNOBASE_CACHE_LINE_SIZE)
    std::atomic<uint64_t> m_entry_release;

    /* time stats */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    time_stats_t m_time_stats;
};    



```

#2.LogWaitQueue::reserve

```cpp
caller:
- log_write_up_to

LogWaitQueue::reserve
--no = m_in.fetch_add(1);
--slot = &m_data[no & (m_size - 1)];
--while (true)
----if (no < m_size + m_out.load())
------slot->wait_lsn = lsn
------slot->time = ts
------if (lsn > log_sys->flushed_to_disk_lsn.load())
--------slot->message = m1
--------m_entry_add++
------else
--------flushed = true
------slot->reserve_no.store(no + 1)
----else
------stop_condition//lambda
------ut_wait_for(0, 10, stop_condition);
--//end while


```

#3.LogWaitQueue::release

#4.async_commit
