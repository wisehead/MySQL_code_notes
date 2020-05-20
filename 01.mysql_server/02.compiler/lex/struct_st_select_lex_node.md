#1.st_select_lex_node
#1.1 long comments

```cpp
/*
  The state of the lex parsing for selects

   master and slaves are pointers to select_lex.
   master is pointer to upper level node.
   slave is pointer to lower level node
   select_lex is a SELECT without union
   unit is container of either
     - One SELECT
     - UNION of selects
   select_lex and unit are both inherited form select_lex_node
   neighbors are two select_lex or units on the same level

   All select describing structures linked with following pointers:
   - list of neighbors (next/prev) (prev of first element point to slave
     pointer of upper structure)
     - For select this is a list of UNION's (or one element list)
     - For units this is a list of sub queries for the upper level select

   - pointer to master (master), which is
     If this is a unit
       - pointer to outer select_lex
     If this is a select_lex
       - pointer to outer unit structure for select

   - pointer to slave (slave), which is either:
     If this is a unit:
       - first SELECT that belong to this unit
     If this is a select_lex
       - first unit that belong to this SELECT (subquries or derived tables)

   - list of all select_lex (link_next/link_prev)
     This is to be used for things like derived tables creation, where we
     go through this list and create the derived tables.

   If unit contain several selects (UNION now, INTERSECT etc later)
   then it have special select_lex called fake_select_lex. It used for
   storing global parameters (like ORDER BY, LIMIT) and executing union.
   Subqueries used in global ORDER BY clause will be attached to this
   fake_select_lex, which will allow them correctly resolve fields of
   'upper' UNION and outer selects.

   For example for following query:

   select *
     from table1
     where table1.field IN (select * from table1_1_1 union
                            select * from table1_1_2)
     union
   select *
     from table2
     where table2.field=(select (select f1 from table2_1_1_1_1
                                   where table2_1_1_1_1.f2=table2_1_1.f3)
                           from table2_1_1
                           where table2_1_1.f1=table2.f2)
     union
   select * from table3;

   we will have following structure:

   select1: (select * from table1 ...)
   select2: (select * from table2 ...)
   select3: (select * from table3)
   select1.1.1: (select * from table1_1_1)
   ...

     main unit
     fake0
     select1 select2 select3
     |^^     |^
    s|||     ||master
    l|||     |+---------------------------------+
    a|||     +---------------------------------+|
    v|||master                         slave   ||
    e||+-------------------------+             ||
     V|            neighbor      |             V|
     unit1.1<+==================>unit1.2       unit2.1
     fake1.1
     select1.1.1 select 1.1.2    select1.2.1   select2.1.1
                                               |^
                                               ||
                                               V|
                                               unit2.1.1.1
                                               select2.1.1.1.1


   relation in main unit will be following:
   (bigger picture for:
      main unit
      fake0
      select1 select2 select3
   in the above picture)

         main unit
         |^^^^|fake_select_lex
         |||||+--------------------------------------------+
         ||||+--------------------------------------------+|
         |||+------------------------------+              ||
         ||+--------------+                |              ||
    slave||master         |                |              ||
         V|      neighbor |       neighbor |        master|V
         select1<========>select2<========>select3        fake0

    list of all select_lex will be following (as it will be constructed by
    parser):
    select1->select2->select3->select2.1.1->select 2.1.2->select2.1.1.1.1-+
                                                                          |
    +---------------------------------------------------------------------+
    |
    +->select1.1.1->select1.1.2

*/                               
```

#1.2 	class st_select_lex_node(SELECT_LEX_NODE)

```cpp
class st_select_lex_node {
protected:
  st_select_lex_node *next, **prev,   /* neighbor list */
    *master, *slave,                  /* vertical links */
    *link_next, **link_prev;          /* list of whole SELECT_LEX */
public:

  ulonglong options;

  /*
    In sql_cache we store SQL_CACHE flag as specified by user to be
    able to restore SELECT statement from internal structures.
  */
  enum e_sql_cache { SQL_CACHE_UNSPECIFIED, SQL_NO_CACHE, SQL_CACHE };
  e_sql_cache sql_cache;

  /*
    result of this query can't be cached, bit field, can be :
      UNCACHEABLE_DEPENDENT
      UNCACHEABLE_RAND
      UNCACHEABLE_SIDEEFFECT
      UNCACHEABLE_EXPLAIN
      UNCACHEABLE_PREPARE
  */
  uint8 uncacheable;
  enum sub_select_type linkage;
  bool no_table_names_allowed; /* used for global order by */
  bool no_error; /* suppress error message (convert it to warnings) */

  static void *operator new(size_t size) throw ()
  {
    return sql_alloc(size);
  }
  static void *operator new(size_t size, MEM_ROOT *mem_root) throw ()
  { return (void*) alloc_root(mem_root, (uint) size); }
  static void operator delete(void *ptr,size_t size) { TRASH(ptr, size); }
  static void operator delete(void *ptr, MEM_ROOT *mem_root) {}

  // Ensures that at least all members used during cleanup() are initialized.
  st_select_lex_node()
    : next(NULL), prev(NULL),
      master(NULL), slave(NULL),
      link_next(NULL), link_prev(NULL),
      linkage(UNSPECIFIED_TYPE)
  {
  }
  virtual ~st_select_lex_node() {}

  inline st_select_lex_node* get_master() { return master; }
  virtual void init_query();
  virtual void init_select();
  void include_down(st_select_lex_node *upper);
  void include_neighbour(st_select_lex_node *before);
  void include_standalone(st_select_lex_node *sel, st_select_lex_node **ref);
  void include_global(st_select_lex_node **plink);
  void exclude();

  virtual st_select_lex_unit* master_unit()= 0;
  virtual st_select_lex* outer_select()= 0;

  virtual bool set_braces(bool value);
  virtual bool inc_in_sum_expr();
  virtual uint get_in_sum_expr();
  virtual TABLE_LIST* get_table_list();
  virtual List<Item>* get_item_list();
  virtual ulong get_table_join_options();
  virtual TABLE_LIST *add_table_to_list(THD *thd, Table_ident *table,
                    LEX_STRING *alias,
                    ulong table_options,
                    thr_lock_type flags= TL_UNLOCK,
                                        enum_mdl_type mdl_type= MDL_SHARED_READ,
                    List<Index_hint> *hints= 0,
                                        List<String> *partition_names= 0,
                                        LEX_STRING *option= 0);
  virtual void set_lock_for_tables(thr_lock_type lock_type) {}

  friend class st_select_lex_unit;
  friend bool mysql_new_select(LEX *lex, bool move_down);
  friend bool mysql_make_view(THD *thd, TABLE_SHARE *share, TABLE_LIST *table,
                              bool open_view_no_parse);
private:
  void fast_exclude();
};
typedef class st_select_lex_node SELECT_LEX_NODE;
```