#1. class DDL_Operation

```cpp
class DDL_Operation
{
public:
        char    db_name[NAME_LEN + 1];
        char    obj_name[NAME_LEN + 1];
        MDL_key::enum_mdl_namespace mdl_type;
        lsn_t   cur_lsn;

        UT_LIST_NODE_T(DDL_Operation) ddl_opr_node;
};
```