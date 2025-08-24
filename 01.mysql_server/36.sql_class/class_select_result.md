#1.class select_result

```cpp
class select_result :public Sql_alloc {
protected:
  THD *thd;
  SELECT_LEX_UNIT *unit;
public:
  /**
    Number of records estimated in this result.
    Valid only for materialized derived tables/views.
  */
  ha_rows estimated_rowcount;
  select_result();
  virtual ~select_result() {};
  virtual int prepare(List<Item> &list, SELECT_LEX_UNIT *u)
  {
    unit= u;
    return 0;
  }
  virtual int prepare2(void) { return 0; }
  /*
    Because of peculiarities of prepared statements protocol
    we need to know number of columns in the result set (if
    there is a result set) apart from sending columns metadata.
  */
  virtual uint field_count(List<Item> &fields) const
  { return fields.elements; }
  virtual bool send_result_set_metadata(List<Item> &list, uint flags)=0;
  virtual bool send_data(List<Item> &items)=0;
  virtual bool initialize_tables (JOIN *join=0) { return 0; }
  virtual void send_error(uint errcode,const char *err);
  virtual bool send_eof()=0;
  /**
    Check if this query returns a result set and therefore is allowed in
    cursors and set an error message if it is not the case.

    @retval FALSE     success
    @retval TRUE      error, an error message is set
  */
  virtual bool check_simple_select() const;
  virtual void abort_result_set() {}
  /*
    Cleanup instance of this class for next execution of a prepared
    statement/stored procedure.
  */
  virtual void cleanup();
  void set_thd(THD *thd_arg) { thd= thd_arg; }

  /**
    If we execute EXPLAIN SELECT ... LIMIT (or any other EXPLAIN query)
    we have to ignore offset value sending EXPLAIN output rows since
    offset value belongs to the underlying query, not to the whole EXPLAIN.
  */
  void reset_offset_limit_cnt() { unit->offset_limit_cnt= 0; }

#ifdef EMBEDDED_LIBRARY
  virtual void begin_dataset() {}
#else
  void begin_dataset() {}
#endif
};
```