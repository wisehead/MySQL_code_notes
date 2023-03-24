#2.TianmuTable::ProceedNormal

```
TianmuTable::ProceedNormal
--if (iop.LocalLoad())
----fs.reset(new system::NetStream(iop));
--while (no_of_rows_returned == to_prepare);
----to_prepare = share->PackSize() - (m_attrs[0]->NumOfObj() % share->PackSize());
----parser.GetPackrow(to_prepare, value_buffers);
```
