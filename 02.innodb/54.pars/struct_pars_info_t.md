#1.pars_info_t

```cpp
/** Extra information supplied for pars_sql(). */
struct pars_info_t {
    mem_heap_t* heap;       /*!< our own memory heap */

    ib_vector_t*    funcs;      /*!< user functions, or NUll
                    (pars_user_func_t*) */
    ib_vector_t*    bound_lits; /*!< bound literals, or NULL
                    (pars_bound_lit_t*) */
    ib_vector_t*    bound_ids;  /*!< bound ids, or NULL
                    (pars_bound_id_t*) */

    ibool       graph_owns_us;  /*!< if TRUE (which is the default),
                    que_graph_free() will free us */
};
```