#1.struct fil_space_t

```cpp
/** Tablespace or log data space */
struct fil_space_t {
  using List_node = UT_LIST_NODE_T(fil_space_t);
  using Files = std::vector<fil_node_t, ut_allocator<fil_node_t>>;

  /** Tablespace name */
  char *name;

  /** Tablespace ID */
  space_id_t id;

  /** true if we want to rename the .ibd file of tablespace and
  want to stop temporarily posting of new i/o requests on the file */
  bool stop_ios;

  /** We set this true when we start deleting a single-table
  tablespace.  When this is set following new ops are not allowed:
  * read IO request
  * ibuf merge
  * file flush
  Note that we can still possibly have new write operations because we
  don't check this flag when doing flush batches. */
  bool stop_new_ops;

#ifdef UNIV_DEBUG
  /** Reference count for operations who want to skip redo log in
  the file space in order to make fsp_space_modify_check pass. */
  ulint redo_skipped_count;
#endif /* UNIV_DEBUG */

  /** Purpose */
  fil_type_t purpose;

  /** Files attached to this tablespace. Note: Only the system tablespace
  can have multiple files, this is a legacy issue. */
  Files files;

  /** Tablespace file size in pages; 0 if not known yet */
  page_no_t size;

  /** FSP_SIZE in the tablespace header; 0 if not known yet */
  page_no_t size_in_header;

  /** Length of the FSP_FREE list */
  uint32_t free_len;

  /** Contents of FSP_FREE_LIMIT */
  page_no_t free_limit;

  /** Tablespace flags; see fsp_flags_is_valid() and
  page_size_t(ulint) (constructor).
  This is protected by space->latch and tablespace MDL */
  uint32_t flags;

  /** Number of reserved free extents for ongoing operations like
  B-tree page split */
  uint32_t n_reserved_extents;

  /** This is positive when flushing the tablespace to disk;
  dropping of the tablespace is forbidden if this is positive */
  uint32_t n_pending_flushes;

  /** This is positive when we have pending operations against this
  tablespace. The pending operations can be ibuf merges or lock
  validation code trying to read a block.  Dropping of the tablespace
  is forbidden if this is positive.  Protected by Fil_shard::m_mutex. */
  uint32_t n_pending_ops;

#ifndef UNIV_HOTBACKUP
  /** Latch protecting the file space storage allocation */
  rw_lock_t latch;
#endif /* !UNIV_HOTBACKUP */

  /** List of spaces with at least one unflushed file we have
  written to */
  List_node unflushed_spaces;

  /** true if this space is currently in unflushed_spaces */
  bool is_in_unflushed_spaces;

  /** Compression algorithm */
  Compression::Type compression_type;

  /** Encryption algorithm */
  Encryption::Type encryption_type;

  /** Encrypt key */
  byte encryption_key[ENCRYPTION_KEY_LEN];

  /** Encrypt key length*/
  ulint encryption_klen;

  /** Encrypt initial vector */
  byte encryption_iv[ENCRYPTION_KEY_LEN];

  /** Encryption is in progress */
  encryption_op_type encryption_op_in_progress;

  /** Release the reserved free extents.
  @param[in]    n_reserved  number of reserved extents */
  void release_free_extents(ulint n_reserved);

  /** FIL_SPACE_MAGIC_N */
  ulint magic_n;
  /** System tablespace */
  static fil_space_t *s_sys_space;

  /** Redo log tablespace */
  static fil_space_t *s_redo_space;

#ifdef UNIV_DEBUG
  /** Print the extent descriptor pages of this tablespace into
  the given output stream.
  @param[in]    out the output stream.
  @return   the output stream. */
  std::ostream &print_xdes_pages(std::ostream &out) const;

  /** Print the extent descriptor pages of this tablespace into
  the given file.
  @param[in]    filename    the output file name. */
  void print_xdes_pages(const char *filename) const;
#endif /* UNIV_DEBUG */
};    
```

#2 Files

```cpp
using Files = std::vector<fil_node_t, ut_allocator<fil_node_t>>;
```