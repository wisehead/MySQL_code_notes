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
```

#2. TransformOtherThanINsOnNumerics
```
TransformOtherThanINsOnNumerics
--if (desc->val1.vc && (desc->val1.vc)->IsMultival()) {
--} else if (desc->val1.vc->IsConst()) {
----v1 = attr->EncodeValue64(desc->val1.vc->GetValue(mit), v1_rounded,
                       &tianmu_err_code);
--if (desc->val2.vc && (desc->val2.vc)->IsMultival()) {
--else
----//do nothing
--if (ISTypeOfEqualOperator(desc->op) || ISTypeOfNotEqualOperator(desc->op))
----v2 = v1;
--if (ISTypeOfNotEqualOperator(desc->op) || desc->op == common::Operator::O_NOT_BETWEEN)
----desc->op = common::Operator::O_NOT_BETWEEN;
--else
----desc->op = common::Operator::O_BETWEEN;  
//把id=2变成，id between(1,1)
--desc->val1 = CQTerm();
  desc->val1.vc = new vcolumn::ConstColumn(
      ValueOrNull(types::TianmuNum(v1, attr->Type().GetScale(), ATI::IsRealType(AttrTypeName()), AttrTypeName())),
      attr->Type());
  desc->val1.vc_id = desc->table->AddVirtColumn(desc->val1.vc);

  desc->val2 = CQTerm();
  desc->val2.vc = new vcolumn::ConstColumn(
      ValueOrNull(types::TianmuNum(v2, attr->Type().GetScale(), ATI::IsRealType(AttrTypeName()), AttrTypeName())),
      attr->Type());
  desc->val2.vc_id = desc->table->AddVirtColumn(desc->val2.vc);
--
```