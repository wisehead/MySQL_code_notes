#1.ncdb_acquire_mdl

```cpp
ncdb_acquire_mdl
--Global_THD_manager *thd_manager= Global_THD_manager::get_instance();
--MDL_REQUEST_INIT(&mdl_request,mdl_type, db, object_name,MDL_EXCLUSIVE, MDL_EXPLICIT);
--thd->mdl_context.try_acquire_lock(&mdl_request)
--while (!ret && mdl_request.ticket == NULL)
----for (uint i= 0; i < thd_manager->thd_list.size(); i++)
------THD* tmp_thd= thd_manager->thd_list.at(i);
------if (tmp_thd !=thd && tmp_thd->mdl_context.find_conflict(&mdl_request, &type) != NULL)
--------tmp_thd->awake(THD::KILL_CONNECTION);
----ret= thd->mdl_context.acquire_lock(&mdl_request, thd->variables.lock_wait_timeout);//killed and retry.
--if (mdl_request.ticket != NULL && mdl_type == MDL_key::TABLE)
----*need_evict= true;
----tdc_remove_table(thd, TDC_RT_REMOVE_ALL, db, object_name, false);	
```