#1.class QUICK_SELECT_I

```cpp
/*
  Quick select interface.
  This class is a parent for all QUICK_*_SELECT and FT_SELECT classes.

  The usage scenario is as follows:
  1. Create quick select
    quick= new QUICK_XXX_SELECT(...);

  2. Perform lightweight initialization. This can be done in 2 ways:
  2.a: Regular initialization
    if (quick->init())
    {
      //the only valid action after failed init() call is delete
      delete quick;
    }
  2.b: Special initialization for quick selects merged by QUICK_ROR_*_SELECT
    if (quick->init_ror_merged_scan())
      delete quick;

  3. Perform zero, one, or more scans.
    while (...)
    {
      // initialize quick select for scan. This may allocate
      // buffers and/or prefetch rows.
      if (quick->reset())
      {
        //the only valid action after failed reset() call is delete
        delete quick;
        //abort query
      }

      // perform the scan
      do
      {
        res= quick->get_next();
      } while (res && ...)
    }

  4. Delete the select:
    delete quick;
  
  NOTE 
    quick select doesn't use Sql_alloc/MEM_ROOT allocation because "range
    checked for each record" functionality may create/destroy
    O(#records_in_some_table) quick selects during query execution.
*/

class QUICK_SELECT_I
{
public:
  ha_rows records;  /* estimate of # of records to be retrieved */
  double  read_time; /* time to perform this retrieval          */
  TABLE   *head;
  /*
    Index this quick select uses, or MAX_KEY for quick selects
    that use several indexes
  */
  uint index;

  /*
    Total length of first used_key_parts parts of the key.
    Applicable if index!= MAX_KEY.
  */
  uint max_used_key_length;

  /*
    Max. number of (first) key parts this quick select uses for retrieval.
    eg. for "(key1p1=c1 AND key1p2=c2) OR key1p1=c2" used_key_parts == 2.
    Applicable if index!= MAX_KEY.

    For QUICK_GROUP_MIN_MAX_SELECT it includes MIN/MAX argument keyparts.
  */
  uint used_key_parts;

  QUICK_SELECT_I();
  virtual ~QUICK_SELECT_I(){};

  /*
    Do post-constructor initialization.
    SYNOPSIS
      init()

    init() performs initializations that should have been in constructor if
    it was possible to return errors from constructors. The join optimizer may
    create and then delete quick selects without retrieving any rows so init()
    must not contain any IO or CPU intensive code.

    If init() call fails the only valid action is to delete this quick select,
    reset() and get_next() must not be called.

    RETURN
      0      OK
      other  Error code
  */
  virtual int  init() = 0;

  /*
    Initialize quick select for row retrieval.
    SYNOPSIS
      reset()

    reset() should be called when it is certain that row retrieval will be
    necessary. This call may do heavyweight initialization like buffering first
    N records etc. If reset() call fails get_next() must not be called.
    Note that reset() may be called several times if 
     * the quick select is executed in a subselect
     * a JOIN buffer is used
    
    RETURN
      0      OK
      other  Error code
  */
  virtual int  reset(void) = 0;

  virtual int  get_next() = 0;   /* get next record to retrieve */

  /* Range end should be called when we have looped over the whole index */
  virtual void range_end() {}

  /** 
    Whether the range access method returns records in reverse order.
  */
  virtual bool reverse_sorted() const = 0;
  /** 
    Whether the range access method is capable of returning records 
    in reverse order.
  */
  virtual bool reverse_sort_possible() const = 0;
  virtual bool unique_key_range() { return false; }
  virtual bool clustered_pk_range() { return false; }
  
  /*
    Request that this quick select produces sorted output.
    Not all quick selects can provide sorted output, the caller is responsible 
    for calling this function only for those quick selects that can.
    The implementation is also allowed to provide sorted output even if it
    was not requested if benificial, or required by implementation 
    internals.
  */
  virtual void need_sorted_output() = 0;
  enum {
    QS_TYPE_RANGE = 0,
    QS_TYPE_INDEX_MERGE = 1,
    QS_TYPE_RANGE_DESC = 2,
    QS_TYPE_FULLTEXT   = 3,
    QS_TYPE_ROR_INTERSECT = 4,
    QS_TYPE_ROR_UNION = 5,
    QS_TYPE_GROUP_MIN_MAX = 6
  };

  /* Get type of this quick select - one of the QS_TYPE_* values */
  virtual int get_type() = 0;

  /*
    Initialize this quick select as a merged scan inside a ROR-union or a ROR-
    intersection scan. The caller must not additionally call init() if this
    function is called.
    SYNOPSIS
      init_ror_merged_scan()
        reuse_handler  If true, the quick select may use table->handler,
                       otherwise it must create and use a separate handler
                       object.
    RETURN
      0     Ok
      other Error
  */
  virtual int init_ror_merged_scan(bool reuse_handler)
  { DBUG_ASSERT(0); return 1; }

  /*
    Save ROWID of last retrieved row in file->ref. This used in ROR-merging.
  */
  virtual void save_last_pos(){};

  /*
    Append comma-separated list of keys this quick select uses to key_names;
    append comma-separated list of corresponding used lengths to used_lengths.
    This is used by select_describe.
  */
  virtual void add_keys_and_lengths(String *key_names,
                                    String *used_lengths)=0;

  /*
    Append text representation of quick select structure (what and how is
    merged) to str. The result is added to "Extra" field in EXPLAIN output.
    This function is implemented only by quick selects that merge other quick
    selects output and/or can produce output suitable for merging.
  */
  virtual void add_info_string(String *str) {};
  /*
    Return 1 if any index used by this quick select
    uses field which is marked in passed bitmap.
  */
  virtual bool is_keys_used(const MY_BITMAP *fields);

  /**
    Simple sanity check that the quick select has been set up
    correctly. Function is overridden by quick selects that merge
    indices.
   */
  virtual bool is_valid() { return index != MAX_KEY; };

  /*
    rowid of last row retrieved by this quick select. This is used only when
    doing ROR-index_merge selects
  */
  uchar    *last_rowid;

  /*
    Table record buffer used by this quick select.
  */
  uchar    *record;
#ifndef DBUG_OFF
  /*
    Print quick select information to DBUG_FILE. Caller is responsible
    for locking DBUG_FILE before this call and unlocking it afterwards.
  */
  virtual void dbug_dump(int indent, bool verbose)= 0;
#endif

  /*
    Returns a QUICK_SELECT with reverse order of to the index.
  */
  virtual QUICK_SELECT_I *make_reverse(uint used_key_parts_arg) { return NULL; }
  virtual void set_handler(handler *file_arg) {}
};


```