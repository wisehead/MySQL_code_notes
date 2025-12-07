#1.Table_shards

```cpp
        /*
        Functions related to sharding by table

        We identify tables by their id. Each table has its own lock queue, so we
        simply group several such queues into single shard.
        */
        class Table_shards {
                /** Each shard is protected by a separate mutex. Mutexes are padded to avoid
                false sharing issues with cache. */
                Padded_mutex mutexes[SHARDS_COUNT];
                /**
                Identifies the table shard which contains locks for the given table.
                @param[in]    table     The table
                @return Integer in the range [0..lock_sys_t::SHARDS_COUNT)
                */
                static size_t get_shard(const dict_table_t &table);

        public:
                Table_shards();
                ~Table_shards();

                /** Returns the mutex which (together with the global latch) protects the
                table shard which contains table locks for the given table.
                @param[in]    table     The table
                @return The mutex responsible for the shard containing the table
                */
                Lock_mutex &get_mutex(const dict_table_t &table);

                /** Returns the mutex which (together with the global latch) protects the
                table shard which contains table locks for the given table.
                @param[in]    table     The table
                @return The mutex responsible for the shard containing the table
                */
                const Lock_mutex &get_mutex(const dict_table_t &table) const;
        };
```


#2. get_mutex

```cpp
size_t Latches::Table_shards::get_shard(const dict_table_t &table) {
  return table.id % SHARDS_COUNT;
}

const Lock_mutex &Latches::Table_shards::get_mutex(
    const dict_table_t &table) const {
  return mutexes[get_shard(table)];
}

Lock_mutex &Latches::Table_shards::get_mutex(const dict_table_t &table) {
  /* See "Effective C++ item 3: Use const whenever possible" for explanation of
  this pattern, which avoids code duplication by reusing const version. */
  return const_cast<Lock_mutex &>(
      const_cast<const Latches::Table_shards *>(this)->get_mutex(table));
}
```