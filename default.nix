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

  # An example of Neovim configuration that would enable Confetti Tree-sitter
  # grammar for `*.confetti` files.
  #
  #   nix-build --arg useNixpkgsPin true -A neovim-example -o result-neovim-example
  #   result-neovim-example/bin/nvim test/samples/core.confetti
  #
  neovim-example = pkgs.neovim.override {
    configure = {
      packages.treesitter.start = [
        (vimPlugins.nvim-treesitter.withPlugins (grammars: [
          tree-sitter-confetti-grammar
        ]))
      ];

      customRC = ''
        lua << EOF

        -- Recognize `*.confetti` files.
        vim.filetype.add({ extension = { confetti = "confetti" } })

        -- Create the autocommand group, clearing previous registrations.
        local group = vim.api.nvim_create_augroup(
          "confetti_filetype_configuration",
          { clear = true }
        )

        -- Configure Confetti buffers.
        vim.api.nvim_create_autocmd("FileType", {
          group = group,
          pattern = "confetti",
          callback = function(ev)
            -- Enable Confetti hash-sign comments.
            vim.opt_local.commentstring = "# %s"
            vim.opt_local.comments = "b:#"

            -- Make dashes part of words.
            vim.opt_local.iskeyword:append("-")

            -- Enable Tree-sitter highlighting for this buffer.
            vim.treesitter.start(ev.buf)
          end,
        })

        EOF
      '';
    };
  };
in

(if inNixShell then shell else {}) // {
  inherit
    shell
    tree-sitter-confetti-grammar
    neovim-example
    ;
}
