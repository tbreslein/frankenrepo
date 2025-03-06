{
  description = "monorepo management through lua";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem =
        { self'
        , pkgs
        , ...
        }:
        let
          inherit (pkgs) ocamlPackages mkShell;
          inherit (ocamlPackages) buildDunePackage;
          name = "config";
          version = "0.0.1";
        in
        {
          devShells = {
            default = mkShell {
              buildInputs = [
                ocamlPackages.utop
                ocamlPackages.ocaml-lsp
                ocamlPackages.ppxlib
                ocamlPackages.ppx_deriving
                pkgs.ocamlformat
              ];
              inputsFrom = [ self'.packages.default ];
            };
          };

          packages = {
            default = buildDunePackage {
              inherit version;
              pname = name;
              propagatedBuildInputs = with ocamlPackages; [
                sedlex
                ppxlib
              ];
              src = ./.;
            };
          };
        };
    };
}
