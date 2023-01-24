#1.class DimensionGroup

```cpp
class DimensionGroup {
 public:
  enum class DGType { DG_FILTER, DG_INDEX_TABLE, DG_VIRTUAL, DG_NOT_KNOWN } dim_group_type;

  class Iterator {
   public:
    // note: retrieving a value depends on DimensionGroup type
    Iterator() { valid = false; }
    Iterator(const Iterator &sec) { valid = sec.valid; }
    virtual ~Iterator(){};

    virtual void operator++() = 0;
    virtual void Rewind() = 0;
    virtual bool NextInsidePack() = 0;
    bool IsValid() const { return valid; }
    virtual int64_t GetPackSizeLeft() = 0;
    virtual bool WholePack(int dim) = 0;   // True, if the current packrow contain exactly the
                                           // whole pack for a dimension (no repetitions, no null
                                           // objects)
    virtual bool InsideOnePack() = 0;      // true if there is only one packrow possible for
                                           // dimensions in this iterator
    virtual bool NullsExist(int dim) = 0;  // return true if there exist any 0 value (always
                                           // false for virtual dimensions)
    virtual void NextPackrow() = 0;
    virtual int64_t GetCurPos(int dim) = 0;
    virtual int GetCurPackrow(int dim) = 0;
    virtual int GetNextPackrow(int dim,
                               int ahead) = 0;  // ahead = 1 => the next packrow
                                                // after this one, etc., return
                                                // -1 if not known
    virtual bool BarrierAfterPackrow() = 0;     // true, if we must synchronize
                                                // threads before NextPackrow()

    // Updating, if possible:
    virtual bool InternallyUpdatable() {
      return false;
    }                                      // true if the subclass implements in-group updating functions, like
                                           // below:
    virtual void ResetCurrent() {}         // reset the current position
    virtual void ResetCurrentPackrow() {}  // reset the whole current packrow
    virtual void CommitUpdate() {}         // commit the previous resets
    virtual void SetNoPacksToGo([[maybe_unused]] int n) {}
    virtual void RewindToRow([[maybe_unused]] int64_t n) {}
    virtual bool RewindToPack([[maybe_unused]] int pack) { return false; }  // true if the pack is nonempty
    virtual int NumOfOnesUncommited([[maybe_unused]] uint pack) { return -1; }
    // Extend the capability of splitting.
    virtual bool GetSlices([[maybe_unused]] std::vector<int64_t> *slices) const { return false; }

   protected:
    bool valid;
  };

 protected:
  int64_t no_obj;
  int locks;
};

```