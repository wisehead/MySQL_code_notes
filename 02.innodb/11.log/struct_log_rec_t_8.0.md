#1.log_rec_t

```cpp
/* simplified one used in page server */
struct log_rec_t {
  enum muti_flag_t  mflag;
  mlog_id_t   type;
  space_id_t  space_id;
  page_no_t   page_no;
  /* record body */
  byte       *body;
  ulint       body_len;
  /* record start lsn */
  lsn_t     start_lsn;
  // record's end lsn, could be rewrite as page's last modified record lsn
  lsn_t     end_lsn;
  UT_LIST_NODE_T(log_rec_t) rec_list;
};
```