#1.pfs_spawn_thread

```cpp
pfs_spawn_thread
--find_thread_class
--create_thread
--clear_thread_account
--set_thread_account
----find_or_create_account
------get_account_hash_pins
------set_account_key
------lf_hash_search
--(*user_start_routine)(user_arg);///* Then, execute the user code for this thread. */
--handle_one_connection
```