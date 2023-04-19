#1.AggregationAlgorithm::AggregatePackrow

```
AggregationAlgorithm::AggregatePackrow
--packrow_length = mit->GetPackSizeLeft();
--if (!gbw.AnyTuplesLeft(cur_tuple, cur_tuple + packrow_length - 1)) {
----//--
--if (require_locking_gr) {
----for (int gr_a = 0; gr_a < gbw.NumOfGroupingAttrs(); gr_a++)
------gbw.LockPackAlways(gr_a, *mit);  // note: ColumnNotOmitted checked inside
```