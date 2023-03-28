#1.thread_pool::add_task

```
thread_pool::add_task
--auto task = std::make_shared<std::packaged_task<typename std::result_of<F(Args...)>::type()>>(
        std::bind(std::forward<F>(f), std::forward<Args>(args)...));
--auto res = task->get_future();
--tasks_.emplace([task]() { (*task)(); });
--condition_.notify_one();
```