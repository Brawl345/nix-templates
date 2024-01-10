{
  description = "Poetry Project";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, poetry2nix }:
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

      poetry2nix-overrides = (defaultPoetryOverrides: pkgs: defaultPoetryOverrides.extend (self: super:
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
        (pkgs:
          let
            inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryEnv defaultPoetryOverrides;
          in
          {
            default = pkgs.mkShellNoCC {
              packages = [
                (mkPoetryEnv
                  {
                    projectDir = self;
                    preferWheels = true;
                    overrides = poetry2nix-overrides defaultPoetryOverrides pkgs;
                  })
              ];
              shellHook = ''
            '';
            };
          });

      packages = forAllSystems
        (pkgs:
          let
            inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryApplication defaultPoetryOverrides;
          in
          {
            default = mkPoetryApplication
              {
                projectDir = self;
                overrides = poetry2nix-overrides defaultPoetryOverrides pkgs;
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
