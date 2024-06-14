{
  description = "Flake for development workflows.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    rain.url = "github:rainlanguage/rain.cli";
    rainix.url = "github:rainprotocol/rainix";
  };

  outputs = { self, flake-utils, rainix, rain, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = rainix.pkgs.${system};
      in rec {
        packages = rec {
          uniswap-prelude = rainix.mkTask.${system} {
            name = "uniswap-prelude";
            body = ''
              set -euxo pipefail

              # Build metadata that is needed for deployments.
              mkdir -p meta;
              forge script --silent "$PWD/script/BuildAuthoringMeta.sol";
              rain meta build \
                -i <(cat ./meta/AuthoringMeta.rain.meta) \
                -m authoring-meta-v2 \
                -t cbor \
                -e deflate \
                -l none \
                -o meta/UniswapWords.rain.meta \
              ;

              FOUNDRY_PROFILE=reference forge build --force
              FOUNDRY_PROFILE=quoter forge build --force
            '';
            additionalBuildInputs = rainix.sol-build-inputs.${system};
          };
        } // rainix.packages.${system};

        devShells.default = pkgs.mkShell {
          packages = [ packages.uniswap-prelude rain.defaultPackage.${system} ];
          inputsFrom = [ rainix.devShells.${system}.default ];
        };
      }
    );
}