#1.ParameterizedFilter::PrepareRoughMultiIndex

```
ParameterizedFilter::PrepareRoughMultiIndex
--for (uint i = 0; i < (uint)mind_->NumOfDimensions(); i++)
----//power=16，相当于对于64K，取模运算。
----packs.push_back((int)((mind_->OrigSize(i) + ((1 << mind_->ValueOfPower()) - 1)) >> mind_->ValueOfPower()));
--rough_mind_ = new RoughMultiIndex(packs);
--for (uint d = 0; d < (uint)mind_->NumOfDimensions(); d++) {
----Filter *f = mind_->GetFilter(d);
----for (int p = 0; p < rough_mind_->NumOfPacks(d); p++) {
------if (f == nullptr)
        rough_mind_->SetPackStatus(d, p, common::RoughSetValue::RS_UNKNOWN);
------else if (f->IsFull(p))
--------rough_mind_->SetPackStatus(d, p, common::RoughSetValue::RS_ALL);
----------rf[dim][pack] = v; 
------else if (f->IsEmpty(p))
        rough_mind_->SetPackStatus(d, p, common::RoughSetValue::RS_NONE);
------else
        rough_mind_->SetPackStatus(d, p, common::RoughSetValue::RS_SOME);
```