#1. rw_lock_t

```cpp
InnoDB 读写锁
与条件变量、互斥锁不同，InnoDB 里面没有Pthread 库的读写锁的包装，其完全依赖依赖于原子操作和InnoDB 的条件变量，甚至都不需要依赖InnoDB 的自旋互斥锁。此外，读写锁还实现了写操作的递归锁，即同一个线程可以多次获得写锁，但是同一个线程依然不能同时获得读锁和写锁。InnoDB 读写锁的核心数据结构rw_lock_t中，并没有等待队列的信息，因此不能保证先到的请求一定会先进入临界区。这与系统互斥量用PTHREAD_MUTEX_ADAPTIVE_NP来初始化有异曲同工之妙。

InnoDB 读写锁的核心实现在源文件sync0rw.cc 和sync0rw.ic 中，核心数据结构rw_lock_t 定义在sync0rw.h 中。使用方法与InnoDB 自旋互斥锁很类似，只不过读请求和写请求要调用不同的函数。加读锁调用rw_lock_s_lock, 加写锁调用rw_lock_x_lock，释放读锁调用rw_lock_s_unlock, 释放写锁调用rw_lock_x_unlock，创建读写锁调用rw_lock_create，释放读写锁调用rw_lock_free。函数rw_lock_x_lock_nowait和rw_lock_s_lock_nowait表示，当加读写锁失败的时候，直接返回，而不是自旋等待。

核心机制
rw_lock_t 中，核心的成员有以下几个：lock_word, event, waiters, wait_ex_event，writer_thread, recursive。

与InnoDB 自旋互斥锁的lock_word 不同，rw_lock_t 中的lock_word 是int 型，注意不是unsigned 的，其取值范围是(-2*X_LOCK_DECR, X_LOCK_DECR]，其中X_LOCK_DECR为0x00100000，差不多100多W的一个数。在InnoDB 自旋互斥锁互斥锁中，lock_word 的取值范围只有0，1，因为这两个状态就能把互斥锁的所有状态都表示出来了，也就是说，只需要查看一下这个lock_word 就能确定当前的线程是否能获得锁。rw_lock_t 中的lock_word 也扮演了相同的角色，只需要查看一下当前的lock_word 落在哪个取值范围中，就确定当前线程能否获得锁。至于rw_lock_t 中的lock_word 是如何做到这一点的，这其实是InnoDB 读写锁乃至InnoDB 同步机制中最神奇的地方，下文我们会详细分析。

event 是一个InnoDB 条件变量，当当前的锁已经被一个线程以写锁方式独占时，后续的读锁和写锁都等待在这个event 上，当这个线程释放写锁时，等待在这个event 上的所有读锁和写锁同时竞争。waiters 这变量，与event 一起用，当有等待者在等待时，这个变量被设置为1，否则为0，锁被释放的时候，需要通过这个变量来判断有没有等待者从而执行os_event_set。

与InnoDB 自旋互斥锁不同，InnoDB 读写锁还有wait_ex_event 和recursive 两个变量。wait_ex_event 也是一个InnoDB 条件变量，但是它用来等待第一个写锁（因为写请求可能会被先前的读请求堵住），当先前到达的读请求都读完了，就会通过这个event 来唤醒这个写锁的请求。

由于InnoDB 读写锁实现了写锁的递归，因此需要保存当前写锁被哪个线程占用了，后续可以通过这个值来判断是否是这个线程的写锁请求，如果是则加锁成功，否则失败，需要等待。线程的id就保存在writer_thread 这个变量中。

recursive 是个bool 变量，用来表示当前的读写锁是否支持递归写模式，在某些情况下，例如需要另外一个线程来释放这个读写锁（insert buffer需要这个功能）的时候，就不要开启递归模式了。

接下来，我们来详细介绍一下lock_word 的变化规则：

当有一个读请求加锁成功时，lock_word 原子递减1。
当有一个写请求加锁成功时，lock_word 原子递减X_LOCK_DECR。
如果读写锁支持递归写，那么第一个递归写锁加锁成功时，lock_word 依然原子递减X_LOCK_DECR，而后续的递归写锁加锁成功是，lock_word 只是原子递减1。
在上述的变化规则约束下，lock_word 会形成以下几个区间：

lock_word == X_LOCK_DECR	表示锁空闲，即当前没有线程获得了这个锁
0 < lock_word < X_LOCK_DECR	表示当前有X_LOCK_DECR - lock_word个读锁
lock_word == 0	表示当前有一个写锁
-X_LOCK_DECR < lock_word < 0	表示当前有-lock_word个读锁，他们还没完成，同时后面还有一个写锁在等待
lock_word <= -X_LOCK_DECR	表示当前处于递归锁模式，同一个线程加了2 - (lock_word + X_LOCK_DECR)次写锁
另外，还可以得出以下结论

由于lock_word 的范围被限制（rw_lock_validate）在(-2*X_LOCK_DECR, X_LOCK_DECR]中，结合上述规则，可以推断出，一个读写锁最多能加X_LOCK_DECR个读锁。在开启递归写锁的模式下，一个线程最多同时加X_LOCK_DECR+1个写锁。
在读锁释放之前，lock_word 一定处于(-X_LOCK_DECR, 0)U(0, X_LOCK_DECR)这个范围内。
在写锁释放之前，lock_word 一定处于(-2*X_LOCK_DECR, -X_LOCK_DECR]或者等于0这个范围内。
只有在lock_word 大于0的情况下才可以对它递减。有一个例外，就是同一个线程需要加递归写锁的时候，lock_word 可以在小于0的情况下递减。
接下来，举个读写锁加锁的例子，方便读者理解读写锁底层加锁的原理。 假设有读写加锁请求按照以下顺序依次到达：R1->R2->W1->R3->W2->W3->R4，其中W2和W3是属于同一个线程的写加锁请求，其他所有读写请求均来自不同线程。初始化后，lock_word 的值为X_LOCK_DECR（十进制值为1048576）。R1读加锁请求首先到，其发现lock_word 大于0，表示可以加读锁，同时lock_word 递减1，结果为1048575，R2读加锁请求接着来到，发现lock_word 依然大于0，继续加读锁并递减lock_word，最终结果为1048574。注意，如果R1和R2几乎是同时到达，即使时序上是R1先请求，但是并不保证R1首先递减，有可能是R2首先拿到原子操作的执行权限。如果在R1或者R2释放锁之前，写加锁请求W1到来，他发现lock_word 依旧大于0，于是递减X_LOCK_DECR，并把自己的线程id记录在writer_thread这个变量里，再检查lock_word 的值（此时为-2），由于结果小于0，表示前面有未完成的读加锁请求，于是其等待在wait_ex_event这个条件变量上。后续的R3, W2, W3, R4请求发现lock_word 小于0，则都等待在条件变量event上，并且设置waiter为1，表示有等待者。假设R1先释放读锁(lock_word 递增1)，R2后释放(lock_word 再次递增1)。R2释放后，由于lock_word 变为0了，其会在wait_ex_event上调用os_event_set，这样W3就被唤醒了，他可以执行临界区内的代码了。W3执行完后，lock_word 被恢复为X_LOCK_DECR，然后其发现waiter为1，表示在其后面有新的读写加锁请求在等待，然后在event上调用os_event_set，这样R3, W2, W3, R4同时被唤醒，进行原子操作执行权限争抢(可以简单的理解为谁先得到cpu调度)。假设W2首先抢到了执行权限，其会把lock_word 再次递减为0并自己的线程id记录在writer_thread这个变量里，当检查lock_word 的时候，发现值为0，表示前面没有读请求了，于是其就进入临界区执行代码了。假设此时，W3得到了cpu的调度，由于lock_word 只有在大于0的情况下才能递减，所以其递减lock_word 失败，但是其通过对比writer_thread和自己的线程id，发现前面的写锁是自己加的，如果这个时候开启了递归写锁，即recursive值为true，他把lock_word 再次递减X_LOCK_DECR（现在lock_word 变为-X_LOCK_DECR了），然后进入临界区执行代码。这样就保证了同一个线程多次加写锁也不发生死锁，也就是递归锁的概念。后续的R3和R4发现lock_word 小于等于0，就直接等待在event条件变量上，并设置waiter为1。直到W2和W3都释放写锁，lock_word 又变为X_LOCK_DECR，最后一个释放的，检查waiter变量发现非0，就会唤醒event上的所有等待者，于是R3和R4就可以执行了。

读写锁的核心函数函数结构跟InnoDB自旋互斥锁的基本相同，主要的区别就是用rw_lock_x_lock_low和rw_lock_s_lock_low替换了__sync_lock_test_and_set原子操作。rw_lock_x_lock_low和rw_lock_s_lock_low就按照上述的lock_word 的变化规则来原子的改变（依然使用了__sync_lock_test_and_set）lock_word 这个变量。

在MySQL 5.7中，读写锁除了可以加读锁(Share lock)请求和加写锁(exclusive lock)请求外，还可以加share exclusive 锁请求，锁兼容性如下：

 LOCK COMPATIBILITY MATRIX
    S   SX  X
 S  +   +   -
 SX +   -   -
 X  -   -   -
按照WL#6363的说法，是为了修复index->lock 这个锁的冲突。

```