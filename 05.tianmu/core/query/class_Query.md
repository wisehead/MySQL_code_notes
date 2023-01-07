#1.class Query

```cpp
class Query final {
 public:
  enum class WrapStatus { SUCCESS, FAILURE, OPTIMIZE };
  
 private:
  CompiledQuery *cq = nullptr;
  std::vector<std::pair<TabID, bool>> subqueries_in_where;
  using TabIDColAlias = std::pair<int, std::string>;
  std::map<TabIDColAlias, int> field_alias2num;
  std::map<std::string, unsigned> path2num;

  // all expression based virtual columns for a given table
  std::multimap<TabID, std::pair<int, MysqlExpression *>> tab_id2expression;
  std::multimap<TabID, std::pair<int, std::pair<std::vector<int>, AttrID>>> tab_id2inset;

  std::vector<MysqlExpression *> gc_expressions;
  std::multimap<std::pair<int, int>, std::pair<int, int>> phys2virt;
  std::multimap<TabID, std::pair<int, TabID>> tab_id2subselect;
  std::map<Item_tianmufield *, int> tianmuitems_cur_var_ids;

  // table aliases - sometimes point to TempTables (maybe to the same one), sometimes to TIanmuTables
  std::vector<std::shared_ptr<JustATable>> ta;

  std::vector<std::shared_ptr<TianmuTable>> t;

  bool rough_query = false;  // set as true to enable rough execution
};  
```