#1.os_cond_t = pthread_cond_t

```cpp

typedef pthread_cond_t          os_cond_t;


```

#2.os_cond相关函数接口，mysql5.6

该接口5.7已经不用了，全部封装为os_event_t。

```cpp
/*
在文件os0sync.cc中，os_cond_XXX类似的函数就是InnoDB对Pthread库的封装。
常用的几个函数如： os_cond_t是核心的操作对象，其实就是pthread_cond_t 的一层typedef 而已，os_cond_init初始化函数，os_cond_destroy销毁函数，os_cond_wait条件等待，不会超时，os_cond_wait_timed条件等待，如果超时则返回，os_cond_broadcast唤醒所有等待线程，os_cond_signal只唤醒其中一个等待线程，但是在阅读源码的时候发现，似乎没有什么地方调用了os_cond_signal……

此外，还有一个os_cond_module_init函数，用来window下的初始化操作。 在InnoDB 下，os_cond_XXX模块的函数主要是给InnoDB自己设计的条件变量使用。
*/
```
