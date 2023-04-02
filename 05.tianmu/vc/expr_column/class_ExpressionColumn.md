#1.class ExpressionColumn

```
class ExpressionColumn : public VirtualColumn {
  // if ExpressionColumn ExpressionColumn encapsulates an expression these sets
  // are used to interface with core::MysqlExpression
  core::MysqlExpression::SetOfVars vars_;
  core::MysqlExpression::TypOfVars var_types_;
  mutable core::MysqlExpression::var_buf_t var_buf_;
  // B_chenhui
  static thread_local core::MysqlExpression::var_buf_t tls_var_buf_;
  // E_chenhui

  //! value for a given row is always the same or not? e.g. currenttime() is not
  //! deterministic
  bool deterministic_;
};
```