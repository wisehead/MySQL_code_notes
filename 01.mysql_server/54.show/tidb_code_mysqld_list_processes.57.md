#1.mysqld_list_processes


```cpp
mysqld_list_processes
--List_process_list list_process_list(user, &thread_infos, thd,max_query_length);
--Global_THD_manager::get_instance()->do_for_all_thd_copy(&list_process_list);
----THD_array thd_list_copy(thd_list);
----std::for_each(thd_list_copy.begin(), thd_list_copy.end(), doit);
------list_process_list()// operator function.


```