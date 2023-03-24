#1.LoadParser::MakeRow

```
LoadParser::MakeRow
--while (cont)
----strategy_->GetOneRow
----switch()//reset of GetOneRow
------case ParsingStrategy::ParseResult::OK: 
--------for (uint att = 0; make_value_ok && att < attrs_.size(); ++att)
----------LoadParser::MakeValue
```