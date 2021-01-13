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

```cpp
LogWaitQueue::release
--in = m_in.load()
--out = m_out
--while (out < in)
----slot = &m_data[out & (m_size - 1)]
----if (slot->reserve_no.load() == 0)
------stop_condition//lambda
------ut_wait_for(10000, 10, stop_condition)
----if (slot->message != NULL && lsn >= slot->wait_lsn)
------release_slot(slot)
--------slot->callback(slot->message)
----------remote_transfer_async_callback
------------thd_register_finish_process
--------------thd->sync_status= ENGINE_LOG_SYNC_FINISHED
--------------task_coordinator->deliver_unfinished_task
----------------pos= thd->thread_id() % worker_size
----------------w = get_assigned_worker(pos)
----------------Ncdb_worker::put_unfinished_task
------------------unfinished_tasks.push(thd)
------------------if (curr_waits && unfinished_tasks.size() == 1)
--------------------mysql_cond_signal(&tasks_cond)
--------os_atomic_increment_uint64(&m_time_stats.sum_time,ut_time_us(NULL) - slot->time);
--------os_atomic_increment_ulint(&m_time_stats.n_count, 1);
--------slot->time = 0;
--------m_entry_release++
------slot->message = NULL
----if (slot->message == NULL)
------if (out == m_out)
--------slot->wait_lsn = 0;
--------slot->reserve_no.store(0);
--------m_out.fetch_add(1);
----out++
--//end while
```
