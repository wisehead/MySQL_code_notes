#1.class TianmuAttr

```cpp
class TianmuAttr final : public mm::TraceableObject, public PhysicalColumn, public PackAllocator {
  friend class TianmuTable;
...
...
 private:
  COL_VER_HDR hdr{};
  common::TX_ID m_version;  // the read-from version
  Transaction *m_tx;
  int m_tid;
  int m_cid;
  ColumnShare *m_share;

  std::shared_ptr<FTree> m_dict;
  std::vector<common::PACK_INDEX> m_idx;

  bool no_change = true;
  uint64_t backup_auto_inc_next_{0};

  // local filters for write session
  std::shared_ptr<RSIndex_Hist> filter_hist;
  std::shared_ptr<RSIndex_CMap> filter_cmap;
  std::shared_ptr<RSIndex_Bloom> filter_bloom;

  std::shared_ptr<RSIndex_Hist> GetFilter_Hist();
  std::shared_ptr<RSIndex_CMap> GetFilter_CMap();
  std::shared_ptr<RSIndex_Bloom> GetFilter_Bloom();
  uint8_t pss;
  common::PackType pack_type;
  double rough_selectivity = -1;  // a probability that simple condition "c = 100" needs to open a data
                                  // pack, providing KNs etc.
  std::function<std::shared_ptr<RSIndex>(const FilterCoordinate &co)> filter_creator;
};  
```