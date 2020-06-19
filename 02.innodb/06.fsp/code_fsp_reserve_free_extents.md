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
fsp_try_extend_data_file
```

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

```cpp
  space_size = mach_read_from_4(header + FSP_SIZE);
  if (space_size <= page_no) {
    /* It must be that we are extending a single-table tablespace
    whose size is still < 64 pages */

    if (!fsp_try_extend_data_file_with_pages(fspace, page_no, header, mtr)) {
      /* No disk space left */
      return (NULL);
    }
  }  
```

##3.12 fsp_reserve_free_extents

```cpp
try_again:
  size = mach_read_from_4(space_header + FSP_SIZE);
#ifndef ENABLED_GAIADB
  ut_ad(size == space->size_in_header);
#endif /* ENABLED_GAIADB */

  if (size < FSP_EXTENT_SIZE && n_pages < FSP_EXTENT_SIZE / 2) {
    /* Use different rules for small single-table tablespaces */
    *n_reserved = 0;
    return fsp_reserve_free_pages(space, space_header, size, mtr, n_pages);
  }
```

##3.13 fsp_get_available_space_in_free_extents

```cpp
ulint size_in_header = space->size_in_header;
  /* Below we play safe when counting free extents above the free limit:
  some of them will contain extent descriptor pages, and therefore
  will not be free extents */
  ut_ad(size_in_header >= space->free_limit);
  ulint n_free_up = (size_in_header - space->free_limit) / FSP_EXTENT_SIZE;

  page_size_t page_size(space->flags);
  if (n_free_up > 0) {
    n_free_up--;
    n_free_up -= n_free_up / (page_size.physical() / FSP_EXTENT_SIZE);
  }

  /* We reserve 1 extent + 0.5 % of the space size to undo logs
  and 1 extent + 0.5 % to cleaning operations; NOTE: this source
  code is duplicated in the function above! */

  ulint reserve = 2 + ((size_in_header / FSP_EXTENT_SIZE) * 2) / 200;
  ulint n_free = space->free_len + n_free_up;
