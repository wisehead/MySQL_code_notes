#1.ParallelHashJoiner::AddKeyColumn

```
ParallelHashJoiner::AddKeyColumn
--size_t column_index = column_bin_encoder_.size();
--column_bin_encoder_.push_back(ColumnBinEncoder(ColumnBinEncoder::ENCODER_IGNORE_NULLS));
--vcolumn::VirtualColumn *second_column =
      (vc->Type().GetTypeName() == common::ColumnType::TIMESTAMP) ? nullptr : vc_matching;
--      
```