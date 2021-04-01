#1.mysql_mutex_init

```cpp
//include/mysql/psi/mysql_thread.h

/**
  @def mysql_mutex_init(K, M, A)
  Instrumented mutex_init.
  @c mysql_mutex_init is a replacement for @c pthread_mutex_init.
  @param K The PSI_mutex_key for this instrumented mutex
  @param M The mutex to initialize
  @param A Mutex attributes
*/

#ifdef HAVE_PSI_MUTEX_INTERFACE
  #ifdef SAFE_MUTEX
    #define mysql_mutex_init(K, M, A) \
      inline_mysql_mutex_init(K, M, A, __FILE__, __LINE__)
  #else
    #define mysql_mutex_init(K, M, A) \
      inline_mysql_mutex_init(K, M, A)
  #endif
#else
  #ifdef SAFE_MUTEX
    #define mysql_mutex_init(K, M, A) \
      inline_mysql_mutex_init(M, A, __FILE__, __LINE__)
  #else
    #define mysql_mutex_init(K, M, A) \
      inline_mysql_mutex_init(M, A)
  #endif
#endif
```

#2. inline_mysql_mutex_init

```cpp
static inline int inline_mysql_mutex_init(
#ifdef HAVE_PSI_MUTEX_INTERFACE
  PSI_mutex_key key,
#endif
  mysql_mutex_t *that,
  const native_mutexattr_t *attr
#ifdef SAFE_MUTEX
  , const char *src_file, uint src_line
#endif
  )
{
#ifdef HAVE_PSI_MUTEX_INTERFACE
  that->m_psi= PSI_MUTEX_CALL(init_mutex)(key, &that->m_mutex);
#else
  that->m_psi= NULL;
#endif
  return my_mutex_init(&that->m_mutex, attr
#ifdef SAFE_MUTEX
                       , src_file, src_line
#endif
                       );
}

```

#3.my_mutex_init

```cpp
160 static inline int my_mutex_init(my_mutex_t *mp, const native_mutexattr_t *attr
161 #ifdef SAFE_MUTEX
162                                 , const char *file, uint line
163 #endif
164                                 )
165 {
166 #ifdef SAFE_MUTEX
167   return safe_mutex_init(mp, attr, file, line);
168 #else
169   return native_mutex_init(mp, attr);
170 #endif
171 }
```

#4.native_mutex_init

```cpp
 67 static inline int native_mutex_init(native_mutex_t *mutex,
 68                                     const native_mutexattr_t *attr)
 69 {
 70 #ifdef _WIN32
 71   InitializeCriticalSection(mutex);
 72   return 0;
 73 #else
 74   return pthread_mutex_init(mutex, attr);
 75 #endif
 76 }
```