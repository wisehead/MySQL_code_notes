#1.lock_object_name

```cpp
bool lock_object_name(THD *thd, MDL_key::enum_mdl_namespace mdl_type,const char
 *db, const char *name)
{
    MDL_request_list mdl_requests;
    MDL_request global_request;
    MDL_request schema_request;
    MDL_request mdl_request;
...
//构造加锁请求。加锁请求，体现了SQL语句的封锁意愿，以及并发情况下，是否存在其他加锁意愿时需要构
 造不同的加锁请求
    MDL_REQUEST_INIT(&global_request,
   //为global_request锁请求在GLOBAL空间内申请语句级的意向排它锁
                      MDL_key::GLOBAL, "", "", MDL_INTENTION_EXCLUSIVE,MDL_STATEMENT);
    MDL_REQUEST_INIT(&schema_request,  //为schema_request锁请求在SCHEMA空间内申请事
    务级的意向排它锁
                      MDL_key::SCHEMA, db, "", MDL_INTENTION_EXCLUSIVE,MDL_TRANSACTION);
    MDL_REQUEST_INIT(&mdl_request,     //为mdl_request锁请求在参数mdl_type空间内申请
    事务级的排它锁
                     mdl_type, db, name, MDL_EXCLUSIVE,MDL_TRANSACTION);
    mdl_requests.push_front(&mdl_request);
    mdl_requests.push_front(&schema_request);
    mdl_requests.push_front(&global_request); //把新的加锁请求放到链表的前端
    if (thd->mdl_context.acquire_locks(&mdl_requests,
    //在会话thd对象的元数据锁上下文（MDL_context）空间内获取准备施加的锁
                                       thd->variables.lock_wait_timeout))
                                       //设置超时等待
        return TRUE;
...
}
```