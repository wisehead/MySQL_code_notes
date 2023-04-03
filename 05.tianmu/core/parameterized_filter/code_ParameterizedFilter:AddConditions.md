#1.ParameterizedFilter::AddConditions

```
ParameterizedFilter::AddConditions
--Condition &cond = *new_cond;
--for (uint i = 0; i < cond.Size(); i++) {
----cond[i].SetCondType(type);
----(cond[i].IsParameterized()) ? parametrized_desc_.AddDescriptor(cond[i]) : descriptors_.AddDescriptor(cond[i]);//加入ParameterizedFilter的desctiptor vector
										//而filter是属于TempTable的
```