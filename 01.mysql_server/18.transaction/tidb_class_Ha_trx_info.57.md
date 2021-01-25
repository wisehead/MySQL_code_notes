#1.class Ha_trx_info

```cpp
/**
  Either statement transaction or normal transaction - related
  thread-specific storage engine data.

  If a storage engine participates in a statement/transaction,
  an instance of this class is present in
  thd->m_transaction.m_scope_info[STMT|SESSION].ha_list. The addition
  this list is made by trans_register_ha().

  When it's time to commit or rollback, each element of ha_list
  is used to access storage engine's prepare()/commit()/rollback()
  methods, and also to evaluate if a full two phase commit is
  necessary.

  @sa General description of transaction handling in handler.cc.
*/

class Ha_trx_info
{
private:
  enum { TRX_READ_ONLY= 0, TRX_READ_WRITE= 1 };
  /**
    Auxiliary, used for ha_list management
  */
  Ha_trx_info *m_next;

  /**
    Although a given Ha_trx_info instance is currently always used
    for the same storage engine, 'ht' is not-NULL only when the
    corresponding storage is a part of a transaction.
  */
  handlerton *m_ht;

  /**
    Transaction flags related to this engine.
    Not-null only if this instance is a part of transaction.
    May assume a combination of enum values above.
  */
  uchar       m_flags;
};
```