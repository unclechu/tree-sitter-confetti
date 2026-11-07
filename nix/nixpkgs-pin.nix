let
  githubRepo = "NixOS/nixpkgs";
  # Branch: nixos-26.05; Date: Nov 5, 2026
  commit = "c56a87d8e41ce69bd2af57eb35dcc117a9dfca33";
  hash = "06g8y8y9bysnpxrl6bfqmn63l8w2lx2yhj0618r34j5jfqy5vjpx";
in
builtins.fetchTarball {
  url = "https://github.com/${githubRepo}/archive/${commit}.tar.gz";
  sha256 = hash;
}
