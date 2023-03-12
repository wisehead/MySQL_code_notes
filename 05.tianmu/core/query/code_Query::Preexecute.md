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

------case CompiledQuery::StepType::ADD_CONDS: {
--------if (step.n1 != static_cast<int64_t>(CondType::HAVING_COND))
----------conds[step.c1.n]->Simplify();
--------AddConds
----------filter.AddConditions(cond, CondType::WHERE_COND);

------case CompiledQuery::StepType::APPLY_CONDS: {
--------ParameterizedFilter *filter = tb->GetFilterP();
--------


------case CompiledQuery::StepType::CREATE_VC: 
--------if (step.mysql_expr.size() > 0) {
----------MultiIndex *mind = (step.t2.n == step.t1.n) ? t->GetOutputMultiIndexP() : t->GetMultiIndexP();
--------} else if (step.virt_cols.size() > 0) {
--------else if (step.a2.n != common::NULL_VALUE_32) {
----------JustATable *t_src = ta[-step.t2.n - 1].get();
----------MultiIndex *mind = (step.t2.n == step.t1.n) ? t->GetOutputMultiIndexP() : t->GetMultiIndexP();
----------phc = (PhysicalColumn *)t_src->GetColumn();
----------AddVirtColumn(new vcolumn::SingleColumn)
                            
------case CompiledQuery::StepType::ADD_COLUMN: 
--------e.vc =((TempTable *)ta[-step.t1.n - 1].get())->GetVirtualColumn(step.e1.vc_id);  
--------((TempTable *)ta[-step.t1.n - 1].get())->AddColumn(); 
----------TempTable::AddColumn
------------attrs.push_back(new Attr(e, mode, p_power, distinct, alias, -2, type, scale, precision, notnull,
                           e.vc ? e.vc->GetCollation() : DTCollation(), &si));   
                                                 
------case CompiledQuery::StepType::APPLY_CONDS: 
--------
```