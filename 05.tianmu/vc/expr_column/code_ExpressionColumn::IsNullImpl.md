#1.ExpressionColumn::IsNullImpl

```
ExpressionColumn::IsNullImpl
--if (FeedArguments(mit))
    last_val_ = expr_->Evaluate();
  return last_val_->IsNull();

```