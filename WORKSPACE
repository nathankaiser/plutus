workspace(name = "plutus")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load(":path_repo.bzl", "path_repo")

git_repository(
    name = "io_tweag_rules_haskell",
    remote = "https://github.com/jbgi/rules_haskell.git",
    commit = "e134749dbdd926515be1d30495dafd8c72c26a61",
)

load("@io_tweag_rules_haskell//haskell:repositories.bzl", "haskell_repositories")

haskell_repositories()

http_archive(
    name = "io_tweag_rules_nixpkgs",
    strip_prefix = "rules_nixpkgs-0.4.1",
    urls = ["https://github.com/tweag/rules_nixpkgs/archive/v0.4.1.tar.gz"],
)

load(
    "@io_tweag_rules_nixpkgs//nixpkgs:nixpkgs.bzl",
    "nixpkgs_package",
)

path_repo(name = "ghc")
path_repo(name = "happy")
path_repo(name = "alex")

path_repo(name = "stylishHaskellTest.sh")
path_repo(name = "hlintTest.sh")
path_repo(name = "shellcheckTest.sh")

register_toolchains("//:ghc")

