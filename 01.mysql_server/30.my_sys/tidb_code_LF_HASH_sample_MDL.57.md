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

#5.lf_hash_insert

```cpp
MDL_map::find_or_insert
--while ((lock= find(pins, mdl_key, pinned)) == NULL)
--lf_hash_insert(&m_locks, pins, mdl_key);
```

#6.lf_hash_delete

```cpp
MDL_map::remove_random_unused
--MDL_lock *lock=lf_hash_random_match(&m_locks, pins, &mdl_lock_match_unused, ctx->get_random()));
--mysql_prlock_wrlock(&lock->m_rwlock);
--lf_hash_search_unpin(pins);
--if (lock->fast_path_state_cas(&old_state, MDL_lock::IS_DESTROYED))
----mysql_prlock_unlock(&lock->m_rwlock);
----lf_hash_delete(&m_locks, pins, lock->key.ptr(), lock->key.length());
```

#7.mdl_locks_key

```cpp
extern "C"
{
static uchar *
mdl_locks_key(const uchar *record, size_t *length,
              my_bool not_used MY_ATTRIBUTE((unused)))
{
  MDL_lock *lock=(MDL_lock*) record;
  *length= lock->key.length();
  return (uchar*) lock->key.ptr();
}
} /* extern "C" */
```
