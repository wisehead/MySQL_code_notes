#1.struct trx_rseg_t

```cpp
/** The rollback segment memory object */
struct trx_rseg_t {
    ulint    id;      //回滚段的标识
...
    ulint    space;   //回滚段的头信息在表空间中的位置，表空间标识
    ulint    page_no; //回滚段的头信息在表空间中的位置，页号
    page_size_t    page_size; /** page size of the relevant tablespace */
    ulint          max_size; /** maximum allowed size in pages */
    ulint          curr_size; /** current size in pages */
...
    /** 执行UPDATE操作产生的UODO日志，包括先删除后插入的过程中产生的UODO信息，事务完成，信息
    依然被保留，用于MVCC机制下的一致性读  */
    UT_LIST_BASE_NODE_T(trx_undo_t)    update_undo_list;    /** List of update
     undo logs */
    UT_LIST_BASE_NODE_T(trx_undo_t)    update_undo_cached;/** List of update undo
    log segments cached for fast reuse */
    /* 执行INSERT操作产生的UODO日志，这些信息是临时的，事务结束后就被清理 */
    UT_LIST_BASE_NODE_T(trx_undo_t) insert_undo_list;/** List of insert undo logs */
    UT_LIST_BASE_NODE_T(trx_undo_t) insert_undo_cached;    /** List of insert
     undo log segments cached for fast reuse */
...
};



/** The rollback segment memory object */
struct trx_rseg_t {
	/*--------------------------------------------------------*/
	/** rollback segment id == the index of its slot in the trx
	system file copy */
	ulint				id;

	/** mutex protecting the fields in this struct except id,space,page_no
	which are constant */
	RsegMutex			mutex;

	/** space where the rollback segment header is placed */
	ulint				space;

	/** page number of the rollback segment header */
	ulint				page_no;

	/** page size of the relevant tablespace */
	page_size_t			page_size;

	/** maximum allowed size in pages */
	ulint				max_size;

	/** current size in pages */
	ulint				curr_size;

	/*--------------------------------------------------------*/
	/* Fields for update undo logs */
	/** List of update undo logs */
	UT_LIST_BASE_NODE_T(trx_undo_t)	update_undo_list;

	/** List of update undo log segments cached for fast reuse */
	UT_LIST_BASE_NODE_T(trx_undo_t)	update_undo_cached;

	/*--------------------------------------------------------*/
	/* Fields for insert undo logs */
	/** List of insert undo logs */
	UT_LIST_BASE_NODE_T(trx_undo_t) insert_undo_list;

	/** List of insert undo log segments cached for fast reuse */
	UT_LIST_BASE_NODE_T(trx_undo_t) insert_undo_cached;

	/*--------------------------------------------------------*/

	/** Page number of the last not yet purged log header in the history
	list; FIL_NULL if all list purged */
	ulint				last_page_no;

	/** Byte offset of the last not yet purged log header */
	ulint				last_offset;

	/** Transaction number of the last not yet purged log */
	trx_id_t			last_trx_no;

	/** TRUE if the last not yet purged log needs purging */
	ibool				last_del_marks;

	/** Reference counter to track rseg allocated transactions. */
	ulint				trx_ref_count;

	/** If true, then skip allocating this rseg as it reside in
	UNDO-tablespace marked for truncate. */
	bool				skip_allocation;
};

```