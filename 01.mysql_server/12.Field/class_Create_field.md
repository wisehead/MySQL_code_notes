#1.class Create_field

```cpp
/// Create_field is a description a field/column that may or may not exists in
/// a table.
///
/// The main usage of Create_field is to contain the description of a column
/// given by the user (usually given with CREATE TABLE). It is also used to
/// describe changes to be carried out on a column (usually given with ALTER
/// TABLE ... CHANGE COLUMN).
class Create_field {
 public:
  dd::Column::enum_hidden_type hidden;

  const char *field_name;
  /**
    Name of column modified by ALTER TABLE's CHANGE/MODIFY COLUMN clauses,
    NULL for columns added.
  */
  const char *change;
  const char *after;    // Put column after this one
  LEX_CSTRING comment;  // Comment for field

  /**
     The declared default value, if any, otherwise NULL. Note that this member
     is NULL if the default is a function. If the column definition has a
     function declared as the default, the information is found in
     Create_field::auto_flags.

     @see Create_field::auto_flags
  */
  Item *constant_default;
  enum_field_types sql_type;
  uint decimals;
  uint flags{0};
  /**
    Bitmap of flags indicating if field value should be auto-generated
    by default and/or on update, and in which way.

    @sa Field::enum_auto_flags for possible options.
  */
  uchar auto_flags{Field::NONE};
  TYPELIB *interval;  // Which interval to use
                      // Used only for UCS2 intervals
  List<String> interval_list;
  const CHARSET_INFO *charset;
  bool is_explicit_collation;  // User exeplicitly provided charset ?
  Field::geometry_type geom_type;
  Field *field;  // For alter table

  uint offset;

  /**
    Indicate whether column is nullable, zerofill or unsigned.

    Initialized based on flags and other members at prepare_create_field()/
    init_for_tmp_table() stage.
  */
  bool maybe_null;
  bool is_zerofill;
  bool is_unsigned;

  /**
    Indicates that storage engine doesn't support optimized BIT field
    storage.

    @note We also use safe/non-optimized version of BIT field for
          special cases like virtual temporary tables.

    Initialized at mysql_prepare_create_table()/sp_prepare_create_field()/
    init_for_tmp_table() stage.
  */
  bool treat_bit_as_char;

  /**
    Row based replication code sometimes needs to create ENUM and SET
    fields with pack length which doesn't correspond to number of
    elements in interval TYPELIB.

    When this member is non-zero ENUM/SET field to be created will use
    its value as pack length instead of one calculated from number
    elements in its interval.

    Initialized at prepare_create_field()/init_for_tmp_table() stage.
  */
  uint pack_length_override{0};

  /* Generated column expression information */
  Value_generator *gcol_info{nullptr};
  /*
    Indication that the field is phycically stored in tables
    rather than just generated on SQL queries.
    As of now, false can only be set for virtual generated columns.
  */
  bool stored_in_db;

  /// Holds the expression to be used to generate default values.
  Value_generator *m_default_val_expr{nullptr};
  Nullable<gis::srid_t> m_srid;

  // Whether the field is actually an array of the field's type;
  bool is_array{false};
  
  
  
  
 private:
  /// The maximum display width of this column.
  ///
  /// The "display width" is the number of code points that is needed to print
  /// out the string represenation of a value. It can be given by the user
  /// both explicitly and implicitly. If a user creates a table with the columns
  /// "a VARCHAR(3), b INT(3)", both columns are given an explicit display width
  /// of 3 code points. But if a user creates a table with the columns
  /// "a INT, b TINYINT UNSIGNED", the first column has an implicit display
  /// width of 11 (-2147483648 is the longest value for a signed int) and the
  /// second column has an implicit display width of 3 (255 is the longest value
  /// for an unsigned tinyint).
  /// This is related to storage size for some types (VARCHAR, BLOB etc), but
  /// not for all types (an INT is four bytes regardless of the display width).
  ///
  /// A "code point" is bascially a numeric value. For instance, ASCII
  /// compromises of 128 code points (0x00 to 0x7F), while unicode contains way
  /// more. In most cases a code point represents a single graphical unit (aka
  /// grapheme), but not always. For instance, É may consists of two code points
  /// where one is the letter E and the other one is the quotation mark above
  /// the letter.
  size_t m_max_display_width_in_codepoints{0};

  /// Whether or not the display width was given explicitly by the user.
  bool m_explicit_display_width{false};

  /// The maximum number of bytes a TINYBLOB can hold.
  static constexpr size_t TINYBLOB_MAX_SIZE_IN_BYTES{255};

  /// The maximum number of bytes a BLOB can hold.
  static constexpr size_t BLOB_MAX_SIZE_IN_BYTES{65535};

  /// The maximum number of bytes a MEDIUMBLOB can hold.
  static constexpr size_t MEDIUMBLOB_MAX_SIZE_IN_BYTES{16777215};

  /// The maximum number of bytes a LONGBLOB can hold.
  static constexpr size_t LONGBLOB_MAX_SIZE_IN_BYTES{4294967295};
};  
         
```