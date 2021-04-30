#1.Latches

```cpp
/**
The class which handles the logic of latching of lock_sys queues themselves.
The lock requests for table locks and record locks are stored in queues, and to
allow concurrent operations on these queues, we need a mechanism to latch these
queues in safe and quick fashion.
In the past we had a single latch which protected access to all of them.
Now, we use more granular approach.
In extreme, one could imagine protecting each queue with a separate latch.
To avoid having too many latch objects, and having to create and remove them on
demand, we use a more conservative approach.
The queues are grouped into a fixed number of shards, and each shard is
protected by its own mutex.

However, there are several rare events in which we need to "stop the world" -
latch all queues, to prevent any activity inside lock-sys.
One way to accomplish this would be to simply latch all the shards one by one,
but it turns out to be way too slow in debug runs, where such "stop the world"
events are very frequent due to lock_sys validation.

To allow for efficient latching of everything, we've introduced a global_latch,
which is a read-write latch.
Most of the time, we operate on one or two shards, in which case it is
sufficient to s-latch the global_latch and then latch shard's mutex.
For the "stop the world" operations, we x-latch the global_latch, which prevents
any other thread from latching any shard.

However, it turned out that on ARM architecture, the default implementation of
read-write latch (rw_lock_t) is too slow because increments and decrements of
the number of s-latchers is implemented as read-update-try-to-write loop, which
means multiple threads try to modify the same cache line disrupting each other.
Therefore, we use a sharded version of read-write latch (Sharded_rw_lock), which
internally uses multiple instances of rw_lock_t, spreading the load over several
cache lines. Note that this sharding is a technical internal detail of the
global_latch, which for all other purposes can be treated as a single entity.

This his how this conceptually looks like:
```
  [                           global latch                                ]
                                  |
                                  v
  [table shard 1] ... [table shard 512] [page shard 1] ... [page shard 512]

```

So, for example access two queues for two records involves following steps:
1. s-latch the global_latch
2. identify the 2 pages to which the records belong
3. identify the lock_sys 2 hash buckets which contain the queues for given pages
4. identify the 2 shard ids which contain these two buckets
5. latch mutexes for the two shards in the order of their addresses

All of the steps above (except 2, as we usually know the page already) are
accomplished with the help of single line:

    locksys::Shard_latches_guard guard{*block_a, *block_b};

And to "stop the world" one can simply x-latch the global latch by using:

    locksys::Global_exclusive_latch_guard guard{};

This class does not expose too many public functions, as the intention is to
rather use friend guard classes, like the Shard_latches_guard demonstrated.
*/
class Latches {
private:
        using Lock_mutex = ib_mutex_t;
        
        using Padded_mutex = ut::Cacheline_padded<Lock_mutex>;

        /** Number of page shards, and also number of table shards.
        Must be a power of two */
        static constexpr size_t SHARDS_COUNT = 512;
        /** padding to prevent other memory update hotspots from residing on the same
        memory cache line */
        char pad1[ut::INNODB_CACHE_LINE_SIZE] = {};

        Unique_sharded_rw_lock global_latch;

        Page_shards page_shards;

        Table_shards table_shards;

public:
        /* You should use following RAII guards to modify the state of Latches. */
        friend class Global_exclusive_latch_guard;
        friend class Global_exclusive_try_latch;
        friend class Global_shared_latch_guard;
        friend class Shard_naked_latch_guard;
        friend class Shard_naked_latches_guard;
};                
```