#1.class Sharded_rw_lock

```cpp
/** Rw-lock with very fast, highly concurrent s-lock but slower x-lock.
It's basically array of rw-locks. When s-lock is being acquired, single
rw-lock from array is selected randomly and s-locked. Therefore, all
rw-locks from array has to be x-locked when x-lock is being acquired.

Purpose of this data structure is to reduce contention on single atomic
in single rw-lock when a lot of threads need to acquire s-lock very often,
but x-lock is very rare. */
class Sharded_rw_lock {
 public:
  void create(mysql_pfs_key_t pfs_key, latch_level_t latch_level,
              size_t n_shards) {
    m_n_shards = n_shards;

    m_shards = static_cast<Shard *>(ut_zalloc_nokey(sizeof(Shard) * n_shards));

    for_each([pfs_key, latch_level](rw_lock_t &lock) {
      static_cast<void>(latch_level);  // clang -Wunused-lambda-capture
      rw_lock_create(pfs_key, &lock, latch_level);
    });
  }

  void free() {
    ut_a(m_shards != nullptr);

    for_each([](rw_lock_t &lock) { rw_lock_free(&lock); });

    ut_free(m_shards);
    m_shards = nullptr;
    m_n_shards = 0;
  }

  ulint s_lock() {
    const size_t shard_no = ut_rnd_interval(0, m_n_shards - 1);
    rw_lock_s_lock(&m_shards[shard_no]);
    return (ulint)shard_no;
  }

  ibool s_lock_nowait(size_t &shard_no, const char *file, ulint line) {
    shard_no = ut_rnd_interval(0, m_n_shards - 1);
    return rw_lock_s_lock_nowait(&m_shards[shard_no], file, line);
  }

  void s_unlock(size_t shard_no) {
    ut_a(shard_no < m_n_shards);
    rw_lock_s_unlock(&m_shards[shard_no]);
  }

  /**
  Tries to obtain exclusive latch - similar to x_lock(), but non-blocking, and
  thus can fail.
  @return true iff succeeded to acquire the exclusive latch
  */
  bool try_x_lock() {
    for (size_t shard_no = 0; shard_no < m_n_shards; ++shard_no) {
      if (!rw_lock_x_lock_nowait(&m_shards[shard_no])) {
        while (0 < shard_no--) {
          rw_lock_x_unlock(&m_shards[shard_no]);
        }
        return (false);
      }
    }
    return (true);
  }

  void x_lock() {
    for_each([](rw_lock_t &lock) { rw_lock_x_lock(&lock); });
  }
 void x_unlock() {
    for_each([](rw_lock_t &lock) { rw_lock_x_unlock(&lock); });
  }

#ifdef UNIV_DEBUG
  bool s_own(size_t shard_no) const {
    return rw_lock_own(&m_shards[shard_no], RW_LOCK_S);
  }

  bool x_own() const { return rw_lock_own(&m_shards[0], RW_LOCK_X); }
#endif /* !UNIV_DEBUG */

private:
  using Shard = ut::Cacheline_padded<rw_lock_t>;

  template <typename F>
  void for_each(F f) {
    std::for_each(m_shards, m_shards + m_n_shards, f);
  }

  Shard *m_shards = nullptr;

  size_t m_n_shards = 0;
};  
```