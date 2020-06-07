

# [MySQL的“线程私有数据”]

#### 函数 / 单线程 / 多线程

单线程环境下，全局变量可以实现所有函数间共享数据

多线程环境下，全局变量可以实现所有线程（每个线程内所有函数）间共享数据

我们希望在多线程环境下，某个变量只能由**指定线程的所有函数**共享，这个变量是全局变量？不行，那么所有线程就都可以共享了。所以，这个变量是“线程私有的全局变量”，叫做**线程私有数据**（Thread Specific Data，TSD）

实现方式参考[linux 多线程编程 Thread Specific Data (TSD)](http://blog.csdn.net/kennyrose/article/details/7603325)和[pthread\_key\_t和pthread\_key\_create()详解](https://www.jianshu.com/p/d52c1ebf808a)

```plain
// 1. 创建一个Key
pthread_key_t RPL_MASTER_INFO
pthread_key_create(RPL_MASTER_INFO)
  
// 2. 每个线程将自身的私有变量（mi）与Key关联
Thread(i)
{
  Master_info* mi
  pthread_setspcific(RPL_MASTER_INFO)
}
  
// 3. 每个线程将得到自身的私有变量（mi）
Thread(i)
{
  Master_info* my_own_mi = (Master_info*)pthread_getspecific(RPL_MASTER_INFO)
}
```

可以看出，一个Key只能关联一个私有变量

设想一个Key关联多个私有变量，那么在pthread\_getspecific(RPL\_MASTER\_INFO)时无法返回多个结果…

#### 举例

```plain
/**
  Slave IO thread entry point.
 
  @param arg Pointer to Master_info struct that holds information for
  the IO thread.
 
  @return Always 0.
*/
pthread_handler_t handle_slave_io(void *arg)
{
  ...
  // 设置mi（master_info）为线程全局变量
  // 1）因为mi只是这个连接中使用CHANGE MASTER设置的，只对这个连接有意义
  // 2）这个连接中还有其他函数可能需要访问mi
  my_pthread_setspecific_ptr(RPL_MASTER_INFO, mi);
  ...
}
```

## 记一次调试历程

**在InnoDB中直接引用THD**，当MySQL/InnoDB启动后，MySQL和InnoDB的网络分别监听端口9988/9987，向端口9987（InnoDB网络）发送测试数据：

```plain
echo "Hello World" | nc 127.0.0.1 9987
```

MySQL出现core dump，分析core文件发现调用栈指出my\_thread\_var为**空指针**

```plain
// new THD时会调用如下函数
void thr_lock_info_init(THR_LOCK_INFO *info)
{
  struct st_my_thread_var *tmp= my_thread_var;
  // tmp是空指针
  info->thread=    tmp->pthread_self;
  info->thread_id= tmp->id;
}
// my_thread_var指向函数_my_thread_var
struct st_my_thread_var *_my_thread_var(void)
{
  if (THR_KEY_mysys_initialized)
    return  my_pthread_getspecific(struct st_my_thread_var*,THR_KEY_mysys);
  return NULL;
}
```

由my\_pthread\_setspecific\_ptr识别出这里使用的是**线程私有数据**机制，而**线程私有数据**的典型使用方式是：

1.  **pthread\_key\_create**
2.  **pthread\_setspcific** （对应到MySQL里是my\_pthread\_setspecific\_ptr）
3.  **pthread\_getspecific**（对应到MySQL里是my\_pthread\_getspecific）

注意到\_my\_thread\_var里会调用函数my\_pthread\_getspecific，而在此前没有使用my\_pthread\_setspecific\_ptr，所以会导致my\_pthread\_getspecific得到的是空值

解决方案是需要在thr\_lock\_info\_init之前使用my\_pthread\_setspecific\_ptr，分析MySQL Server的代码发现，在初始化THD对象之前，会调用my\_thread\_init函数

```plain
my_thread_init // 分配线程私有的内存区域
 |-set_mysys_var
   |-my_pthread_setspecific_ptr // 设置线程私有的"全局变量"
```
