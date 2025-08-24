#1.class KEY_PART_INFO

```cpp
class KEY_PART_INFO {   /* Info about a key part */
public:
  Field *field;
  uint  offset;             /* offset in record (from 0) */
  uint  null_offset;            /* Offset to null_bit in record */
  /* Length of key part in bytes, excluding NULL flag and length bytes */
  uint16 length;
  /*
    Number of bytes required to store the keypart value. This may be
    different from the "length" field as it also counts
     - possible NULL-flag byte (see HA_KEY_NULL_LENGTH)
     - possible HA_KEY_BLOB_LENGTH bytes needed to store actual value length.
  */
  uint16 store_length;
  uint16 key_type;
  uint16 fieldnr;           /* Fieldnum in UNIREG */
  uint16 key_part_flag;         /* 0 or HA_REVERSE_SORT */
  uint8 type;
  uint8 null_bit;           /* Position to null_bit */
  void init_from_field(Field *fld);     /** Fill data from given field */
  void init_flags();                    /** Set key_part_flag from field */
};

```