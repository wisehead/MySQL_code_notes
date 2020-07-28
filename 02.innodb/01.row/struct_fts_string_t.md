#1.struct fts_string_t

```cpp
/** An UTF-16 ro UTF-8 string. */
struct fts_string_t {
  byte *f_str;    /*!< string, not necessary terminated in
                  any way */
  ulint f_len;    /*!< Length of the string in bytes */
  ulint f_n_char; /*!< Number of characters */
};
```