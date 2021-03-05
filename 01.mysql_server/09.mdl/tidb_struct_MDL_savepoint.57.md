#1.class MDL_savepoint

```cpp
/**
  Savepoint for MDL context.

  Doesn't include metadata locks with explicit duration as
  they are not released during rollback to savepoint.
*/

class MDL_savepoint
{
public:
  MDL_savepoint() {};

private:
  MDL_savepoint(MDL_ticket *stmt_ticket, MDL_ticket *trans_ticket)
    : m_stmt_ticket(stmt_ticket), m_trans_ticket(trans_ticket)
  {}

  friend class MDL_context;

private:
  /**
    Pointer to last lock with statement duration which was taken
    before creation of savepoint.
  */
  MDL_ticket *m_stmt_ticket;
  /**
    Pointer to last lock with transaction duration which was taken
    before creation of savepoint.
  */
  MDL_ticket *m_trans_ticket;
};

```