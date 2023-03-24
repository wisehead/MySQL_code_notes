#1.LoadParser::MakeRow

```
LoadParser::MakeRow
--while (cont)
----strategy_->GetOneRow
----switch()//reset of GetOneRow
------case ParsingStrategy::ParseResult::OK: 
--------for (uint att = 0; make_value_ok && att < attrs_.size(); ++att)
----------LoadParser::MakeValue
--------for (uint att = 0; att < attrs_.size(); ++att) {
----------value_buffers[att].Commit();
--------io_param_.GetTHD()->get_stmt_da()->inc_current_row_for_condition();
--------if (num_of_skip_ < io_param_.GetSkipLines()) /*check skip lines */
----------//null
--------} else if (tab_index_ != nullptr) { /* check duplicate */
----------//null
--------return true;
```