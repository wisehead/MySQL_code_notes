#1.Prpl_Worker::apply

```cpp
caller is : Prpl_Worker::run()

Prpl_Worker::apply
--while (UT_LIST_GET_LEN(m_slots) != 0)
----slot = UT_LIST_GET_FIRST(m_slots);
----while (slot != NULL && UT_LIST_GET_LEN(m_slots) != 0) 
------apply_redo_to_one_slot(slot);
--------buf_page_peek_for_apply
----------buf_page_get_gen
----------call_back_func
------------prpl_add_redo_log_recs
--------if (block != NULL && locked)
----------apply_redo_to_one_slot_low
--------else if (block == NULL)
----------skip_redo_to_one_slot_low
```