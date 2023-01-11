#1.AggregationWorkerEnt::TaskAggrePacks

```
AggregationWorkerEnt::TaskAggrePacks
--taskIterator->Rewind();
--while (taskIterator->IsValid())
----if ((task_pack_num >= task->dwStartPackno) && (task_pack_num <= task->dwEndPackno))
------int cur_tuple = (*task->dwPack2cur)[task_pack_num];
------aa->AggregatePackrow(*gbw, &mii, cur_tuple);
----taskIterator->NextPackrow();
----++task_pack_num;
```