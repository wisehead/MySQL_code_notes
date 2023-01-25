#1.class DimensionGroupFilter

```cpp
class DimensionGroupFilter : public DimensionGroup {
 public:

  class DGFilterIterator : public DimensionGroup::Iterator {
   public:
    DGFilterIterator(Filter *f_to_iterate, uint32_t power) : fi(f_to_iterate, power), f(f_to_iterate) {
      valid = !f->IsEmpty();
    }
    DGFilterIterator(const Iterator &sec, uint32_t power);

    void operator++() override {
      DEBUG_ASSERT(valid);
      ++fi;
      valid = fi.IsValid();
    }
    void Rewind() override {
      fi.Rewind();
      valid = fi.IsValid();
    }
    bool NextInsidePack() override {
      bool r = fi.NextInsidePack();
      valid = fi.IsValid();
      return r;
    }
    int64_t GetPackSizeLeft() override { return fi.GetPackSizeLeft(); }
    bool WholePack([[maybe_unused]] int dim) override { return f->IsFull(fi.GetCurrPack()); }
    bool InsideOnePack() override { return fi.InsideOnePack(); }
    bool NullsExist([[maybe_unused]] int dim) override { return false; }
    void NextPackrow() override {
      DEBUG_ASSERT(valid);
      fi.NextPack();
      valid = fi.IsValid();
    }
    int GetCurPackrow([[maybe_unused]] int dim) override { return fi.GetCurrPack(); }
    int64_t GetCurPos([[maybe_unused]] int dim) override { return (*fi); }
    int GetNextPackrow([[maybe_unused]] int dim, int ahead) override { return fi.Lookahead(ahead); }
    bool BarrierAfterPackrow() override { return false; }
    // Updating
    bool InternallyUpdatable() override { return true; }
    void ResetCurrent() override { fi.ResetDelayed(); }
    void ResetCurrentPackrow() override { fi.ResetCurrentPackrow(); }
    void CommitUpdate() override { f->Commit(); }
    void SetNoPacksToGo(int n) override { fi.SetNoPacksToGo(n); }
    void RewindToRow(int64_t n) override {
      fi.RewindToRow(n);
      valid = fi.IsValid();
    }
    bool RewindToPack(int pack) override {
      bool r = fi.RewindToPack(pack);
      valid = fi.IsValid();
      return r;
    }

    bool GetSlices(std::vector<int64_t> *slices) const override {
      slices->resize(fi.GetPackCount(), 1 << fi.GetPackPower());
      return true;
    }

    int NumOfOnesUncommited(uint pack) override { return f->NumOfOnesUncommited(pack); }
    virtual bool Ordered() { return false; }  // check if it is an ordered iterator
   private:
    FilterOnesIterator fi;
    // external pointer:
    Filter *f;
  };

  class DGFilterOrderedIterator : public DimensionGroup::Iterator {
   public:
    DGFilterOrderedIterator(Filter *f_to_iterate, PackOrderer *po, uint32_t power)
        : fi(f_to_iterate, po, power), f(f_to_iterate) {
      valid = !f->IsEmpty();
    }
    DGFilterOrderedIterator(const Iterator &sec, uint32_t power);

    void operator++() override {
      DEBUG_ASSERT(valid);
      ++fi;
      valid = fi.IsValid();
    }
    void Rewind() override {
      fi.Rewind();
      valid = fi.IsValid();
    }
    bool NextInsidePack() override {
      bool r = fi.NextInsidePack();
      valid = fi.IsValid();
      return r;
    }
    int64_t GetPackSizeLeft() override { return fi.GetPackSizeLeft(); }
    bool WholePack([[maybe_unused]] int dim) override { return f->IsFull(fi.GetCurrPack()); }
    bool InsideOnePack() override { return fi.InsideOnePack(); }
    bool NullsExist([[maybe_unused]] int dim) override { return false; }
    void NextPackrow() override {
      DEBUG_ASSERT(valid);
      fi.NextPack();
      valid = fi.IsValid();
    }
    int GetCurPackrow([[maybe_unused]] int dim) override { return fi.GetCurrPack(); }
    int64_t GetCurPos([[maybe_unused]] int dim) override { return (*fi); }
    int GetNextPackrow([[maybe_unused]] int dim, int ahead) override { return fi.Lookahead(ahead); }
    bool BarrierAfterPackrow() override { return (fi.NaturallyOrdered() == false); }
    // Updating
    bool InternallyUpdatable() override { return true; }
    void ResetCurrent() override { fi.ResetDelayed(); }
    void ResetCurrentPackrow() override { fi.ResetCurrentPackrow(); }
    void CommitUpdate() override { f->Commit(); }
    void SetNoPacksToGo(int n) override { fi.SetNoPacksToGo(n); }
    void RewindToRow(int64_t n) override {
      fi.RewindToRow(n);
      valid = fi.IsValid();
    }
    bool RewindToPack(int pack) override {
      bool r = fi.RewindToPack(pack);
      valid = fi.IsValid();
      return r;
    }

    bool GetSlices(std::vector<int64_t> *slices) const override {
      slices->resize(fi.GetPackCount(), 1 << fi.GetPackPower());
      return true;
    }

    int NumOfOnesUncommited(uint pack) override { return f->NumOfOnesUncommited(pack); }
    virtual bool Ordered() { return true; }  // check if it is an ordered iterator
   private:
    FilterOnesIteratorOrdered fi;
    // external pointer:
    Filter *f;
  };


 private:
  int base_dim;
  Filter *f;
};
```