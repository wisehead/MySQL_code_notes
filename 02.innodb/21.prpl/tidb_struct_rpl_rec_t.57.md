#1.struct rpl_rec_t

```cpp
/* Stored log record struct */
struct rpl_rec_t {
        byte*           data;
        ulint           len;
        bool            multi_page;
        UT_LIST_NODE_T(rpl_rec_t)
                        rec_list;
};
```