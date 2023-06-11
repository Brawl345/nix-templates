{
  description = "Simple Project";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
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
