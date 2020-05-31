#1.btr_pcur_t

```cpp
/* The persistent B-tree cursor structure. This is used mainly for SQL
selects, updates, and deletes. */

struct btr_pcur_t{
    btr_cur_t   btr_cur;    /*!< a B-tree cursor */
    ulint       latch_mode; /*!< see TODO note below!
                    BTR_SEARCH_LEAF, BTR_MODIFY_LEAF,
                    BTR_MODIFY_TREE, or BTR_NO_LATCHES,
                    depending on the latching state of
                    the page and tree where the cursor is
                    positioned; BTR_NO_LATCHES means that
                    the cursor is not currently positioned:
                    we say then that the cursor is
                    detached; it can be restored to
                    attached if the old position was
                    stored in old_rec */
    ulint       old_stored; /*!< BTR_PCUR_OLD_STORED
                    or BTR_PCUR_OLD_NOT_STORED */
    rec_t*      old_rec;    /*!< if cursor position is stored,
                    contains an initial segment of the
                    latest record cursor was positioned
                    either on, before, or after */
    ulint       old_n_fields;   /*!< number of fields in old_rec */
    ulint       rel_pos;    /*!< BTR_PCUR_ON, BTR_PCUR_BEFORE, or
                    BTR_PCUR_AFTER, depending on whether
                    cursor was on, before, or after the
                    old_rec record */
    buf_block_t*    block_when_stored;/* buffer block when the position was
                    stored */
    ib_uint64_t modify_clock;   /*!< the modify clock value of the
                    buffer block when the cursor position
                    was stored */
    enum pcur_pos_t pos_state;  /*!< btr_pcur_store_position() and
                    btr_pcur_restore_position() state. */
    ulint       search_mode;    /*!< PAGE_CUR_G, ... */
    trx_t*      trx_if_known;   /*!< the transaction, if we know it;
                    otherwise this field is not defined;
                    can ONLY BE USED in error prints in
                    fatal assertion failures! */
    /*-----------------------------*/
    /* NOTE that the following fields may possess dynamically allocated
    memory which should be freed if not needed anymore! */

    byte*       old_rec_buf;    /*!< NULL, or a dynamically allocated
                    buffer for old_rec */
    ulint       buf_size;   /*!< old_rec_buf size if old_rec_buf
                    is not NULL */
};

```