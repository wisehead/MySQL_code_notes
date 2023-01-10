#1.Query::Preexecute

```
Query::Preexecute
--std::vector<Condition *> conds(qu.NumOfConds());
--ta.resize(qu.NumOfTabs());
--global_limits = qu.GetGlobalLimit();
--for (int i = 0; i < qu.NumOfSteps(); i++)
----CompiledQuery::CQStep step = qu.Step(i);
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
------case CompiledQuery::StepType::CREATE_VC: 
--------else if (step.a2.n != common::NULL_VALUE_32) {
----------JustATable *t_src = ta[-step.t2.n - 1].get();
----------MultiIndex *mind = (step.t2.n == step.t1.n) ? t->GetOutputMultiIndexP() : t->GetMultiIndexP();
----------phc = (PhysicalColumn *)t_src->GetColumn(step.a2.n >= 0 ? step.a2.n : -step.a2.n - 1);
----------int c = ((TempTable *)ta[-step.t1.n - 1].get())
                        ->AddVirtColumn(
                            new vcolumn::SingleColumn(phc, mind, step.t2.n, step.a2.n, ta[-step.t2.n - 1].get(), dim),
                            step.a1.n);
------case CompiledQuery::StepType::ADD_COLUMN: 
--------e.vc =((TempTable *)ta[-step.t1.n - 1].get())->GetVirtualColumn(step.e1.vc_id);  
--------step.a1.n = ((TempTable *)ta[-step.t1.n - 1].get())->AddColumn(e, step.cop, step.alias, step.n1 ? true : false, step.si); 
----------TempTable::AddColumn
------------attrs.push_back(new Attr(e, mode, p_power, distinct, alias, -2, type, scale, precision, notnull,
                           e.vc ? e.vc->GetCollation() : DTCollation(), &si));                         
------case CompiledQuery::StepType::APPLY_CONDS: 
--------
```