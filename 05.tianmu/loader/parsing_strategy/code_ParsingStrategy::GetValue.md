#1.ParsingStrategy::GetValue

```
ParsingStrategy::GetValue
--ati = GetATI(col);
--if (isnull)
----//nothing
--else if (core::ATI::IsBinType(ati.Type())) 
----//nothing
--} else if (core::ATI::IsTxtType(ati.Type())) {
----//nothing
--} else {
----types::BString tmp_string(value_ptr, value_size);
----function = types::ValueParserForText::GetParsingFuntion(ati);
----function(tmp_string, *reinterpret_cast<int64_t *>(buffer.Prepare(sizeof(int64_t)))
------ValueParserForText::ParseNumeric
--------

```