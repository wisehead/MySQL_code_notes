#1.class Yacc_state

```cpp
/**
  The internal state of the syntax parser.
  This object is only available during parsing,
  and is private to the syntax parser implementation (sql_yacc.yy).
*/
class Yacc_state
{
public:
  /**
    Bison internal state stack, yyss, when dynamically allocated using
    my_yyoverflow().
  */
  uchar *yacc_yyss;

  /**
    Bison internal semantic value stack, yyvs, when dynamically allocated using
    my_yyoverflow().
  */
  uchar *yacc_yyvs;
  /**
    Fragments of parsed tree,
    used during the parsing of SIGNAL and RESIGNAL.
  */
  Set_signal_information m_set_signal_info;

  /**
    Type of lock to be used for tables being added to the statement's
    table list in table_factor, table_alias_ref, single_multi and
    table_wild_one rules.
    Statements which use these rules but require lock type different
    from one specified by this member have to override it by using
    st_select_lex::set_lock_for_tables() method.

    The default value of this member is TL_READ_DEFAULT. The only two
    cases in which we change it are:
    - When parsing SELECT HIGH_PRIORITY.
    - Rule for DELETE. In which we use this member to pass information
      about type of lock from delete to single_multi part of rule.

    We should try to avoid introducing new use cases as we would like
    to get rid of this member eventually.
  */
  thr_lock_type m_lock_type;

  /**
    The type of requested metadata lock for tables added to
    the statement table list.
  */
  enum_mdl_type m_mdl_type;

  /** Type of condition for key in HANDLER READ statement. */
  enum ha_rkey_function m_ha_rkey_mode;

  /*
    TODO: move more attributes from the LEX structure here.
  */
};
  
```