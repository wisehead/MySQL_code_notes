#1.class JustATable

```cpp
class JustATable : public std::enable_shared_from_this<JustATable> {
 public:
  static unsigned PackIndex(int64_t obj, uint32_t power) {
    return (obj == common::NULL_VALUE_64 ? 0xFFFFFFFF : (unsigned)(obj >> power));
  }  // null pack number (interpreted properly)
  virtual void LockPackForUse(unsigned attr, unsigned pack_no) = 0;
  virtual void UnlockPackFromUse(unsigned attr, unsigned pack_no) = 0;
  virtual int64_t NumOfObj() = 0;
  virtual uint NumOfAttrs() const = 0;
  virtual uint NumOfDisplaybleAttrs() const = 0;
  virtual TType TableType() const = 0;

  virtual int64_t GetTable64(int64_t obj, int attr) = 0;
  virtual void GetTable_S(types::BString &s, int64_t obj, int attr) = 0;

  virtual bool IsNull(int64_t obj, int attr) = 0;

  virtual uint MaxStringSize(int n_a, Filter *f = nullptr) = 0;

  virtual std::vector<AttributeTypeInfo> GetATIs(bool orig = false) = 0;

  virtual PhysicalColumn *GetColumn(int col_no) = 0;

  virtual const ColumnType &GetColumnType(int n_a) = 0;
  virtual uint32_t Getpackpower() const = 0;
  //! Returns column value in the form required by complex expressions
  ValueOrNull GetComplexValue(const int64_t obj, const int attr);

  virtual ~JustATable(){};
};
```