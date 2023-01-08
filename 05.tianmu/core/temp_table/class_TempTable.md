#1.class TempTable

```cpp
//  TempTable - for storing a definition or content of a temporary table (view)

class TempTable : public JustATable {
 public:
  class Attr final : public PhysicalColumn {
   public:
    SI si;
    void *buffer;             // buffer to values of attribute, if materialized
    int64_t no_obj;           // number of objects in the buffer
    uint32_t no_power;        // number of objects in the buffer
    int64_t no_materialized;  // number of objects already set in the buffer
    uint page_size;           // size of one page of buffered values
    char *alias;
    common::ColOperation mode;
    bool distinct;  // distinct modifier for aggregations
    CQTerm term;
    int dim;  // dimension of a column, i.e., index of source table,
    // -1 means there is no corresponding table: constant, count(*)
    uint orig_precision;
    bool not_complete;  // does not contain all the column elements - some
                        // functions cannot be computed

  };
  
  struct TableMode {
    bool distinct;
    bool top;
    bool exists;
    int64_t param1, param2;  // e.g., TOP(5), LIMIT(2,5)
    TableMode() : distinct(false), top(false), exists(false), param1(0), param2(-1) {}
  };

 protected:
  int mem_scale;
  std::map<PhysicalColumn *, PhysicalColumn *> attr_back_translation;
  //	TempTable* subq_template;

 protected:
  int64_t no_obj;
  uint32_t p_power;                      // pack power
  uint no_cols;                          // no. of output columns, i.e., with defined alias
  TableMode mode;                        // based on { TM_DISTINCT, TM_TOP, TM_EXISTS }
  std::vector<Attr *> attrs;             // vector of output columns, each column contains
                                         // a buffer with values
  std::vector<Attr *> displayable_attr;  // just a shortcut: some of attrs
  Condition having_conds;
  std::vector<JustATable *> tables;                 // vector of pointers to source tables
  std::vector<int> aliases;                         // vector of aliases of source tables
  std::vector<vcolumn::VirtualColumn *> virt_cols;  // vector of virtual columns defined for TempTable
  std::vector<bool> virt_cols_for_having;           // is a virt column based on output_mind (true) or
                                                    // source mind_ (false)
  std::vector<JoinType> join_types;                 // vector of types of joins, one less than tables
  ParameterizedFilter filter;                       // multidimensional filter, contains multiindex,
                                                    // can be parametrized
  bool filter_shallow_memory = false;               // is filter shallow memory
  MultiIndex output_mind;                           // one dimensional MultiIndex used for operations on
                                                    // output columns of TempTable
  std::vector<SortDescriptor> order_by;             // indexes of order by columns
  bool group_by = false;                            // true if there is at least one grouping column
  bool is_vc_owner = true;                          // true if temptable should dealocate virtual columns
  int no_global_virt_cols;                          // keeps number of virtual columns. In case for_subq
                                                    // == true, all locally created
  // virtual columns will be removed
  bool is_sent;  // true if result of materialization was sent to MySQL

  // some internal functions for low-level query execution
  static const uint CACHE_SIZE = 100000000;  // size of memory cache for data in the materialized TempTable
  // everything else is cached on disk (CachedBuffer) buffers

  bool materialized = false;
  bool has_temp_table = false;

  bool lazy;                       // materialize on demand, page by page
  int64_t no_materialized;         // if lazy - how many are ready
  common::Tribool rough_is_empty;  // rough value specifying if there is
                                   // non-empty result of a query
  bool force_full_materialize = false;
  bool can_cond_push_down = false;  // Conditional push occurs

  // Refactoring: extracted small methods
  bool CanOrderSources();
  bool LimitMayBeAppliedToWhere();
  ColumnType GetUnionType(ColumnType type1, ColumnType type2);
  bool SubqueryInFrom();
  uint size_of_one_record;

 public:
  class RecordIterator;

 public:
  Transaction *m_conn;  // external pointer

 public:
  class Record final {
   public:
    RecordIterator &m_it;
  };

  /*! \brief RecordIterator class for _table records.
   */
  class RecordIterator final {
   public:
    TempTable *table;
    uint64_t _currentRNo;
    Transaction *_conn;
    bool is_prepared;

    std::vector<std::unique_ptr<types::TianmuDataType>> dataTypes;

   private:
    friend class TempTable;
    friend class Record;
  };
};

```