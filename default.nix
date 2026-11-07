{ pkgs ? import (if useNixpkgsPin then import nix/nixpkgs-pin.nix else <nixpkgs>) {}
, lib ? pkgs.lib

, gcc ? pkgs.gcc
, pkg-config ? pkgs.pkg-config
, gnumake ? pkgs.gnumake

, vimPlugins ? pkgs.vimPlugins
, tree-sitter ? pkgs.tree-sitter

, inNixShell ? false
, useNixpkgsPin ? false

, tree-sitter-confetti-source-root ? ./.
, tree-sitter-confetti-source ?
    lib.fileset.toSource {
      root = tree-sitter-confetti-source-root;
      # Minimal required file set for the grammar
      fileset = lib.fileset.unions [
        (tree-sitter-confetti-source-root + "/src/parser.c")
        (tree-sitter-confetti-source-root + "/src/scanner.c")
        (tree-sitter-confetti-source-root + "/src/tree_sitter/parser.h")
        (tree-sitter-confetti-source-root + "/tree-sitter.json")
        (tree-sitter-confetti-source-root + "/queries/highlights.scm")
      ];
    }
}:

let
  # Produces:
  # - parser — Shared object (compiled library file, without *.so extension)
  # - queries/highlights.scm
  # - tree-sitter.json
  tree-sitter-confetti-grammar = tree-sitter.buildGrammar {
    language = "confetti";
    version = "0.1.0";
    src = tree-sitter-confetti-source;
  };

  shell = pkgs.mkShell {
    pname = "tree-sitter-confetti-shell";

    packages = [
      pkgs.gcc
      pkgs.pkg-config
      pkgs.gnumake
      pkgs.tree-sitter
    ];
  };
in

(if inNixShell then shell else {}) // {
  inherit
    shell
    tree-sitter-confetti-grammar
    ;
}
