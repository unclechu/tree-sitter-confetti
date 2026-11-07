CC ?= cc
CFLAGS ?= -O2 -std=c11 -fPIC -Wall -Wextra -Wpedantic

.PHONY: all clean

all: build/libtree-sitter-confetti.so

build/libtree-sitter-confetti.so: src/parser.c src/scanner.c src/tree_sitter/parser.h
	mkdir -p build
	$(CC) $(CFLAGS) -Isrc -shared src/parser.c src/scanner.c -o $@

clean:
	rm -f build/libtree-sitter-confetti.so
