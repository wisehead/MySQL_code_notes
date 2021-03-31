#1.ib_mutex_t

这是innodb用的最多的mutex，现在是SysMutex。

```cpp
#ifdef MUTEX_FUTEX
/** The default mutex type. */
typedef FutexMutex ib_mutex_t;
typedef BlockFutexMutex ib_bpmutex_t;
#define MUTEX_TYPE      "Uses futexes"
#elif defined(MUTEX_SYS)
typedef SysMutex ib_mutex_t;
typedef BlockSysMutex ib_bpmutex_t;
#define MUTEX_TYPE      "Uses system mutexes"
#elif defined(MUTEX_EVENT)
typedef SyncArrayMutex ib_mutex_t;
typedef BlockSyncArrayMutex ib_bpmutex_t;
#define MUTEX_TYPE      "Uses event mutexes"
#else
#error "ib_mutex_t type is unknown"
#endif /* MUTEX_FUTEX */
```

#2. SysMutex

https://www.mwat.de/docs/CPP/sync-api/classdfg_1_1Synchronizer.html#dfg_1_1Synchronizerx2

```cpp
typedef ::pthread_mutex_t	sysMutex
```