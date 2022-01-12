#1. show_readview_gtid

```cpp
show_readview_gtid
--
```

#2. Gtid_info
```cpp
/** Serialized GTID */
using Gtid_info = std::array<unsigned char, GTID_INFO_SIZE>;

/** List of GTIDs */
using Gitd_info_list = std::vector<Gtid_info>;

/** GTID descriptor with version information. */
struct Gtid_desc {
  /** If GTID descriptor is set. */
  bool m_is_set;
  /** Serialized GTID information. */
  Gtid_info m_info;
  /* GTID version. */
  uint32_t m_version;
};
```

#3.slave_latest_gtid_info