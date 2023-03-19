#1.TempTable::CreateDisplayableAttrP

```
TempTable::CreateDisplayableAttrP
--displayable_attr.clear();
--displayable_attr.resize(attrs.size());
--int idx = 0;
--for (size_t i = 0; i < attrs.size(); i++) {
    if (attrs[i]->alias) {
      displayable_attr[idx] = attrs[i];
      idx++;
    }
  }
--for (uint i = idx; i < attrs.size(); i++) displayable_attr[i] = nullptr;
```