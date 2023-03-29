#1.ColumnBinEncoder::PrepareEncoder

```
ColumnBinEncoder::PrepareEncoder
--ColumnType vct = vc->Type();
  ColumnType vct2 = _vc2 ? _vc2->Type() : ColumnType();
--if (vct.IsFixed() && (!_vc2 || (vct2.IsFixed() && vct.GetScale() == vct2.GetScale()))) {  // int/dec of the same scale
    my_encoder.reset(new ColumnBinEncoder::EncoderInt(vc, decodable, nulls_possible, descending));
  } else if (vct.IsFloat() || (_vc2 && vct2.IsFloat())) {
    my_encoder.reset(new ColumnBinEncoder::EncoderDouble(vc, decodable, nulls_possible, descending));
  } else if (vct.IsFixed() && !vct2.IsString()) {  // Decimals for different scale (the same
                                                   // scale is done by EncoderInt)
    my_encoder.reset(new ColumnBinEncoder::EncoderDecimal(vc, decodable, nulls_possible, descending));
  } else if (vct.GetTypeName() == common::ColumnType::DATE) {
    my_encoder.reset(new ColumnBinEncoder::EncoderDate(vc, decodable, nulls_possible, descending));
  } else if (vct.GetTypeName() == common::ColumnType::YEAR) {
    my_encoder.reset(new ColumnBinEncoder::EncoderYear(vc, decodable, nulls_possible, descending));
  } else if (!monotonic_encoding && vct.Lookup() && _vc2 == nullptr &&
             !types::RequiresUTFConversions(vc->GetCollation())) {  // Lookup encoding: only non-UTF
    my_encoder.reset(new ColumnBinEncoder::EncoderLookup(vc, decodable, nulls_possible, descending));
    lookup_encoder = true;
--} else if (!monotonic_encoding && vct.Lookup() && _vc2 != nullptr &&
             vct2.Lookup()) {  // Lookup in joining - may be UTF
    my_encoder.reset(new ColumnBinEncoder::EncoderLookup(vc, decodable, nulls_possible, descending));
    lookup_encoder = true;
--} else if (vct.IsString() || vct2.IsString()) {    
----DTCollation col_v1 = vc->GetCollation();
    DTCollation coll = col_v1;
    if (_vc2) {
      DTCollation col_v2 = _vc2->GetCollation();
      coll = types::ResolveCollation(col_v1, col_v2);
    }
----if (!noncomparable)  // noncomparable => non-sorted cols in sorter, don't UTF-encode.
------my_encoder.reset(new ColumnBinEncoder::EncoderText_UTF(vc, decodable, nulls_possible, descending));
--if (_vc2 != nullptr) {  
----bool encoding_possible = my_encoder->SecondColumn(_vc2);
--val_size = my_encoder->ValueSize();
--val_sec_size = my_encoder->ValueSizeSec();
--return true;
```