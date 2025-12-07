#1.Page_shards

```cpp
        /*
        Functions related to sharding by page (containing records to lock).

        This must be done in such a way that two pages which share a single lock
        queue fall into the same shard. We accomplish this by reusing hash function
        used to determine lock queue, and then group multiple queues into single
        shard.
        */
        class Page_shards {
                /** Each shard is protected by a separate mutex. Mutexes are padded to avoid
                false sharing issues with cache. */
                Padded_mutex mutexes[SHARDS_COUNT];
                /**
                Identifies the page shard which contains record locks for records from the
                given page.
                @param[in]    page_id    The space_id and page_no of the page
                @return Integer in the range [0..lock_sys_t::SHARDS_COUNT)
                */
                static size_t get_shard(const page_id_t &page_id);

        public:
                Page_shards();
                ~Page_shards();

                /**
                Returns the mutex which (together with the global latch) protects the page
                shard which contains record locks for records from the given page.
                @param[in]    page_id    The space_id and page_no of the page
                @return The mutex responsible for the shard containing the page
                */
                const Lock_mutex &get_mutex(const page_id_t &page_id) const;

                /**
                Returns the mutex which (together with the global latch) protects the page
                shard which contains record locks for records from the given page.
                @param[in]    page_id    The space_id and page_no of the page
                @return The mutex responsible for the shard containing the page
                */
                Lock_mutex &get_mutex(const page_id_t &page_id);
        };

```

#2. get_mutex

```cpp

size_t Latches::Page_shards::get_shard(const page_id_t &page_id) {
  /* We always use lock_rec_hash regardless of the exact type of the lock.
  It may happen that the lock is a predicate lock, in which case,
  it would make more sense to use hash_calc_hash with proper hash table
  size. The current implementation works, because the size of all three
  hashmaps is always the same. This allows an interface with less arguments.
  */
  ut_ad(lock_sys->rec_hash->n_cells == lock_sys->prdt_hash->n_cells);
  ut_ad(lock_sys->rec_hash->n_cells == lock_sys->prdt_page_hash->n_cells);
  return lock_rec_hash(page_id) % SHARDS_COUNT;
}

const Lock_mutex &Latches::Page_shards::get_mutex(
    const page_id_t &page_id) const {
  return mutexes[get_shard(page_id)];
}

Lock_mutex &Latches::Page_shards::get_mutex(const page_id_t &page_id) {
  /* See "Effective C++ item 3: Use const whenever possible" for explanation of
  this pattern, which avoids code duplication by reusing const version. */
  return const_cast<Lock_mutex &>(
      const_cast<const Latches::Page_shards *>(this)->get_mutex(page_id));
}
```