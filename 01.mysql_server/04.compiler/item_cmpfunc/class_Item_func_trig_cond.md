#1.class Item_func_trig_cond

```cpp

class Item_func_trig_cond: public Item_bool_func
{
public:
  enum enum_trig_type
  {
    /**
       In t1 LEFT JOIN t2, ON can be tested on t2's row only if that row is
       not NULL-complemented
    */
    IS_NOT_NULL_COMPL,
    /**
       In t1 LEFT JOIN t2, the WHERE pushed to t2 can be tested only after at
       least one t2's row has been found
    */
    FOUND_MATCH,
    /**
       In IN->EXISTS subquery transformation, new predicates are added:
       WHERE inner_field=outer_field OR inner_field IS NULL,
       as well as
       HAVING inner_field IS NOT NULL,
       are disabled if outer_field is a NULL value
    */
    OUTER_FIELD_IS_NOT_NULL
  };
private:
  /** Pointer to trigger variable */
  bool *trig_var;
  /** Optional table(s) which are the source of trig_var; for printing */
  const struct st_join_table *trig_tab;
  /** Type of trig_var; for printing */
  enum_trig_type trig_type;
...
...
}
```

#2.comments

```cpp
/*
  trigcond<param>(arg) ::= param? arg : TRUE

  The class Item_func_trig_cond is used for guarded predicates 
  which are employed only for internal purposes.
  A guarded predicate is an object consisting of an a regular or
  a guarded predicate P and a pointer to a boolean guard variable g. 
  A guarded predicate P/g is evaluated to true if the value of the
  guard g is false, otherwise it is evaluated to the same value that
  the predicate P: val(P/g)= g ? val(P):true.
  Guarded predicates allow us to include predicates into a conjunction
  conditionally. Currently they are utilized for pushed down predicates
  in queries with outer join operations.

  In the future, probably, it makes sense to extend this class to
  the objects consisting of three elements: a predicate P, a pointer
  to a variable g and a firing value s with following evaluation
  rule: val(P/g,s)= g==s? val(P) : true. It will allow us to build only
  one item for the objects of the form P/g1/g2... 

  Objects of this class are built only for query execution after
  the execution plan has been already selected. That's why this
  class needs only val_int out of generic methods. 
 
  Current uses of Item_func_trig_cond objects:
   - To wrap selection conditions when executing outer joins
   - To wrap condition that is pushed down into subquery
*/
```