#1.dfield_t

```cpp
/** Structure for an SQL data field */
struct dfield_t{
    void*       data;   /*!< pointer to data */
    unsigned    ext:1;  /*!< TRUE=externally stored, FALSE=local */
    unsigned    len:32; /*!< data length; UNIV_SQL_NULL if SQL null */
    dtype_t     type;   /*!< type of data */
};
```