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

#2.notes

```cpp
/**Savepoint for MDL context.  //注意，不是所有的元数据锁可以被“即时释放”的，如
“explicit duration”类型
    Doesn't include metadata locks with explicit duration asthey are not released
during rollback to savepoint.*/
class MDL_savepoint
{
public:
    MDL_savepoint() {};
private:
    MDL_savepoint(MDL_ticket *stmt_ticket, MDL_ticket *trans_ticket)
        : m_stmt_ticket(stmt_ticket), m_trans_ticket(trans_ticket){}
    friend class MDL_context;
private:
    /**Pointer to last lock with statement duration which was takenbefore
    creation of savepoint.*/
    MDL_ticket *m_stmt_ticket;  //statement duration类可以被及时释放
    /**Pointer to last lock with transaction duration which was takenbefore
    creation of savepoint.*/
    MDL_ticket *m_trans_ticket;//transaction duration类可以被及时释放
};

```