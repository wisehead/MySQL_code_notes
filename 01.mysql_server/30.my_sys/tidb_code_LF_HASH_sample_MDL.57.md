#1.lf_hash_init2

```cpp
MDL_map::init
--lf_hash_init2
```

#2.lf_hash_destroy

```cpp
MDL_map::destroy
--lf_hash_destroy
```

#3.lf_hash_search

```cpp
caller:
- MDL_map::find_or_insert
- MDL_context::find_lock_owner

MDL_map::find
--lock= static_cast<MDL_lock *>(lf_hash_search(&m_locks, pins, mdl_key->ptr(),mdl_key->length()));

MDL_context::try_acquire_lock_impl
--MDL_context::fix_pins
--MDL_map::find_or_insert
----MDL_map::find

```

#4.lf_hash_get_pins

```cpp
try_acquire_lock_impl
--MDL_context::fix_pins
----MDL_map::get_pins
------lf_hash_get_pins
```