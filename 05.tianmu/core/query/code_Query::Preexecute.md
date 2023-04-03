#1.Query::Preexecute

```
Query::Preexecute
--std::vector<Condition *> conds(qu.NumOfConds());
--ta.resize(qu.NumOfTabs());
--global_limits = qu.GetGlobalLimit();
--for (int i = 0; i < qu.NumOfSteps(); i++)
----CompiledQuery::CQStep step = qu.Step(i);
----if (step.t1.n != common::NULL_VALUE_32) {
------if (step.t1.n >= 0)
--------t1_ptr = Table(step.t1.n);  // normal table
------else
--------t1_ptr = ta[-step.t1.n - 1];  // TempTable
----switch (step.type)
------case CompiledQuery::StepType::TABLE_ALIAS:
--------ta[-step.t1.n - 1] = t2_ptr;

------case CompiledQuery::StepType::TMP_TABLE:
--------ta[-step.t1.n - 1] = step.n1
                                   ? TempTable::Create(ta[-step.tables1[0].n - 1].get(), step.tables1[0].n, this, true)
                                   : TempTable::Create(ta[-step.tables1[0].n - 1].get(), step.tables1[0].n, this);
----------TempTable::Create
------------new TempTable(t, alias, q)
--------((TempTable *)ta[-step.t1.n - 1].get())->ReserveVirtColumns(qu.NumOfVirtualColumns(step.t1));

------case CompiledQuery::StepType::CREATE_CONDS:
--------step.e1.vc = TempTable::GetVirtualColumn(step.e1.vc_id)//where id=2, e1.vc_id = 0, value is id column
--------step.e2.vc =GetVirtualColumn(step.e2.vc_id)//e2.vc_id =2, value = 2
--------if (step.n1 != static_cast<int64_t>(CondType::OR_SUBTREE)) {  // on result = false
----------conds[step.c1.n] = new Condition();
----------if (step.c2.IsNull()) 
------------conds[step.c1.n]->AddDescriptor(
--------------Condition::AddDescriptor
----------------descriptors.push_back(Descriptor(e1, op, e2, e3, t, no_dims, like_esc));

------case CompiledQuery::StepType::JOIN_T:
--------((TempTable *)ta[-step.t1.n - 1].get())->JoinT(t2_ptr.get(), step.t2.n, step.jt);
----------TempTable::JoinT

------case CompiledQuery::StepType::ADD_CONDS: {
--------if (step.n1 != static_cast<int64_t>(CondType::HAVING_COND))
----------conds[step.c1.n]->Simplify();
--------TempTable::AddConds
----------filter.AddConditions(cond, CondType::WHERE_COND);

------case CompiledQuery::StepType::APPLY_CONDS: {
--------ParameterizedFilter *filter = tb->GetFilterP();
--------std::set<int> used_dims = qu.GetUsedDims(step.t1, ta);
--------for (int i = 0; i < filter->mind_->NumOfDimensions(); i++) {
----------(used_dims.find(i) == used_dims.end() && is_simple_filter && (!tb->CanCondPushDown()))
                ? filter->mind_->ResetUsedInOutput(i)
                : filter->mind_->SetUsedInOutput(i);
----------SetUsedInOutput
------------used_in_output[dim] = true                
--------filter->UpdateMultiIndex(qu.CountColumnOnly(step.t1), cur_limit);

------case CompiledQuery::StepType::ADD_COLUMN: 
--------e.vc =((TempTable *)ta[-step.t1.n - 1].get())->GetVirtualColumn(step.e1.vc_id);  
--------((TempTable *)ta[-step.t1.n - 1].get())->AddColumn(); 
----------TempTable::AddColumn
------------attrs.push_back(new Attr(e, mode, p_power, distinct, alias, -2, type, scale, precision, notnull,
                           e.vc ? e.vc->GetCollation() : DTCollation(), &si));  
                           
------case CompiledQuery::StepType::CREATE_VC: 
--------if (step.mysql_expr.size() > 0) {
----------MultiIndex *mind = (step.t2.n == step.t1.n) ? t->GetOutputMultiIndexP() : t->GetMultiIndexP();
----------int c = ((TempTable *)ta[-step.t1.n - 1].get())
                        ->AddVirtColumn(CreateColumnFromExpression(step.mysql_expr, t, step.t1.n, mind), step.a1.n);
------------Query::CreateColumnFromExpression
--------} else if (step.virt_cols.size() > 0) {
----------//-
--------else if (step.a2.n != common::NULL_VALUE_32) {
----------JustATable *t_src = ta[-step.t2.n - 1].get();//
----------MultiIndex *mind = (step.t2.n == step.t1.n) ? t->GetOutputMultiIndexP() : t->GetMultiIndexP();
------------filter.mind_; //output_mind区分。
----------phc = (PhysicalColumn *)t_src->GetColumn();//alias get column 0. a2.n=0.
------------TianmuTable::GetColumn
------------return m_attrs[col_no].get(); 
----------AddVirtColumn(new vcolumn::SingleColumn)//根据之前-3alias获取的column信息，在-2，TempTable中增加虚拟列。注意增加的是SingleColumn。
											                   //tempTable有virt_cols，还有attrs
                               
------case CompiledQuery::StepType::RESULT:
--------output_table = (TempTable *)ta[-step.t1.n - 1].get();
```



