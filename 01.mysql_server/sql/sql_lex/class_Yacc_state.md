#1.class Yacc_state

```cpp

class Yacc_state  //词法分析时关键字的值
{...
    /**
        Type of lock to be used for tables being added to the statement'stable
        list in table_factor,
        table_alias_ref, single_multi andtable_wild_one rules.
        Statements which use these rules but require lock type differentfrom one
        specified bythis member
        have to override it by usingst_select_lex::set_lock_for_tables() method.
       //这句描述的情况主要适用与UPDATE和INSERT语句
        The default value of this member is TL_READ_DEFAULT. The only twocases in
          which we change it are:
        - When parsing SELECT HIGH_PRIORITY. //参见11.5.1节中SELECT语句的语法
        - Rule for DELETE. In which we use this member to pass informationabout
        type of lock from delete to single_multi part of rule.
        We should try to avoid introducing new use cases as we would liketo get
       rid of this member eventually.
    */
    thr_lock_type m_lock_type; //为记录/元组记载锁的粒度(参见11.5.1节)
    // The type of requested metadata lock for tables added tothe statement table list.
    enum_mdl_type m_mdl_type; //为表结构/元信息记载锁的粒度
...
  void reset()  //设置锁的缺省值
  {
    yacc_yyss= NULL;
    yacc_yyvs= NULL;
    yacc_yyls= NULL;
    m_lock_type= TL_READ_DEFAULT; //为记录/元组记载锁的粒度对应的缺省值
    m_mdl_type= MDL_SHARED_READ; //为表结构/元信息记载锁的粒度对应的缺省值
    m_ha_rkey_mode= HA_READ_KEY_EXACT;
  }
...}
```