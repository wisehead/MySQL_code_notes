#1.class Filesort_info

```cpp
class Filesort_info
{
  /// Buffer for sorting keys.
  Filesort_buffer filesort_buffer;

public:
  IO_CACHE *io_cache;           /* If sorted through filesort */
  uchar     *buffpek;           /* Buffer for buffpek structures */
  uint      buffpek_len;        /* Max number of buffpeks in the buffer */
  uchar     *addon_buf;         /* Pointer to a buffer if sorted with fields */
  size_t    addon_length;       /* Length of the buffer */
  struct st_sort_addon_field *addon_field;     /* Pointer to the fields info */
  void    (*unpack)(struct st_sort_addon_field *, uchar *); /* To unpack back */
  uchar     *record_pointers;    /* If sorted in memory */
  ha_rows   found_records;      /* How many records in sort */

  Filesort_info(): record_pointers(0) {};
  /** Sort filesort_buffer */
  void sort_buffer(Sort_param *param, uint count)
  { filesort_buffer.sort_buffer(param, count); }

  /**
     Accessors for Filesort_buffer (which @c).
  */
  uchar *get_record_buffer(uint idx)
  { return filesort_buffer.get_record_buffer(idx); }

  uchar **get_sort_keys()
  { return filesort_buffer.get_sort_keys(); }

  uchar **alloc_sort_buffer(uint num_records, uint record_length)
  { return filesort_buffer.alloc_sort_buffer(num_records, record_length); }

  void free_sort_buffer()
  { filesort_buffer.free_sort_buffer(); }

  void init_record_pointers()
  { filesort_buffer.init_record_pointers(); }

  size_t sort_buffer_size() const
  { return filesort_buffer.sort_buffer_size(); }
};

```