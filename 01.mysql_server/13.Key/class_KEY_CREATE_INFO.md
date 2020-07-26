#1.class KEY_CREATE_INFO

```cpp
class KEY_CREATE_INFO {
 public:
  enum ha_key_alg algorithm = HA_KEY_ALG_SE_SPECIFIC;
  /**
    A flag which indicates that index algorithm was explicitly specified
    by user.
  */
  bool is_algorithm_explicit = false;
  ulong block_size = 0;
  LEX_CSTRING parser_name = {NullS, 0};
  LEX_CSTRING comment = {NullS, 0};
  bool is_visible = true;

  KEY_CREATE_INFO() = default;

  explicit KEY_CREATE_INFO(bool is_visible_arg) : is_visible(is_visible_arg) {}
};
```
