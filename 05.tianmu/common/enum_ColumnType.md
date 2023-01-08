#1.enum ColumnType

```cpp
// Column Type
// NOTE: do not change the order of implemented data types! Stored as int(...)
// on disk.
enum class ColumnType : unsigned char {
  STRING,   // string treated either as dictionary value or "free" text
  VARCHAR,  // as above (discerned for compatibility with SQL)
  INT,      // integer 32-bit

  NUM,   // numerical: decimal, up to DEC(18,18)
  DATE,  // numerical (treated as integer in YYYYMMDD format)
  TIME,  // numerical (treated as integer in HHMMSS format)

  BYTEINT,   // integer 8-bit
  SMALLINT,  // integer 16-bit

  BIN,      // free binary (BLOB), no encoding
  BYTE,     // free binary, fixed size, no encoding
  VARBYTE,  // free binary, variable size, no encoding
  REAL,     // double (stored as non-interpreted int64_t, null value is
            // NULL_VALUE_64)
  DATETIME,
  TIMESTAMP,
  DATETIME_N,
  TIMESTAMP_N,
  TIME_N,

  FLOAT,
  YEAR,
  MEDIUMINT,
  BIGINT,
  LONGTEXT,
  UNK = 255
};
```