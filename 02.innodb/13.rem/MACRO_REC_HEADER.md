#1.MACRO REC_HEADER

```cpp
/* We list the byte offsets from the origin of the record, the mask,
and the shift needed to obtain each bit-field of the record. */

#define REC_NEXT        2
#define REC_NEXT_MASK       0xFFFFUL
#define REC_NEXT_SHIFT      0

#define REC_OLD_SHORT       3   /* This is single byte bit-field */
#define REC_OLD_SHORT_MASK  0x1UL
#define REC_OLD_SHORT_SHIFT 0

#define REC_OLD_N_FIELDS    4
#define REC_OLD_N_FIELDS_MASK   0x7FEUL
#define REC_OLD_N_FIELDS_SHIFT  1

#define REC_NEW_STATUS      3   /* This is single byte bit-field */
#define REC_NEW_STATUS_MASK 0x7UL
#define REC_NEW_STATUS_SHIFT    0

#define REC_OLD_HEAP_NO     5
#define REC_HEAP_NO_MASK    0xFFF8UL
#if 0 /* defined in rem0rec.h for use of page0zip.cc */
#define REC_NEW_HEAP_NO     4
#define REC_HEAP_NO_SHIFT   3
#endif

#define REC_OLD_N_OWNED     6   /* This is single byte bit-field */
#define REC_NEW_N_OWNED     5   /* This is single byte bit-field */
#define REC_N_OWNED_MASK    0xFUL
#define REC_N_OWNED_SHIFT   0

#define REC_OLD_INFO_BITS   6   /* This is single byte bit-field */
#define REC_NEW_INFO_BITS   5   /* This is single byte bit-field */
#define REC_INFO_BITS_MASK  0xF0UL
#define REC_INFO_BITS_SHIFT 0


```

#2. REC_N_NEW_EXTRA_BYTES

```cpp
/* Number of extra bytes in an old-style record,
in addition to the data and the offsets */
#define REC_N_OLD_EXTRA_BYTES   6
/* Number of extra bytes in a new-style record,
in addition to the data and the offsets */
#define REC_N_NEW_EXTRA_BYTES   5
```

#3. REC_OFFS_HEADER_SIZE

```cpp
#ifdef UNIV_DEBUG
/* Length of the rec_get_offsets() header */
# define REC_OFFS_HEADER_SIZE   4
#else /* UNIV_DEBUG */
/* Length of the rec_get_offsets() header */
# define REC_OFFS_HEADER_SIZE   2
#endif /* UNIV_DEBUG */
```

#4.INFO

```cpp
//每个rec可以找到下一条record。
#define REC_NEXT        2
```
