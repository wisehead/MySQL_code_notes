#1.Descriptor::EvaluatePack

```
Descriptor::EvaluatePack
--if (GetParallelSize() == 0)
----LockSourcePacks
------if (attr.vc)
--------attr.vc->LockSourcePacks(mit);//VirtualColumn::LockSourcePacks
----------vc_pack_guard_.LockPackrow(mit); //VCPackGuardian::LockPackrow
```