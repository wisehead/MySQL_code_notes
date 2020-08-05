#1.enum btr_op_t

```cpp
/** Buffered B-tree operation types, introduced as part of delete buffering. */
enum btr_op_t {
    BTR_NO_OP = 0,          /*!< Not buffered */                                                                                                                                                                                                                
    BTR_INSERT_OP,          /*!< Insert, do not ignore UNIQUE */
    BTR_INSERT_IGNORE_UNIQUE_OP,    /*!< Insert, ignoring UNIQUE */
    BTR_DELETE_OP,          /*!< Purge a delete-marked record */
    BTR_DELMARK_OP          /*!< Mark a record for deletion */
}; 
```