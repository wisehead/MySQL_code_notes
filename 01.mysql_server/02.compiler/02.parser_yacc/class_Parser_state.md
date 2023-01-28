#1.class Parser_state

```cpp
/**
  Internal state of the parser.
  The complete state consist of:
  - state data used during lexical parsing,
  - state data used during syntactic parsing.
*/
class Parser_state
{
public:
  Parser_state()
    : m_yacc()
  {}

  /**
     Object initializer. Must be called before usage.

     @retval FALSE OK
     @retval TRUE  Error
  */
  bool init(THD *thd, char *buff, unsigned int length)
  {
    return m_lip.init(thd, buff, length);
  }

  ~Parser_state()
  {}

  Lex_input_stream m_lip;
  Yacc_state m_yacc;

  void reset(char *found_semicolon, unsigned int length)
  {
    m_lip.reset(found_semicolon, length);
    m_yacc.reset();
  }
};
```