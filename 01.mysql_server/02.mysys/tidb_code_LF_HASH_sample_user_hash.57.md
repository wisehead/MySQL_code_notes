#1.lf_hash_init

```cpp
/**
  Initialize the user hash.
  @return 0 on success
*/
int init_user_hash(const PFS_global_param *param)
{
  if ((! user_hash_inited) && (param->m_user_sizing != 0))
  {
    lf_hash_init(&user_hash, sizeof(PFS_user*), LF_HASH_UNIQUE,
                 0, 0, user_hash_get_key, &my_charset_bin);
    user_hash_inited= true;
  }
  return 0;
}
```

#2.lf_hash_destroy

```cpp
/** Cleanup the user hash. */
void cleanup_user_hash(void)
{
  if (user_hash_inited)
  {
    lf_hash_destroy(&user_hash);
    user_hash_inited= false;
  }
}
```

#3.lf_hash_search/lf_hash_insert

```cpp
find_or_create_user
--LF_PINS *pins= get_user_hash_pins(thread);
----thread->m_user_hash_pins= lf_hash_get_pins(&user_hash);
--entry= (lf_hash_search(&user_hash, pins, key.m_hash_key, key.m_key_length));
--if (entry && (entry != MY_ERRPTR))
----lf_hash_search_unpin(pins);
----return
--lf_hash_search_unpin(pins);
--res= lf_hash_insert(&user_hash, pins, &pfs);
```

#4.lf_hash_delete
```cpp
purge_user
--LF_PINS *pins= get_user_hash_pins(thread);
--lf_hash_search(&user_hash, pins,user->m_key.m_hash_key, user->m_key.m_key_length));
--lf_hash_delete(&user_hash, pins,user->m_key.m_hash_key, user->m_key.m_key_length);
--lf_hash_search_unpin(pins);
```

#5. lf_hash_get_pins

```cpp
get_user_hash_pins(thread);
--thread->m_user_hash_pins= lf_hash_get_pins(&user_hash);
```

#6.lf_hash_put_pins

```cpp
destroy_thread
--lf_hash_put_pins(pfs->m_user_hash_pins);
```

#7. user_hash_get_key

```cpp
static uchar *user_hash_get_key(const uchar *entry, size_t *length,my_bool)
--typed_entry= reinterpret_cast<const PFS_user* const *> (entry);
--user= *typed_entry;
--*length= user->m_key.m_key_length;
--result= user->m_key.m_hash_key;
--return const_cast<uchar*> (reinterpret_cast<const uchar*> (result));

```