#1.struct trx_undo_ptr_t

```cpp

/** Represents an instance of rollback segment along with its state variables.*/
struct trx_undo_ptr_t {
	trx_rseg_t*	rseg;		/*!< rollback segment assigned to the
					transaction, or NULL if not assigned
					yet */
	trx_undo_t*	insert_undo;	/*!< pointer to the insert undo log, or
					NULL if no inserts performed yet */
	trx_undo_t*	update_undo;	/*!< pointer to the update undo log, or
					NULL if no update performed yet */
};
```