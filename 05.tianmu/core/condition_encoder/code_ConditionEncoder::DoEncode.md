#1.ConditionEncoder::DoEncode

```
ConditionEncoder::DoEncode
--TransformWithRespectToNulls
--if (!IsTransformationNeeded())
    return;
--DescriptorTransformation
--if (ATI::IsStringType(AttrTypeName()))
    EncodeConditionOnStringColumn();
--else
----EncodeConditionOnNumerics();
------TransformOtherThanINsOnNumerics
--------if (desc->val1.vc && (desc->val1.vc)->IsMultival()) {
--------} else if (desc->val1.vc->IsConst()) {
----------v1 = attr->EncodeValue64(desc->val1.vc->GetValue(mit), v1_rounded,
                             &tianmu_err_code);
----------                             
```