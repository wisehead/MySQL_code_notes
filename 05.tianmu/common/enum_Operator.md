#1.enum Operator

```cpp
/**
        The types of support SQL query operators.

        The order of these enumerated values is important and
        relevent to the Descriptor class for the time being.
        Any changes made here must also be reflected in the
        Descriptor class' interim createQueryOperator() member.
 */
enum class Operator {
  O_EQ = 0,
  O_EQ_ALL,
  O_EQ_ANY,
  O_NOT_EQ,
  O_NOT_EQ_ALL,
  O_NOT_EQ_ANY,
  O_LESS,
  O_LESS_ALL,
  O_LESS_ANY,
  O_MORE,
  O_MORE_ALL,
  O_MORE_ANY,
  O_LESS_EQ,
  O_LESS_EQ_ALL,
  O_LESS_EQ_ANY,
  O_MORE_EQ,
  O_MORE_EQ_ALL,
  O_MORE_EQ_ANY,

  O_IS_NULL,
  O_NOT_NULL,
  O_BETWEEN,
  O_NOT_BETWEEN,
  O_LIKE,
  O_NOT_LIKE,
  O_IN,
  O_NOT_IN,
  O_EXISTS,
  O_NOT_EXISTS,

  O_FALSE,
  O_TRUE,     // constants
  O_ESCAPE,   // O_ESCAPE is special terminating value, do not interpret
  O_OR_TREE,  // fake operator indicating complex descriptor

  // below operators correspond to MySQL special operators used in MySQL
  // expression tree
  O_MULT_EQUAL_FUNC,  // a=b=c
  O_NOT_FUNC,         // NOT
  O_NOT_ALL_FUNC,     //
  O_UNKNOWN_FUNC,     //
  O_ERROR,            // undefined operator

  /**
  Enumeration member count.
  This should always be the last member.  It's a count of
  the elements in this enumeration and can be used for both
  compiled-time and run-time bounds checking.
  */
  OPERATOR_ENUM_COUNT
};

```