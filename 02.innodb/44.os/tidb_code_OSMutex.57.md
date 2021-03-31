#1.OSMutex

os_event用的是这个event

```cpp
#ifndef UNIV_INNOCHECKSUM
/** OS mutex, without any policy. It is a thin wrapper around the
system mutexes. The interface is different from the policy mutexes,
to ensure that it is called directly and not confused with the
policy mutexes. */
struct OSMutex {

        /** Constructor */
        OSMutex()
                UNIV_NOTHROW
        {
                ut_d(m_freed = true);
        }

        /** Create the mutex by calling the system functions. */
        void init()
                UNIV_NOTHROW
        {
                ut_ad(m_freed);

#ifdef _WIN32
                InitializeCriticalSection((LPCRITICAL_SECTION) &m_mutex);
#else
                {
                        int     ret = pthread_mutex_init(&m_mutex, NULL);
                        ut_a(ret == 0);
                }
#endif /* _WIN32 */

                ut_d(m_freed = false);
        }
        /** Destroy the mutex */
        void destroy()
                UNIV_NOTHROW
        {
                ut_ad(innodb_calling_exit || !m_freed);
#ifdef _WIN32
                DeleteCriticalSection((LPCRITICAL_SECTION) &m_mutex);
#else
                int     ret;

                ret = pthread_mutex_destroy(&m_mutex);

                if (ret != 0) {

                        ib::error()
                                << "Return value " << ret << " when calling "
                                << "pthread_mutex_destroy().";
                }
#endif /* _WIN32 */
                ut_d(m_freed = true);
        }
private:
#ifdef UNIV_DEBUG
        /** true if the mutex has been freed/destroyed. */
        bool                    m_freed;
#endif /* UNIV_DEBUG */

        sys_mutex_t             m_mutex;
};                
```

#2. os_mutex_t mysql5.6

```cpp
/*
系统互斥锁
相比与系统条件变量，系统互斥锁除了包装Pthread库外，还做了一层简单的监控统计，结构名为os_mutex_t。在文件os0sync.cc中，os_mutex_create创建mutex，并调用os_fast_mutex_init_func创建pthread的mutex，值得一提的是，创建pthread mutex的参数是my_fast_mutexattr的东西，其在MySQL server层函数my_thread_global_init初始化 ，只要pthread库支持，则默认成初始化为PTHREAD_MUTEX_ADAPTIVE_NP和PTHREAD_MUTEX_ERRORCHECK。前者表示，当锁释放，之前在等待的锁进行公平的竞争，而不是按照默认的优先级模式。后者表示，如果发生了递归的加锁，即同一个线程对同一个锁连续加锁两次，第二次加锁会报错。另外三个有用的函数为，销毁锁os_mutex_free，加锁os_mutex_enter，解锁os_mutex_exit。

一般来说，InnoDB 上层模块不需要直接与系统互斥锁打交道，需要用锁的时候一般用InnoDB 自己实现的一套互斥锁。系统互斥锁主要是用来辅助实现一些数据结构，例如最后一节提到的一些辅助结构，由于这些辅助结构可能本身就要提供给InnoDB 自旋互斥锁用，为了防止递归引用，就暂时用系统互斥锁来代替。
*/
```