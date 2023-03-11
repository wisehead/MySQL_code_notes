#1.class CompiledQuery

```cpp
/*
        CompiledQuery - for storing execution plan of a query (sequence of
   primitive operations) and output data definition
*/
class MysqlExpression;

class CompiledQuery final {
 public:
  // Definition of one step
  enum class StepType {
    TABLE_ALIAS,
    TMP_TABLE,
    CREATE_CONDS,
    AND_F,
    OR_F,
    AND_DESC,
    OR_DESC,
    T_MODE,
    JOIN_T,
    LEFT_JOIN_ON,
    INNER_JOIN_ON,
    ADD_CONDS,
    APPLY_CONDS,
    ADD_COLUMN,
    ADD_ORDER,
    UNION,
    RESULT,
    STEP_ERROR,
    CREATE_VC
  };

  class CQStep {
   public:
    StepType type;
    TabID t1;
    TabID t2;
    TabID t3;
    AttrID a1, a2;
    CondID c1, c2, c3;
    CQTerm e1, e2, e3;
    common::Operator op;  // predicate: common::Operator::O_EQ, common::Operator::O_LESS etc.
    common::ExtraOperation ex_op;
    TMParameter tmpar;  // Table Mode Parameter
    JoinType jt;
    common::ColOperation cop;
    char *alias;
    std::vector<MysqlExpression *> mysql_expr;
    std::vector<int> virt_cols;
    std::vector<TabID> tables1;
    std::vector<TabID> tables2;
    int64_t n1, n2;  // additional parameter (e.g. descending order, TOP n,
                     // LIMIT n1..n2)
    SI si;
   private:
  };
  // Initialization


 private:

  // IDs of params and filters start with 0 and increase.
  int no_tabs;   // counters: which IDs are not in use?
  int no_conds;  // counters: which IDs are not in use?

  std::map<TabID, int> no_virt_cols;

  std::vector<int> no_attrs;  // repository of attr_ids for each table
  std::vector<CQStep> steps;  // repository of steps to be executed

  // Extra containers to store specific steps (tmp_tables, group by, tabid2steps
  // map) so that search can be faster than looking them in the original
  // container (steps).
  std::vector<CQStep> steps_tmp_tables;
  std::vector<CQStep> steps_group_by_cols;
  std::multimap<TabID, CQStep> TabIDSteps;
};
```