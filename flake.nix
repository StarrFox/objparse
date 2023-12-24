{
  description = "Parse with objects";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts/";
    nix-systems.url = "github:nix-systems/default";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    nix-systems,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      debug = true;
      systems = import nix-systems;
      perSystem = {
        pkgs,
        self',
        ...
      }: let
        python = pkgs.python311;
        pyproject = builtins.fromTOML (builtins.readFile ./pyproject.toml);
        projectName = pyproject.tool.poetry.name;
      in {
        packages.${projectName} = python.pkgs.buildPythonPackage {
          inherit (pyproject.tool.poetry) version;

          src = ./.;
          pname = projectName;
          format = "pyproject";
          pythonImportsCheck = [projectName];
          nativeBuildInputs = [python.pkgs.poetry-core];
          propagatedBuildInputs = with python.pkgs; [];
        };

        packages.default = self'.packages.${projectName};

        devShells.default = pkgs.mkShell {
          name = projectName;
          packages = with pkgs; [
            (poetry.withPlugins (ps: with ps; [poetry-plugin-up]))
            python
            just
            alejandra
            python.pkgs.black
            python.pkgs.isort
          ];
        };
      };
    };
}