#1.MIUpdatingIterator::Commit

```
MIUpdatingIterator::Commit
--if (one_filter_dim > -1) {
----one_filter_it->CommitUpdate();  // working directly on multiindex filer // (special case)
------f->Commit()//Filter::Commit()
----if (recalculate_no_tuples)
------mind->UpdateNumOfTuples();  // not for parallel WHERE - shallow copy of
                                  // MultiIndex/Filter
```