{
  description = "Simple Project";

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
    in
    {

      devShells = forAllSystems
        (pkgs: {
          default = pkgs.mkShell {
            packages = [
              pkgs.bashInteractive
            ];
            shellHook = ''
            '';
          };
        });

    };
}
