#1.innodb_buffer_pool_filename_basic.test

```
innodb_buffer_pool_filename_basic.test
--SET @orig = @@global.innodb_buffer_pool_filename;
--SELECT variable_value FROM information_schema.global_status WHERE LOWER(variable_name) = 'innodb_buffer_pool_dump_status';
--SET GLOBAL innodb_buffer_pool_filename = 'innodb_foobar_dump';
--SET GLOBAL innodb_buffer_pool_dump_now = ON

```