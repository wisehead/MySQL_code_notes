#1.ib_trx_start

```cpp
ib_trx_start
--trx->api_trx = true;
--trx->api_auto_commit = auto_commit;
--trx->read_write = read_write;
--trx_start_if_not_started
--trx->isolation_level = ib_trx_level;
--trx->mysql_thd = static_cast<THD*>(thd); 
```

#2.caller

```cpp
- ib_trx_begin
- 
```