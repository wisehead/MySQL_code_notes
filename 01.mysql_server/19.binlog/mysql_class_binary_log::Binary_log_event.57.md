#1.binary_log::Binary_log_event

```cpp
/**
    This is the abstract base class for binary log events.

  @section Binary_log_event_binary_format Binary Format

  @anchor Binary_log_event_format
  Any @c Binary_log_event saved on disk consists of the following four
  components.

  - Common-Header
  - Post-Header
  - Body
  - Footer

  Common header has the same format and length in a given MySQL version. It is
  documented @ref Table_common_header "here".

  The Body may be of different format and length even for different events of
  the same type. The binary formats of Post-Header and Body are documented
  separately in each subclass.

  Footer is common to all the events in a given MySQL version. It is documented
  @ref Table_common_footer "here".

  @anchor packed_integer
  - Some events, used for RBR use a special format for efficient representation
  of unsigned integers, called Packed Integer.  A Packed Integer has the
  capacity of storing up to 8-byte integers, while small integers
  still can use 1, 3, or 4 bytes.  The value of the first byte
  determines how to read the number, according to the following table:

  <table>
  <caption>Format of Packed Integer</caption>

  <tr>
    <th>First byte</th>
    <th>Format</th>
  </tr>

  <tr>
    <td>0-250</td>
    <td>The first byte is the number (in the range 0-250), and no more
    bytes are used.</td>
  </tr>

  <tr>
    <td>252</td>
    <td>Two more bytes are used.  The number is in the range
    251-0xffff.</td>
  </tr>

  <tr>
    <td>253</td>
    <td>Three more bytes are used.  The number is in the range
    0xffff-0xffffff.</td>
  </tr>

  <tr>
    <td>254</td>
    <td>Eight more bytes are used.  The number is in the range
    0xffffff-0xffffffffffffffff.</td>
  </tr>

  </table>

  - Strings are stored in various formats.  The format of each string
  is documented separately.
  

*/
class Binary_log_event
{
public:

  /*
     The number of types we handle in Format_description_event (UNKNOWN_EVENT
     is not to be handled, it does not exist in binlogs, it does not have a
     format).
  */
  static const int LOG_EVENT_TYPES= (ENUM_END_EVENT - 1);
private:
  Log_event_header m_header;
  Log_event_footer m_footer;
};
```