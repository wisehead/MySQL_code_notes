#1.class XID_STATE

```cpp
class XID_STATE
{
public:
  enum xa_states {XA_NOTR=0, XA_ACTIVE, XA_IDLE, XA_PREPARED, XA_ROLLBACK_ONLY};

  /**
     Transaction identifier.
     For now, this is only used to catch duplicated external xids.
  */
private:
  static const char *xa_state_names[];

  XID m_xid;
  /// Used by external XA only
  xa_states xa_state;
  bool in_recovery;
  /// Error reported by the Resource Manager (RM) to the Transaction Manager.
  uint rm_error;
  /*
    XA-prepare binary logging status. The flag serves as a facility
    to conduct XA transaction two round binary logging.
    It is set to @c false at XA-start.
    It is set to @c true by binlogging routine of XA-prepare handler as well
    as recovered to @c true at the server recovery upon restart.
    Checked and reset at XA-commit/rollback.
  */
  bool m_is_binlogged;
};  
  
```