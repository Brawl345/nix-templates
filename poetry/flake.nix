{
  description = "Poetry Project";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs }:
    let
      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ]
          (system: function nixpkgs.legacyPackages.${system});

      poetry-overrides = {
        somepackage = [ "setuptools" ];
      };

      poetry2nix-overrides = (pkgs: pkgs.poetry2nix.defaultPoetryOverrides.extend (self: super:
        builtins.mapAttrs
          (package: build-requirements:
            (builtins.getAttr package super).overridePythonAttrs (old: {
              buildInputs = (old.buildInputs or [ ]) ++ (builtins.map (pkg: if builtins.isString pkg then builtins.getAttr pkg super else pkg) build-requirements);
            })
          )
          poetry-overrides
      ));
    in
    {
      devShells = forAllSystems
        (pkgs: {
          default = pkgs.mkShellNoCC {
            packages = [
              (pkgs.poetry2nix.mkPoetryEnv
                {
                  projectDir = self;
                  preferWheels = true;
                  overrides = poetry2nix-overrides pkgs;
                })
            ];
            shellHook = ''
            '';
          };
        });

      packages = forAllSystems
        (pkgs: {
          default = pkgs.poetry2nix.mkPoetryApplication
            {
              projectDir = self;
              overrides = poetry2nix-overrides pkgs;
              preferWheels = true;
              doCheck = false;

              meta = with pkgs.lib; {
                description = "";
                homepage = "";
                platforms = platforms.all;
              };
            };
        });

    };
}
