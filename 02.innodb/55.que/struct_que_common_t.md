#1.struct que_common_t

```cpp
struct que_common_t{
    ulint       type;   /*!< query node type */
    que_node_t* parent; /*!< back pointer to parent node, or NULL */
    que_node_t* brother;/* pointer to a possible brother node */
    dfield_t    val;    /*!< evaluated value for an expression */
    ulint       val_buf_size;
                /* buffer size for the evaluated value data,
                if the buffer has been allocated dynamically:
                if this field is != 0, and the node is a
                symbol node or a function node, then we
                have to free the data field in val
                explicitly */
};

```