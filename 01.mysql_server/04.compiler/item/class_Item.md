#1.class Item

```cpp
class Item
{
  int8 is_expensive_cache;
  enum Type {FIELD_ITEM= 0, FUNC_ITEM, SUM_FUNC_ITEM, STRING_ITEM,
         INT_ITEM, REAL_ITEM, NULL_ITEM, VARBIN_ITEM,
         COPY_STR_ITEM, FIELD_AVG_ITEM, DEFAULT_VALUE_ITEM,
         PROC_ITEM,COND_ITEM, REF_ITEM, FIELD_STD_ITEM,
         FIELD_VARIANCE_ITEM, INSERT_VALUE_ITEM,
             SUBSELECT_ITEM, ROW_ITEM, CACHE_ITEM, TYPE_HOLDER,
             PARAM_ITEM, TRIGGER_FIELD_ITEM, DECIMAL_ITEM,
             XPATH_NODESET, XPATH_NODESET_CMP,
             VIEW_FIXER_ITEM};

  enum cond_result { COND_UNDEF,COND_OK,COND_TRUE,COND_FALSE };

  enum traverse_order { POSTFIX, PREFIX };

  /* Reuse size, only used by SP local variable assignment, otherwize 0 */
  uint rsize;

  /*
    str_values's main purpose is to be used to cache the value in
    save_in_field
  */
  String str_value;

  Item_name_string item_name;  /* Name from select */
  Item_name_string orig_name;  /* Original item name (if it was renamed)*/

  /**
     Intrusive list pointer for free list. If not null, points to the next
     Item on some Query_arena's free list. For instance, stored procedures
     have their own Query_arena's.

     @see Query_arena::free_list
   */
  Item *next;
  uint32 max_length;                    /* Maximum length, in bytes */
  /**
     This member has several successive meanings, depending on the phase we're
     in:
     - during field resolution: it contains the index, in the "all_fields"
     list, of the expression to which this field belongs; or a special
     constant UNDEF_POS; see st_select_lex::cur_pos_in_all_fields and
     match_exprs_for_only_full_group_by().
     - when attaching conditions to tables: it says whether some condition
     needs to be attached or can be omitted (for example because it is already
     implemented by 'ref' access)
     - when pushing index conditions: it says whether a condition uses only
     indexed columns
     - when creating an internal temporary table: it says how to store BIT
     fields
     - when we change DISTINCT to GROUP BY: it is used for book-keeping of
     fields.
  */
  int marker;
  uint8 decimals;
  my_bool maybe_null;           /* If item may be null */
  my_bool null_value;           /* if item is null */
  my_bool unsigned_flag;
  my_bool with_sum_func;
  my_bool fixed;                        /* If item fixed with fix_fields */
  DTCollation collation;
  Item_result cmp_context;              /* Comparison context */
  /*
    If this item was created in runtime memroot,it cannot be used for
    substitution in subquery transformation process
   */
  bool runtime_item;
 protected:
  my_bool with_subselect;               /* If this item is a subselect or some
                                           of its arguments is or contains a
                                           subselect. Computed by fix_fields
                                           and updated by update_used_tables. */
  my_bool with_stored_program;          /* If this item is a stored program
                                           or some of its arguments is or
                                           contains a stored program.
                                           Computed by fix_fields and updated
                                           by update_used_tables. */

  /**
    This variable is a cache of 'Needed tables are locked'. True if either
    'No tables locks is needed' or 'Needed tables are locked'.
    If tables are used, then it will be set to
    current_thd->lex->is_query_tables_locked().

    It is used when checking const_item()/can_be_evaluated_now().
  */
  bool tables_locked_cache;
};      
```