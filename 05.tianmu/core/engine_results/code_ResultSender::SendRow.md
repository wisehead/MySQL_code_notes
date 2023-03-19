#2.ResultSender::SendRow
```
ResultSender::SendRow
--if (!is_initialized) 
----owner->CreateDisplayableAttrP()
------TempTable::CreateDisplayableAttrP
----Init(owner);
------ResultSender::Init
--------res->send_result_set_metadata(fields, Protocol::SEND_NUM_ROWS | Protocol::SEND_EOF);
----------Query_result_send::send_result_set_metadata
--------scan_fields(fields, buf_lens, items_backup);
--if (owner && !owner->IsSent())
----owner->SetIsSent();
--thd->current_found_rows++;
--thd->update_previous_found_rows();
--SendRecord(record);
----ResultSender::SendRecord
--rows_sent++;

```

