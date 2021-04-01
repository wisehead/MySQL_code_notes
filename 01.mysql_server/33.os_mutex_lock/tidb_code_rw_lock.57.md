#1.rw_lock

```cpp
/**
  @def mysql_rwlock_init(K, RW)
  Instrumented rwlock_init.
  @c mysql_rwlock_init is a replacement for @c pthread_rwlock_init.
  Note that pthread_rwlockattr_t is not supported in MySQL.
  @param K The PSI_rwlock_key for this instrumented rwlock
  @param RW The rwlock to initialize
*/
#ifdef HAVE_PSI_RWLOCK_INTERFACE
  #define mysql_rwlock_init(K, RW) inline_mysql_rwlock_init(K, RW)
#else
  #define mysql_rwlock_init(K, RW) inline_mysql_rwlock_init(RW)
#endif
```

#2. inline_mysql_rwlock_init

```cpp
static inline int inline_mysql_rwlock_init(
#ifdef HAVE_PSI_RWLOCK_INTERFACE
  PSI_rwlock_key key,
#endif
  mysql_rwlock_t *that)
{
#ifdef HAVE_PSI_RWLOCK_INTERFACE
  that->m_psi= PSI_RWLOCK_CALL(init_rwlock)(key, &that->m_rwlock);
#else
  that->m_psi= NULL;
#endif
  return native_rw_init(&that->m_rwlock);
}
```

#3.native_rw_init

```cpp
static inline int native_rw_init(native_rw_lock_t *rwp)
{
#ifdef _WIN32
  InitializeSRWLock(&rwp->srwlock);
  rwp->have_exclusive_srwlock = FALSE;
  return 0;
#else
  /* pthread_rwlockattr_t is not used in MySQL */
  return pthread_rwlock_init(rwp, NULL);
#endif
}
```