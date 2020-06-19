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

##3.3 Fil_shard::open_file

```cpp
 2520   if (file->size == 0 ||
 2521       (space->size_in_header == 0 && space->purpose == FIL_TYPE_TABLESPACE &&
 2522        file == &space->files.front()
 2523 #ifndef UNIV_HOTBACKUP
 2524        && undo::is_active(space->id, false) &&
 2525        srv_startup_is_before_trx_rollback_phase
 2526 #endif /* !UNIV_HOTBACKUP */
 2527        )) {
 2528
 2529     /* We don't know the file size yet. */
 2530     dberr_t err = get_file_size(file, read_only_mode);
 2531
 2532     if (err != DB_SUCCESS) {
 2533       return (false);
 2534     }
 2535   }
```

##3.4 Fil_shard::meb_extend_tablespaces_to_stored_len(backup ignore)

```cpp
size_in_header = fsp_header_get_field(buf, FSP_SIZE);
success = space_extend(space, size_in_header);
```

##3.5 fsp_header_init

```cpp
space->size_in_header = size
```

##3.6 fsp_header_inc_size

```cpp
  size = mach_read_from_4(header + FSP_SIZE);
#ifndef ENABLED_GAIADB
  ut_ad(size == space->size_in_header);
#endif /* ENABLED_GAIADB */
  size += size_inc;

  fsp_header_size_update(header, size, mtr);
  space->size_in_header = size;
```

##3.7 fsp_header_get_tablespace_size

```cpp
  header = fsp_get_space_header(TRX_SYS_SPACE, univ_page_size, &mtr);

  page_no_t size;

  size = mach_read_from_4(header + FSP_SIZE);
#ifndef ENABLED_GAIADB
  ut_ad(space->size_in_header == size);
#endif /* ENABLED_GAIADB */
return (size);
```

##3.8 fsp_try_extend_data_file_with_pages

```cpp
  page_no_t size = mach_read_from_4(header + FSP_SIZE);
#ifndef ENABLED_GAIADB
  ut_ad(size == space->size_in_header);
#endif /* ENABLED_GAIADB */

  ut_a(page_no >= size);

  bool success = fil_space_extend(space, page_no + 1);

  /* The size may be less than we wanted if we ran out of disk space. */
  fsp_header_size_update(header, space->size, mtr);
  space->size_in_header = space->size;
```

##3.9 fsp_try_extend_data_file

```cpp
  size = mach_read_from_4(header + FSP_SIZE);
#ifndef ENABLED_GAIADB
  ut_ad(size == space->size_in_header);
#endif /* ENABLED_GAIADB */


    page_no_t extent_pages = fsp_get_extent_size_in_pages(page_size);
    if (size < extent_pages) {
      /* Let us first extend the file to extent_size */
      if (!fsp_try_extend_data_file_with_pages(space, extent_pages - 1, header,
                                               mtr)) {
        return false;
      }

      size = extent_pages;
    }

    size_increase = fsp_get_pages_to_extend_ibd(page_size, size);
    
  if (!fil_space_extend(space, size + size_increase)) {
    return false;
  }

  /* We ignore any fragments of a full megabyte when storing the size
  to the space header */

  space->size_in_header =
      ut_calc_align_down(space->size, (1024 * 1024) / page_size.physical());

  fsp_header_size_update(header, space->size_in_header, mtr);    
```

##3.10 fsp_fill_free_list

```cpp
size = mach_read_from_4(header + FSP_SIZE);

  if (size < limit + FSP_EXTENT_SIZE * FSP_FREE_ADD) {
    if ((!init_space && !fsp_is_system_tablespace(space->id) &&
         !fsp_is_global_temporary(space->id)) ||
        (space->id == TRX_SYS_SPACE &&
         srv_sys_space.can_auto_extend_last_file()) ||
        (fsp_is_global_temporary(space->id) &&
         srv_tmp_space.can_auto_extend_last_file())) {
      fsp_try_extend_data_file(space, header, mtr);
      size = space->size_in_header;
    }
  }
```

##3.11 fsp_alloc_free_page











--------------------
todo

###gaia无法保证
space->size_in_header == mach_read_from_4(sp_header + FSP_SIZE);

###space->size

