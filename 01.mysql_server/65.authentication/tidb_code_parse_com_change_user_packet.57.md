#1.parse_com_change_user_packet


```cpp
parse_com_change_user_packet
--protocol = mpvio->protocol
--user= (char*) protocol->get_net()->read_pos
--passwd= strend(user) + 1;
--user_len= copy_and_convert(user_buff, sizeof(user_buff) - 1,system_charset_info, user, user_len,mpvio->charset_adapter->charset(),&dummy_errors);
--mpvio->auth_info.user_name= my_strndup(key_memory_MPVIO_EXT_auth_info,user_buff, user_len, MYF(MY_WME))
--

```

#2.caller

```cpp
acl_authenticate
```