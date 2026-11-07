#include <stdbool.h>
#include <stdint.h>
#include <tree_sitter/parser.h>

enum TokenType {
  QUOTED_STRING,
  TRIPLE_QUOTED_STRING,
};

// Confetti permits escaped punctuation and continuation lines inside strings.
static bool is_line_terminator(int32_t c) {
  return (
    c == '\n' ||
    c == '\r' ||
    c == '\v' ||
    c == '\f' ||
    c == 0x85 || // U+0085 NEXT LINE (NEL)
    c == 0x2028 || // U+2028 LINE SEPARATOR (LS)
    c == 0x2029 // U+2029 PARAGRAPH SEPARATOR (PS)
  );
}

// Check whether a Unicode character is whitespace but not a line terminator.
static bool is_non_line_terminating_space(int32_t c) {
  return (
    c == ' ' ||
    c == '\t' ||
    c == 0xa0 || // U+00A0 NO-BREAK SPACE
    c == 0x1680 || // U+1680 OGHAM SPACE MARK
    (c >= 0x2000 && c <= 0x200a) || // U+2000–U+200A Unicode spaces
    c == 0x202f || // U+202F NARROW NO-BREAK SPACE
    c == 0x205f || // U+205F MEDIUM MATHEMATICAL SPACE
    c == 0x3000 // U+3000 IDEOGRAPHIC SPACE
  );
}

static bool scan_escape(TSLexer *lexer) {
  lexer->advance(lexer, false); // Consume the backslash.
  if (lexer->eof(lexer)) return false;
  if (is_non_line_terminating_space(lexer->lookahead)) return false;

  int32_t escaped = lexer->lookahead;
  lexer->advance(lexer, false);
  if (escaped == '\r' && lexer->lookahead == '\n')
    lexer->advance(lexer, false);
  return true;
}

static bool scan_string(TSLexer *lexer, bool triple) {
  while (!lexer->eof(lexer)) {
    int32_t c = lexer->lookahead;
    if (c == '\\') {
      if (!scan_escape(lexer)) return false;
      continue;
    }
    if (c == '"') {
      lexer->advance(lexer, false);
      if (!triple) {
        lexer->mark_end(lexer);
        return true;
      }

      unsigned quotes = 1;
      while (quotes < 3 && lexer->lookahead == '"') {
        lexer->advance(lexer, false);
        quotes++;
      }
      if (quotes == 3) {
        lexer->mark_end(lexer);
        return true;
      }
      continue;
    }
    if (!triple && is_line_terminator(c)) return false;
    lexer->advance(lexer, false);
  }
  return false;
}

void *tree_sitter_confetti_external_scanner_create(void) {
   return NULL;
}

void tree_sitter_confetti_external_scanner_destroy(void *payload) {
  (void)payload;
}

unsigned tree_sitter_confetti_external_scanner_serialize(
  void *payload,
  char *buffer
) {
  (void)payload;
  (void)buffer;
  return 0;
}

void tree_sitter_confetti_external_scanner_deserialize(
  void *payload,
  const char *buffer,
  unsigned length
) {
  (void)payload;
  (void)buffer;
  (void)length;
}

bool tree_sitter_confetti_external_scanner_scan(
  void *payload,
  TSLexer *lexer,
  const bool *valid_symbols
) {
  (void)payload;
  // External scanners run before the internal lexer consumes `extras`.
  while (is_non_line_terminating_space(lexer->lookahead))
    lexer->advance(lexer, true);
  if (lexer->lookahead != '"') return false;
  lexer->advance(lexer, false);

  if (lexer->lookahead == '"') {
    lexer->advance(lexer, false);
    if (lexer->lookahead == '"' && valid_symbols[TRIPLE_QUOTED_STRING]) {
      lexer->advance(lexer, false);
      if (!scan_string(lexer, true)) return false;
      lexer->result_symbol = TRIPLE_QUOTED_STRING;
      return true;
    }
    if (valid_symbols[QUOTED_STRING]) {
      lexer->mark_end(lexer);
      lexer->result_symbol = QUOTED_STRING;
      return true;
    }
    return false;
  }

  if (valid_symbols[QUOTED_STRING] && scan_string(lexer, false)) {
    lexer->result_symbol = QUOTED_STRING;
    return true;
  }
  return false;
}
