(comment) @comment

[(quoted_string) (triple_quoted_string)] @string

((simple_directive name: (bare_argument) @function)
  (#match? @function "^[A-Za-z_][A-Za-z0-9_-]*$"))
((block_directive name: (bare_argument) @function)
  (#match? @function "^[A-Za-z_][A-Za-z0-9_-]*$"))

; Keep these patterns compatible with both Vim's and Tree-sitter's regex engines.
; They recognize ordinary numbers, unit suffixes, and a leading decimal point.
((bare_argument) @number
  (#match? @number "^[-+]*[0-9][0-9_A-Za-z.]*$"))
((bare_argument) @number
  (#match? @number "^[-+]*[.][0-9][0-9_A-Za-z]*$"))
((bare_argument) @number
  (#match? @number "^[-+]*[0-9][0-9_.]*[eE][-+][0-9][0-9_]*$"))
((bare_argument) @number
  (#match? @number "^[-+]*[.][0-9][0-9_]*[eE][-+][0-9][0-9_]*$"))

((bare_argument) @operator
  (#any-of? @operator "+" "-" "*" "/" "==" "!=" "<=" ">=" "<" ">" "&&" "||"))

["{" "}"] @punctuation.bracket
";" @punctuation.delimiter
