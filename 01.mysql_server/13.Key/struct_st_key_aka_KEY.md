#1.struct st_key

```cpp
typedef struct st_key {
  /** Tot length of key */
  uint	key_length;
  /** dupp key and pack flags */
  ulong flags;
  /** dupp key and pack flags for actual key parts */
  ulong actual_flags;
  /** How many key_parts */
  uint  user_defined_key_parts;
  /** How many key_parts including hidden parts */
  uint  actual_key_parts;
  /**
     Key parts allocated for primary key parts extension but
     not used due to some reasons(no primary key, duplicated key parts)
  */
  uint  unused_key_parts;
  /** Should normally be = key_parts */
  uint	usable_key_parts;
  uint  block_size;
  enum  ha_key_alg algorithm;
  /**
    Note that parser is used when the table is opened for use, and
    parser_name is used when the table is being created.
  */
  union
  {
    /** Fulltext [pre]parser */
    plugin_ref parser;
    /** Fulltext [pre]parser name */
    LEX_STRING *parser_name;
  };
  KEY_PART_INFO *key_part;
  /** Name of key */
  char	*name;

  /**
    Array of AVG(#records with the same field value) for 1st ... Nth key part.
    0 means 'not known'.
    For internally created temporary tables this member is NULL.
  */
  ulong *rec_per_key;

private:
  /**
    Estimate for how much of the index data that is currently
    available in a memory buffer. Valid range is [0..1]. This will be
    initialized to a IN_MEMORY_ESTIMATE_UNKNOWN. If it still has this
    value when used, it means that the storage engine has not supplied
    a value.
  */
  double m_in_memory_estimate;

  /**
    Array of AVG(#records with the same field value) for 1st ... Nth
    key part. For internally created temporary tables this member is
    NULL. This is the same information as stored in the above
    rec_per_key array but using float values instead of integer
    values. If the storage engine has supplied values in this array,
    these will be used. Otherwise the value in rec_per_key will be
    used.  @todo In the next release the rec_per_key array above
    should be removed and only this should be used.
  */
  rec_per_key_t *rec_per_key_float;
public:
  union {
    int  bdb_return_if_eq;
  } handler;
  TABLE *table;
  LEX_STRING comment;

  /** 
    Check if records per key estimate is available for given key part.

    @param key_part_no key part number, must be in [0, KEY::actual_key_parts)

    @return true if records per key estimate is available, false otherwise
  */

  bool has_records_per_key(uint key_part_no) const
  {
    assert(key_part_no < actual_key_parts);

    return ((rec_per_key_float && rec_per_key_float[key_part_no] !=
             REC_PER_KEY_UNKNOWN) || 
            (rec_per_key && rec_per_key[key_part_no] != 0));
  }

  /**
    Retrieve an estimate for the average number of records per distinct value,
    when looking only at the first key_part_no+1 columns.

    If no record per key estimate is available for this key part,
    REC_PER_KEY_UNKNOWN is returned.

    @param key_part_no key part number, must be in [0, KEY::actual_key_parts)

    @return Number of records having the same key value
      @retval REC_PER_KEY_UNKNOWN    no records per key estimate available
      @retval != REC_PER_KEY_UNKNOWN record per key estimate
  */

  rec_per_key_t records_per_key(uint key_part_no) const
  {
    assert(key_part_no < actual_key_parts);

    /*
      If the storage engine has provided rec per key estimates as float
      then use this. If not, use the integer version.
    */
    if (rec_per_key_float[key_part_no] != REC_PER_KEY_UNKNOWN)
      return rec_per_key_float[key_part_no];

    return (rec_per_key[key_part_no] != 0) ? 
      static_cast<rec_per_key_t>(rec_per_key[key_part_no]) :
      REC_PER_KEY_UNKNOWN;
  }

  /**
    Set the records per key estimate for a key part.

    The records per key estimate must be in [1.0,..> or take the value
    REC_PER_KEY_UNKNOWN.

    @param key_part_no     the number of key parts that the estimate includes,
                           must be in [0, KEY::actual_key_parts)
    @param rec_per_key_est new records per key estimate
  */

  void set_records_per_key(uint key_part_no, rec_per_key_t rec_per_key_est)
  {
    assert(key_part_no < actual_key_parts);
    assert(rec_per_key_est == REC_PER_KEY_UNKNOWN ||
           rec_per_key_est >= 1.0);
    assert(rec_per_key_float != NULL);

    rec_per_key_float[key_part_no]= rec_per_key_est;
  }

  /**
    Check if this key supports storing records per key information.

    @return true if it has support for storing records per key information,
            false otherwise.
  */

  bool supports_records_per_key() const
  {
    if (rec_per_key_float != NULL && rec_per_key != NULL)
      return true;

    return false;
  }

  /**
    Assign storage for the rec per key arrays to the KEY object.

    This is used when allocating memory and creating KEY objects. The
    caller is responsible for allocating the correct size for the
    two arrays. If needed, the caller is also responsible for
    de-allocating the memory when the KEY object is no longer used.

    @param rec_per_key_arg       pointer to allocated array for storing
                                 records per key using ulong
    @param rec_per_key_float_arg pointer to allocated array for storing
                                 records per key using float
  */

  void set_rec_per_key_array(ulong *rec_per_key_arg,
                             rec_per_key_t *rec_per_key_float_arg)
  {
    rec_per_key= rec_per_key_arg;
    rec_per_key_float= rec_per_key_float_arg;
  }

  /**
    Retrieve the estimate for how much of the index data that is available
    in a memory buffer.

    The returned estimate will be in the interval [0..1].

    @return Estimate for how much of index data is available in memory buffer
      @retval IN_MEMORY_ESTIMATE_UNKNOWN no estimate available
      @retval != IN_MEMORY_ESTIMATE_UNKNOWN estimate
  */

  double in_memory_estimate() const
  {
    assert(m_in_memory_estimate == IN_MEMORY_ESTIMATE_UNKNOWN ||
           (m_in_memory_estimate >= 0.0 && m_in_memory_estimate <= 1.0));

    return m_in_memory_estimate;
  }

  /**
    Set the estimate for how much of this index that is currently in a
    memory buffer.

    The estimate must be in the interval [0..1] or take the value
    IN_MEMORY_ESTIMATE_UNKNOWN.
  */

  void set_in_memory_estimate(double in_memory_estimate)
  {
    assert(in_memory_estimate == IN_MEMORY_ESTIMATE_UNKNOWN ||
           (in_memory_estimate >= 0.0 && in_memory_estimate <= 1.0));

    m_in_memory_estimate= in_memory_estimate;
  }
} KEY;


```