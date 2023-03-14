#1.ParameterizedFilter::PropagateRoughToMind

```
ParameterizedFilter::PropagateRoughToMind
--for (int i = 0; i < rough_mind_->NumOfDimensions(); i++) {  // update classical multiindex
----Filter *f = mind_->GetUpdatableFilter(i);
----for (int b = 0; b < rough_mind_->NumOfPacks(i); b++) {
------if (rough_mind_->GetPackStatus(i, b) == common::RoughSetValue::RS_NONE)
--------f->ResetBlock(b);
----}

----if (f->IsEmpty())
------is_nonempty = false;
```