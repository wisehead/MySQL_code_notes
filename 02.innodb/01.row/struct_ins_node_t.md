#1.struct ins_node_t

```cpp
/* Insert node structure */

struct ins_node_t{
	que_common_t	common;	/*!< node type: QUE_NODE_INSERT */
	ulint		ins_type;/* INS_VALUES, INS_SEARCHED, or INS_DIRECT */
	dtuple_t*	row;	/*!< row to insert */
	dict_table_t*	table;	/*!< table where to insert */
	sel_node_t*	select;	/*!< select in searched insert */
	que_node_t*	values_list;/* list of expressions to evaluate and
				insert in an INS_VALUES insert */
	ulint		state;	/*!< node execution state */
	dict_index_t*	index;	/*!< NULL, or the next index where the index
				entry should be inserted */
	dtuple_t*	entry;	/*!< NULL, or entry to insert in the index;
				after a successful insert of the entry,
				this should be reset to NULL */
	UT_LIST_BASE_NODE_T(dtuple_t)
			entry_list;/* list of entries, one for each index */
	byte*		row_id_buf;/* buffer for the row id sys field in row */
	trx_id_t	trx_id;	/*!< trx id or the last trx which executed the
				node */
	byte*		trx_id_buf;/* buffer for the trx id sys field in row */
	mem_heap_t*	entry_sys_heap;
				/* memory heap used as auxiliary storage;
				entry_list and sys fields are stored here;
				if this is NULL, entry list should be created
				and buffers for sys fields in row allocated */
	ulint		magic_n;
};
```