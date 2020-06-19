#1. fsp_reserve_free_extents

```cpp
btr_cur_pessimistic_insert
--fsp_reserve_free_extents
--fil_space_release_free_extents
```


#2.Fil_shard::space_create

```cpp
srv_start
--SysTablespace::open_or_create
----gaia_fil_space_create
------Fil_shard::space_create
```


#3.space->size_in_header
```cpp
in fsp_try_extend_data_file()
...
  /* We ignore any fragments of a full megabyte when storing the size
  to the space header */

  space->size_in_header =
      ut_calc_align_down(space->size, (1024 * 1024) / page_size.physical());

```

##3.1 innobase_get_tablespace_statistics(ignore)

```cpp
stats->m_total_extents = space->size_in_header / extent_pages;
```

##3.2 Fil_shard::get_file_size

```cpp
page_no_t size = fsp_header_get_field(page, FSP_SIZE);
space->size_in_header = size;
```

##3.3

```cpp

```












#5.fsp_header_init

```cpp
fsp_header_init
--space->size_in_header = size;
```

#6.space->size and space->size_in_header

