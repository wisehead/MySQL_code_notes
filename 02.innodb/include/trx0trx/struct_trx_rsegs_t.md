#1.struct trx_rsegs_t

```cpp
/** Rollback segments assigned to a transaction for undo logging. */
struct trx_rsegs_t {
	/** undo log ptr holding reference to a rollback segment that resides in
	system/undo tablespace used for undo logging of tables that needs
	to be recovered on crash. */
	trx_undo_ptr_t	m_redo;

	/** undo log ptr holding reference to a rollback segment that resides in
	temp tablespace used for undo logging of tables that doesn't need
	to be recovered on crash. */
	trx_undo_ptr_t	m_noredo;
};
```