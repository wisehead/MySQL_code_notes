#1.join_read_const//JT_CONST

```
make_join_statistics
--join_read_const_table
----join_read_const
```

#2.comments
```cpp
/**
  Read a constant table when there is at most one matching row, using an
  index lookup.

  @param tab            Table to read

  @retval 0  Row was found
  @retval -1 Row was not found
  @retval 1  Got an error (other than row not found) during read
*/
```