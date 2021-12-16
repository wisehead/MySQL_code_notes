#1.struct prpl_slot_t

```cpp
/** Data structure of hash table's bucket in prpl mode.
A slot is one-one correspondence to a page in one log group
links all redo records to one page whithin that log group
            |- (prpl_slot_t) - rpl_rec_t ... rpl_rec_t
hash table -|- (prpl_slot_t) - rpl_rec_t ... rpl_rec_t
            |- (prpl_slot_t) - rpl_rec_t ... rpl_rec_t */
struct prpl_slot_t {
  /** processsed state of the page */
  recv_addr_state state;

  /** Space ID */
  ulint space;

  /** Page number */
  ulint page_no;

        /* List node, for details see Prpl_Worker::m_slots */
        UT_LIST_NODE_T(prpl_slot_t) node;

  /** Based node of redo log records list for one single page */
  UT_LIST_BASE_NODE_T(rpl_rec_t) rec_list;
};

```