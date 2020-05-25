#1.MACRO REC_HEADER
##1.1 New/Compact

```cpp
New/Compact

Old


```

##1.2 Old
```cpp
New/Compact

Old


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