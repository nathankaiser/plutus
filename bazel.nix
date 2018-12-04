{ ghc
, haskellPackages
, localLib
}:

with localLib;
with pkgs;
let
  plutusPkgs = map (x: haskellPackages.${x}) localLib.plutusPkgList;
  packageInputs = map haskell.lib.getBuildInputs plutusPkgs;
  haskellInputs = pkgs.lib.filter
    (input: pkgs.lib.all (p: input.outPath != p.outPath) plutusPkgs)
    (pkgs.lib.concatMap (p: p.haskellBuildInputs) packageInputs);
  ghcWithDependencies = haskellPackages.ghcWithPackages (p: 
    haskellInputs
  );

  hlintTest =
    let
      script = (import iohkNix.tests.hlintScript {inherit pkgs;});
    in
      pkgs.stdenv.mkDerivation {
        name = "hlintTest";
        unpackPhase = "true";
        buildInputs = [];
        buildPhase = "";
        installPhase = ''
        mkdir -p $out/bin
        cp ${script} $out/bin/hlintTest.sh
        '';
      };

  stylishHaskellTest =
    let
      script = (import iohkNix.tests.stylishHaskellScript {inherit pkgs;});
    in
      pkgs.stdenv.mkDerivation {
        name = "stylishHaskellTest";
        unpackPhase = "true";
        buildInputs = [];
        buildPhase = "";
        installPhase = ''
        mkdir -p $out/bin
        cp ${script} $out/bin/stylishHaskellTest.sh
        '';
      };

  shellcheckTest =
    let
      script = (import iohkNix.tests.shellcheckScript {inherit pkgs;});
    in
      pkgs.stdenv.mkDerivation {
        name = "shellcheckTest";
        unpackPhase = "true";
        buildInputs = [ ];
        buildPhase = "";
        installPhase = ''
        mkdir -p $out/bin
        cp ${script} $out/bin/shellcheckTest.sh
        '';
      };
in
  buildBazelPackage rec {
    name = "plutus-${version}";
    version = "0.0.1";

    src = lib.cleanSourceWith {
        filter = with stdenv;
          name: type: let baseName = baseNameOf (toString name); in (
            baseName == "WORKSPACE" ||
            lib.hasPrefix "BUILD" baseName ||
            lib.hasSuffix ".bzl" baseName ||
            lib.hasSuffix ".hs" baseName ||
            lib.hasSuffix ".cabal" baseName ||
            lib.hasSuffix ".sh" baseName ||
            lib.hasSuffix ".nix" baseName
          );
        src = lib.cleanSource ./.;
      };

    nativeBuildInputs = [ bazel perl git ghcWithDependencies haskellPackages.happy haskellPackages.alex stylishHaskellTest hlintTest shellcheckTest ];

    fetchAttrs = {
      preBuild = ''
        # tell rules_go to invoke GIT with custom CAINFO path
        export GIT_SSL_CAINFO="${cacert}/etc/ssl/certs/ca-bundle.crt"
      '';

        sha256 = "1cx4s2y4p31gh845crab7yk73zvwpgn6g8s9xlgspha0vmnngj9a";
    };

    bazelTarget = "//language-plutus-core:language-plutus-core";

    buildAttrs = {
      preBuild = ''
        export GIT_SSL_CAINFO="${cacert}/etc/ssl/certs/ca-bundle.crt"
      '';

      installPhase = ''
        install -Dm755 bazel-bin/* $out/
      '';
    };

    meta = with stdenv.lib; {
      homepage = https://github.com/input-output-hk/plutus;
      description = "The Plutus language reference implementation and tools.";
      license = licenses.mit;
      platforms = platforms.all;
    };
  }
