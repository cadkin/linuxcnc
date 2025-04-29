{
  description = "LinuxCNC - software for manufacturing control";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    utils.url   = github:numtide/flake-utils;
  };

  outputs = inputs @ { self, utils, ... }: utils.lib.eachDefaultSystem (system: let
    config = rec {
      pkgs = import inputs.nixpkgs {
        inherit system;
      };

      stdenv = llvm.stdenv;

      llvm = rec {
        packages = pkgs.llvmPackages_19;
        stdenv   = packages.stdenv;

        tooling = rec {
          lldb = packages.lldb;
          clang-tools = packages.clang-tools;
          clang-tools-libcxx = clang-tools.override {
            enableLibcxx = true;
          };
        };
      };
    };
  in with config; rec {
    inherit config;

    lib = let
      version = lib.pipe ./VERSION [
        builtins.readFile
        (builtins.replaceStrings [ "\n" ] [ "" ])
      ];
    in rec {
      mkPackages = { pkgs, stdenv ? pkgs.stdenv }: rec {
        nixpkgs = pkgs;

        dependencies = {
          yapps2 = pkgs.python3Packages.callPackage ./nix/dependencies/python3/yapps2 { };
        };

        linuxcnc = {
          core = pkgs.callPackage ./nix/linuxcnc/core {
            src = self;
            inherit version;
            inherit stdenv;

            inherit (dependencies) yapps2;
          };
        };
      };
    } // config.pkgs.lib;

    legacyPackages = {
      inherit (lib.mkPackages { inherit pkgs stdenv; } ) linuxcnc dependencies nixpkgs;
    };

    packages = rec {
      default = core;
      core = legacyPackages.linuxcnc.core;
    };
  });
}