```

##3.14 recv_parse_or_apply_log_rec_body

```cpp
          case FSP_HEADER_OFFSET + FSP_SPACE_FLAGS:
          case FSP_HEADER_OFFSET + FSP_SIZE:
          case FSP_HEADER_OFFSET + FSP_FREE_LIMIT:
          case FSP_HEADER_OFFSET + FSP_FREE + FLST_LEN:

            space = fil_space_get(space_id);

            ut_a(space != nullptr);

            val = mach_read_from_4(page + offs);

            switch (offs) {
              case FSP_HEADER_OFFSET + FSP_SPACE_FLAGS:
                space->flags = val;
                break;

              case FSP_HEADER_OFFSET + FSP_SIZE:

                space->size_in_header = val;

                if (space->size >= val) {
                  break;
                }
```



#4.space->size

##4.1 Fil_shard::validate

```cpp
  for (auto elem : m_spaces) {
    page_no_t size = 0;
    auto space = elem.second;

    for (const auto &file : space->files) {
      ut_a(file.is_open || !file.n_pending);

      if (file.is_open) {
        ++n_open;
      }

      size += file.size;
    }

    ut_a(space->size == size);
  }
```

##4.2 Fil_shard::create_node

```cpp
  space->size += size;

  space->files.push_back(file);
```

##4.3 Fil_shard::get_file_size(backup ignore)

```cpp
#ifdef UNIV_HOTBACKUP
  if (space->id == TRX_SYS_SPACE) {
    file->size = (ulint)(size_bytes / UNIV_PAGE_SIZE);
    space->size += file->size;
    os_file_close(file->handle);
    return (DB_SUCCESS);
  }
#endif /* UNIV_HOTBACKUP */
```

##4.4 Fil_shard::get_file_size

```cpp
  if (file->size == 0) {
    ulint extent_size;

    extent_size = page_size.physical() * FSP_EXTENT_SIZE;

#ifndef UNIV_HOTBACKUP
    /* Truncate the size to a multiple of extent size. */
    if (size_bytes >= extent_size) {
      size_bytes = ut_2pow_round(size_bytes, extent_size);
    }
#else /* !UNIV_HOTBACKUP */

    /* After apply-incremental, tablespaces are not
    extended to a whole megabyte. Do not cut off
    valid data. */

#endif /* !UNIV_HOTBACKUP */

    file->size = static_cast<page_no_t>(size_bytes / page_size.physical());

    space->size += file->size;
  }
```

##4.5 Fil_shard::space_free_low

```cpp
#ifdef ENABLED_GAIADB
  if (fsp_is_system_temporary(space->id)) {
#endif /* ENABLED_GAIADB */
    for (auto &file : space->files) {
      ut_d(space->size -= file.size);

      os_event_destroy(file.sync_event);

      ut_free(file.name);
    }

    call_destructor(&space->files);
    ut_ad(space->size == 0);

#ifdef ENABLED_GAIADB
  }
#endif /* ENABLED_GAIADB */
```


##4.6 gaia_fil_space_create

```cpp
fil_space_t *gaia_fil_space_create(const char *name, space_id_t space_id,
                              uint32_t flags, fil_type_t purpose, page_no_t size) {
    fil_space_t* space = fil_space_create(name, space_id, flags, purpose);
    space->size = size;
    return space;
}
```

##4.7 Fil_shard::space_load

```cpp
  if (space == nullptr || space->size != 0) {
    return (space);
  }
```

##4.8 fil_space_get_size

```cpp
page_no_t size = space ? space->size : 0;
```

##4.9 Fil_shard::space_truncate

```cpp
space->size = file.size = size_in_pages;
bool success = os_file_truncate(file.name, file.handle, 0);
```

##4.10 Fil_shard::gaia_space_extend

gaiaDB的space->size 是用来管理所有gaiadb的size，需要考虑space->size_in_header的关系？？？？
另外看下，独立表空间size的变化情况。和size_in_header怎么协调？？？

```
/** Try to extend a gaia tablespace if it is smaller than the specified size.
@param[in,out]  space       tablespace
@param[in]  size        desired size in pages
@return whether the tablespace is at least as big as requested */
bool Fil_shard::gaia_space_extend(fil_space_t *space, page_no_t size) {
  /* In read-only mode we allow write to shared temporary tablespace
  as intrinsic table created by Optimizer reside in this tablespace. */
  ut_ad(!srv_read_only_mode && !fsp_is_system_temporary(space->id));

  bool slot = false;
  bool success = true;
  page_no_t extend_size;
  int ret = 0;

  slot = mutex_acquire_and_get_space(space->id, space);

  ut_a(space->size > 0);

  extend_size = size - space->size;

  extend_size = MAPPING_SIZE(extend_size);

  ut_ad(0 == space->size % FSP_MAPPING_SIZE);
  ut_ad(0 == extend_size % FSP_MAPPING_SIZE);
  ret = srv_psmgr_client->extend_space(space->id, space->size / FSP_MAPPING_SIZE,
                                       extend_size / FSP_MAPPING_SIZE);
  ib::info(ER_IB_MSG_1240) << "extend space->id:" << space->id << " space->size:"
  << space->size / FSP_MAPPING_SIZE << " extend_size:" << extend_size / FSP_MAPPING_SIZE;
  if (ret < 0) {
    ib::error(ER_IB_MSG_1240) << "extend space failed:" << ret;
    success = false;
  }

  if (slot) {
    release_open_slot(m_id);
  }

  if (success) {
    space->size += extend_size;
    ut_ad(0 == space->size % FSP_MAPPING_SIZE);
  }

  mutex_release();

  return (success);
}
```

##11.Fil_shard::space_extend（not for gaia）
//拓展文件操作

```cpp
    if (size < space->size) {
      /* Space already big enough */
      mutex_release();

      if (slot) {
        release_open_slot(m_id);
      }

      return (true);
    }
  
  file->size += pages_added;
  space->size += pages_added;
  
  //更新相应的元信息。
  if (space->id == TRX_SYS_SPACE) {
    srv_sys_space.set_last_file_size(size_in_pages);
  } else if (fsp_is_system_temporary(space->id)) {
    srv_tmp_space.set_last_file_size(size_in_pages);
  }
```


##12.fsp_try_extend_data_file_with_pages

size_in_header 根据 space->size更新

```
caller:
--fseg_alloc_free_page_low
--fsp_try_extend_data_file

fsp_try_extend_data_file_with_pages
--fil_space_extend
----Fil_shard::gaia_space_extend//shard->gaia_space_extend//更新space->size
----Fil_shard::space_extend
------posix_fallocate(file->handle.m_file, node_start, len);
------srv_sys_space.set_last_file_size(size_in_pages)
```

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

##13.











--------------------
todo

###gaia无法保证
space->size_in_header == mach_read_from_4(sp_header + FSP_SIZE);

###space->size

