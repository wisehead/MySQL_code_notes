#1.AggregationAlgorithm::AggregatePackrow

```
AggregationAlgorithm::AggregatePackrow
--packrow_length = mit->GetPackSizeLeft();
--if (!gbw.AnyTuplesLeft(cur_tuple, cur_tuple + packrow_length - 1)) {
----//--
--if (require_locking_gr) {
----for (int gr_a = 0; gr_a < gbw.NumOfGroupingAttrs(); gr_a++)
------gbw.LockPackAlways(gr_a, *mit);  // note: ColumnNotOmitted checked inside
--if (require_locking_ag) {
----//-
--gbw.ResetPackrow();
--rows_in_pack = gbw.TuplesLeftBetween(cur_tuple, cur_tuple + packrow_length - 1);
--skip_packrow = AggregateRough(gbw, *mit, packrow_done, part_omitted, aggregations_not_changeable, stop_all,
                                uniform_pos, rows_in_pack, factor);
--while (mit->IsValid()) {  // becomes invalid on pack end
----if (gbw.TuplesGet(cur_tuple)) {
------for (int gr_a = 0; gr_a < gbw.NumOfGroupingAttrs(); gr_a++)
--------if (gbw.ColumnNotOmitted(gr_a))
----------gbw.PutGroupingValue(gr_a, *mit);
------existed = gbw.FindCurrentRow(pos);
```