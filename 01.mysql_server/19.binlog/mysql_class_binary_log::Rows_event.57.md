#1.Rows_event

```cpp
/**
  @class Rows_event

 Common base class for all row-containing binary log events.

 RESPONSIBILITIES

   - Provide an interface for adding an individual row to the event.

  @section Rows_event_binary_format Binary Format

  The Post-Header has the following components:

  <table>
  <caption>Post-Header for Rows_event</caption>

  <tr>
    <th>Name</th>
    <th>Format</th>
    <th>Description</th>
  </tr>

  <tr>
    <td>table_id</td>
    <td>6 bytes unsigned integer</td>
    <td>The number that identifies the table</td>
  </tr>

  <tr>
    <td>flags</td>
    <td>2 byte bitfield</td>
    <td>Reserved for future use; currently always 0.</td>
  </tr>

  </table>

  The Body has the following components:

  <table>
  <caption>Body for Rows_event</caption>

  <tr>
    <th>Name</th>
    <th>Format</th>
    <th>Description</th>
  </tr>


  <tr>
    <td>var_header_len</td>
    <td>packed integer</td>
    <td>Represents the number of columns in the table</td>
  </tr>

  <tr>
    <td>width</td>
    <td>Bitfield, variable sized</td>
    <td>Indicates whether each column is used, one bit per column.
        For this field, the amount of storage required for N columns
        is INT((N + 7) / 8) bytes. </td>
  </tr>

  <tr>
    <td>extra_row_data</td>
    <td>unsigned char pointer</td>
    <td>Pointer to extra row data if any. If non null, first byte is length</td>
  </tr>
  <tr>
    <td>columns_before_image</td>
    <td>vector of elements of type uint8_t</td>
    <td>Bit-field indicating whether each column is used
        one bit per column. For this field, the amount of storage
        required for N columns is INT((N + 7) / 8) bytes.</td>
  </tr>

  <tr>
    <td>columns_after_image</td>
    <td>vector of elements of type uint8_t</td>
    <td>variable-sized (for UPDATE_ROWS_EVENT only).
        Bit-field indicating whether each column is used in the
        UPDATE_ROWS_EVENT and WRITE_ROWS_EVENT after-image; one bit per column.
        For this field, the amount of storage required for N columns
        is INT((N + 7) / 8) bytes.

        @verbatim
          +-------------------------------------------------------+
          | Event Type | Cols_before_image | Cols_after_image     |
          +-------------------------------------------------------+
          |  DELETE    |   Deleted row     |    NULL              |
          |  INSERT    |   NULL            |    Inserted row      |
          |  UPDATE    |   Old     row     |    Updated row       |
          +-------------------------------------------------------+
        @end verbatim
    </td>
  </tr>

  <tr>
    <td>row</td>
    <td>vector of elements of type uint8_t</td>
    <td> A sequence of zero or more rows. The end is determined by the size
         of the event. Each row has the following format:
           - A Bit-field indicating whether each field in the row is NULL.
             Only columns that are "used" according to the second field in
             the variable data part are listed here. If the second field in
             the variable data part has N one-bits, the amount of storage
             required for this field is INT((N + 7) / 8) bytes.
           - The row-image, containing values of all table fields. This only
             lists table fields that are used (according to the second field
             of the variable data part) and non-NULL (according to the
             previous field). In other words, the number of values listed here
             is equal to the number of zero bits in the previous field.
             (not counting padding bits in the last byte).
             @verbatim
                For example, if a INSERT statement inserts into 4 columns of a
                table, N= 4 (in the formula above).
                length of bitmask= (4 + 7) / 8 = 1
                Number of fields in the row= 4.

                        +------------------------------------------------+
                        |Null_bit_mask(4)|field-1|field-2|field-3|field 4|
                        +------------------------------------------------+
             @endverbatim
    </td>
  </tr>
*/
class Rows_event: public Binary_log_event
{
protected:
  Log_event_type  m_type;     /** Actual event type */

  /** Post header content */
  Table_id m_table_id;
  uint16_t m_flags;           /** Flags for row-level events */

  /* Body of the event */
  unsigned long m_width;      /** The width of the columns bitmap */
  uint32_t n_bits_len;        /** value determined by (m_width + 7) / 8 */
  uint16_t var_header_len;

  unsigned char* m_extra_row_data;

  std::vector<uint8_t> columns_before_image;
  std::vector<uint8_t> columns_after_image;
  std::vector<uint8_t> row;
  template <class Iterator_value_type> friend class Row_event_iterator;
};

```