#1.class Cost_estimate

```cpp
/**
  Used to store optimizer cost estimates.

  The class consists of PODs only: default operator=, copy constructor
  and destructor are used.
 */
class Cost_estimate
{ 
private:
  double io_cost;                               ///< cost of I/O operations
  double cpu_cost;                              ///< cost of CPU operations
  double import_cost;                           ///< cost of remote operations
  double mem_cost;                              ///< memory used (bytes)
  
public:
  Cost_estimate() :
    io_cost(0),
    cpu_cost(0),
    import_cost(0),
    mem_cost(0)
  {}

  /// Returns sum of time-consuming costs, i.e., not counting memory cost
  double total_cost() const  { return io_cost + cpu_cost + import_cost; }
  double get_io_cost()     const { return io_cost; }
  double get_cpu_cost()    const { return cpu_cost; }
  double get_import_cost() const { return import_cost; }
  double get_mem_cost()    const { return mem_cost; }

  /**
    Whether or not all costs in the object are zero
    
    @return true if all costs are zero, false otherwise
  */
  bool is_zero() const
  { 
    return !(io_cost || cpu_cost || import_cost || mem_cost);
  }
  /**
    Whether or not the total cost is the maximal double
    
    @return true if total cost is the maximal double, false otherwise
  */
  bool is_max_cost()  const { return io_cost == DBL_MAX; }
  /// Reset all costs to zero
  void reset()
  {
    io_cost= cpu_cost= import_cost= mem_cost= 0;
  }
  /// Set current cost to the maximal double
  void set_max_cost()
  {
    reset();
    io_cost= DBL_MAX;
  }

  /// Multiply io, cpu and import costs by parameter
  void multiply(double m)
  {
    assert(!is_max_cost());

    io_cost *= m;
    cpu_cost *= m;
    import_cost *= m;
    /* Don't multiply mem_cost */
  }

  Cost_estimate& operator+= (const Cost_estimate &other)
  {
    assert(!is_max_cost() && !other.is_max_cost());

    io_cost+= other.io_cost;
    cpu_cost+= other.cpu_cost;
    import_cost+= other.import_cost;
    mem_cost+= other.mem_cost;

    return *this;
  }

  Cost_estimate operator+ (const Cost_estimate &other)
  {
    Cost_estimate result= *this;
    result+= other;

    return result;
  }

  Cost_estimate operator- (const Cost_estimate &other)
  {
    Cost_estimate result;

    assert(!other.is_max_cost());

    result.io_cost= io_cost - other.io_cost;
    result.cpu_cost= cpu_cost - other.cpu_cost;
    result.import_cost= import_cost - other.import_cost;
    result.mem_cost= mem_cost - other.mem_cost;
    return result;
  }

  bool operator> (const Cost_estimate &other) const
  {
    return total_cost() > other.total_cost() ? true : false;
  }

  bool operator< (const Cost_estimate &other) const
  {
    return other > *this ? true : false;
  }

  /// Add to IO cost
  void add_io(double add_io_cost)
  {
    assert(!is_max_cost());
    io_cost+= add_io_cost;
  }

  /// Add to CPU cost
  void add_cpu(double add_cpu_cost)
  {
    assert(!is_max_cost());
    cpu_cost+= add_cpu_cost;
  }

  /// Add to import cost
  void add_import(double add_import_cost)
  {
    assert(!is_max_cost());
    import_cost+= add_import_cost;
  }

  /// Add to memory cost
  void add_mem(double add_mem_cost)
  {
    assert(!is_max_cost());
    mem_cost+= add_mem_cost;
  }
};

```