#1.os_rmb

```cpp
//storage/innobase/include/os0atomic.h

/** barrier definitions for memory ordering */
#ifdef HAVE_IB_GCC_ATOMIC_THREAD_FENCE
# define HAVE_MEMORY_BARRIER
# define os_rmb __atomic_thread_fence(__ATOMIC_ACQUIRE)
# define os_wmb __atomic_thread_fence(__ATOMIC_RELEASE)
# define IB_MEMORY_BARRIER_STARTUP_MSG \
        "GCC builtin __atomic_thread_fence() is used for memory barrier"

#elif defined(HAVE_IB_GCC_SYNC_SYNCHRONISE)
# define HAVE_MEMORY_BARRIER
# define os_rmb __sync_synchronize()
# define os_wmb __sync_synchronize()
# define IB_MEMORY_BARRIER_STARTUP_MSG \
        "GCC builtin __sync_synchronize() is used for memory barrier"

#elif defined(HAVE_IB_MACHINE_BARRIER_SOLARIS)
# define HAVE_MEMORY_BARRIER
# include <mbarrier.h>
# define os_rmb __machine_r_barrier()
# define os_wmb __machine_w_barrier()
# define IB_MEMORY_BARRIER_STARTUP_MSG \
        "Solaris memory ordering functions are used for memory barrier"

#elif defined(HAVE_WINDOWS_MM_FENCE) && defined(_WIN64)
# define HAVE_MEMORY_BARRIER
# include <mmintrin.h>
# define os_rmb _mm_lfence()
# define os_wmb _mm_sfence()
# define IB_MEMORY_BARRIER_STARTUP_MSG \
        "_mm_lfence() and _mm_sfence() are used for memory barrier"

#else
# define os_rmb
# define os_wmb
# define IB_MEMORY_BARRIER_STARTUP_MSG \
        "Memory barrier is not used"
#endif

```

#2.notes

```
关于内存屏障的专门指令，MySQL 5.7提供的比较完善。os_rmb表示acquire barrier，os_wmb表示release barrier。

如果在编程时，需要在某个位置准确的读取一个变量的值时，记得在读取之前加上os_rmb，同理，如果需要在某个位置保证一个变量已经被写了，记得在写之后调用os_wmb。
```