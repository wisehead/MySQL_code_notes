#1.do_command
```cpp
caller:
--do_handle_one_connection

/**
  Read one command from connection and execute it (query or simple command).
  This function is called in loop from thread function.

  For profiling to work, it must never be called recursively.

  @retval
    0  success
  @retval
    1  request of thread shutdown (see dispatch_command() description)
*/
do_command
--my_net_read
--command= (enum enum_server_command) (uchar) packet[0];
--dispatch_command
```