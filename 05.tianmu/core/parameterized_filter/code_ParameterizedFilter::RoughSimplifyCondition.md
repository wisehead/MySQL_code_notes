#1.ParameterizedFilter::RoughSimplifyCondition

```
ParameterizedFilter::RoughSimplifyCondition
--for (uint i = 0; i < cond.Size(); i++) {
    Descriptor &desc = cond[i];
    if (desc.op == common::Operator::O_FALSE || desc.op == common::Operator::O_TRUE || !desc.IsType_OrTree())
      continue;
```