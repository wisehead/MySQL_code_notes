#1.ha_innobase::store_lock

```cpp
ha_innobase::store_lock(
...
        /* Check for FLUSH TABLES ... WITH READ LOCK */
        if (trx->isolation_level == TRX_ISO_SERIALIZABLE) {
                m_prebuilt->select_lock_type = LOCK_S;
                m_prebuilt->stored_select_lock_type = LOCK_S;
        } else {
                m_prebuilt->select_lock_type = LOCK_NONE;
                m_prebuilt->stored_select_lock_type = LOCK_NONE;
        }
...
}
```