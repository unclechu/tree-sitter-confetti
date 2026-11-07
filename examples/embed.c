#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tree_sitter/api.h>

#include "../bindings/c/tree_sitter_confetti.h"

// Example embedding using Tree-sitter’s plain C API.
int main(void) {
  const char source[] = "app {\n  version 1.0\n  enabled yes\n}\n";
  TSParser *parser = ts_parser_new();
  if (parser == NULL || !ts_parser_set_language(parser, tree_sitter_confetti())) {
    fputs("Unable to initialize the Confetti parser\n", stderr);
    if (parser != NULL) ts_parser_delete(parser);
    return EXIT_FAILURE;
  }

  TSTree *tree = ts_parser_parse_string(parser, NULL, source, strlen(source));
  if (tree == NULL) {
    fputs("Unable to parse Confetti source\n", stderr);
    ts_parser_delete(parser);
    return EXIT_FAILURE;
  }

  char *tree_text = ts_node_string(ts_tree_root_node(tree));
  if (tree_text != NULL) {
    puts(tree_text);
    free(tree_text);
  }

  ts_tree_delete(tree);
  ts_parser_delete(parser);
  return EXIT_SUCCESS;
}
