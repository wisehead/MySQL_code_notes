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

#3.LogWaitQueue::release