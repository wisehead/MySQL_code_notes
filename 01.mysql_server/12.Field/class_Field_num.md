#1.Field_num

```cpp
class Field_num :public Field {
public:
  const uint8 dec;
  bool zerofill,unsigned_flag;  // Purify cannot handle bit fields
  Field_num(uchar *ptr_arg,uint32 len_arg, uchar *null_ptr_arg,
        uchar null_bit_arg, utype unireg_check_arg,
        const char *field_name_arg,
            uint8 dec_arg, bool zero_arg, bool unsigned_arg);
  Item_result result_type () const { return REAL_RESULT; }
  enum Derivation derivation(void) const { return DERIVATION_NUMERIC; }
  uint repertoire(void) const { return MY_REPERTOIRE_NUMERIC; }
  const CHARSET_INFO *charset(void) const { return &my_charset_numeric; }
  void prepend_zeros(String *value);
  void add_zerofill_and_unsigned(String &res) const;
  friend class Create_field;
  uint decimals() const { return (uint) dec; }
  bool eq_def(Field *field);
  type_conversion_status store_decimal(const my_decimal *);
  type_conversion_status store_time(MYSQL_TIME *ltime, uint8 dec);
  my_decimal *val_decimal(my_decimal *);
  bool get_date(MYSQL_TIME *ltime, uint fuzzydate);
  bool get_time(MYSQL_TIME *ltime);
  uint is_equal(Create_field *new_field);
  uint row_pack_length() const { return pack_length(); }
  uint32 pack_length_from_metadata(uint field_metadata) {
    uint32 length= pack_length();
    DBUG_PRINT("result", ("pack_length_from_metadata(%d): %u",
                          field_metadata, length));
    return length;
  }
  type_conversion_status check_int(const CHARSET_INFO *cs,
                                   const char *str, int length,
                                   const char *int_end, int error);
  type_conversion_status get_int(const CHARSET_INFO *cs,
                                 const char *from, uint len,
                                 longlong *rnd, ulonglong unsigned_max,
                                 longlong signed_min, longlong signed_max);
};
```
