{
  description = "Flake for development workflows.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    rainix.url = "github:rainprotocol/rainix";
  };

  outputs = { self, flake-utils, rainix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = rainix.pkgs.${system};
      in {
        packages = rec {
          uniswap-prelude = rainix.mkTask.${system} {
            name = "uniswap-prelude";
            body = ''
              set -euxo pipefail

              FOUNDRY_PROFILE=reference forge build --force
            '';
            additionalBuildInputs = rainix.sol-build-inputs.${system};
          };

          rainix-sol-test-debug = mkTask {
            name = "rainix-sol-test-debug";
            body = ''
              set -euxo pipefail
              forge test -vvvvv
            '';
            additionalBuildInputs = sol-build-inputs;
          };
        } // rainix.packages.${system};

        devShells = rainix.devShells.${system};
      }
    );
}