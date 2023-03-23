#1.ParsingStrategy::SearchUnescapedPatternNoEOL

```
ParsingStrategy::SearchUnescapedPatternNoEOL
--if (size == 1) {
----while (ptr < search_end && *ptr != *c_pattern) {
------if (escape_char_ && *ptr == escape_char_)
--------ptr += 2;
------else if (DoubleEnclosedCharMatch(string_qualifier_, ptr, search_end))
--------ptr += 2;
------else if (*ptr == *c_eol && ptr + crlf <= buf_end && TailsMatch(ptr, c_eol, crlf))
--------return SearchResult::END_OF_LINE;
------else
--------++ptr;
--} else if (size == 2) {
----//nothing
--return (ptr < search_end) ? SearchResult::PATTERN_FOUND : SearchResult::END_OF_BUFFER;
```