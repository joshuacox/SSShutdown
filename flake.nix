{
  description = "A flake for SSShutdown";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
  in {
    packages = forAllSystems (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        default = pkgs.stdenv.mkDerivation {
          name = "SSShutdown";
          src = self;
          installPhase = ''
            mkdir -p $out
            cp -av bin $out/
          '';
        };
        SSShutdown = self.packages.${system}.default;
      });
  };
}
