#1.dict_col_sys_tables_enum

```cpp

/* The columns in SYS_TABLES */
enum dict_col_sys_tables_enum {
    DICT_COL__SYS_TABLES__NAME      = 0,
    DICT_COL__SYS_TABLES__ID        = 1,
    DICT_COL__SYS_TABLES__N_COLS        = 2,
    DICT_COL__SYS_TABLES__TYPE      = 3,
    DICT_COL__SYS_TABLES__MIX_ID        = 4,
    DICT_COL__SYS_TABLES__MIX_LEN       = 5,
    DICT_COL__SYS_TABLES__CLUSTER_ID    = 6,
    DICT_COL__SYS_TABLES__SPACE     = 7,
    DICT_NUM_COLS__SYS_TABLES       = 8
};
```

#2.dict_fld_sys_tables_enum

```cpp
/* The field numbers in the SYS_TABLES clustered index */
enum dict_fld_sys_tables_enum {
    DICT_FLD__SYS_TABLES__NAME      = 0,
    DICT_FLD__SYS_TABLES__DB_TRX_ID     = 1,
    DICT_FLD__SYS_TABLES__DB_ROLL_PTR   = 2,
    DICT_FLD__SYS_TABLES__ID        = 3,
    DICT_FLD__SYS_TABLES__N_COLS        = 4,
    DICT_FLD__SYS_TABLES__TYPE      = 5,
    DICT_FLD__SYS_TABLES__MIX_ID        = 6,
    DICT_FLD__SYS_TABLES__MIX_LEN       = 7,
    DICT_FLD__SYS_TABLES__CLUSTER_ID    = 8,
    DICT_FLD__SYS_TABLES__SPACE     = 9,
    DICT_NUM_FIELDS__SYS_TABLES     = 10
};
```