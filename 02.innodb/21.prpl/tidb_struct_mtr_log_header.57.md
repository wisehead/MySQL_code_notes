#1.struct mtr_log_header

```cpp
#define mtr_log_header  mtr_log_header_v1
```

#2.struct mtr_log_header_v1

```cpp
struct mtr_log_header_v1 {
    /* log lsn : high 4 bits are log version */
    union {
        uint64_t    _lsn_bytes;
        struct {
            uint64_t    _lsn:60;
            uint64_t    _version:4;
        };
    };

    /* low 4 bytes of page lsn before modification */
    uint32_t    _prev_lsn;
    uint32_t    _lsn_len:24;
    uint32_t    _rec_len:24;
    uint32_t    _cpl_len:24;

    /* Currently only support up to 16 spaces */
    union {
        uint8_t     _space_byte;
        struct {
            uint8_t     _space:4;
            uint8_t     _reserve:2;
            uint8_t     _applied_flag:1;
            uint8_t     _mtr_end_flag:1;
        };
    };
    uint32_t    _page;
};
```