set -euo pipefail
set -x

nix flake check --all-systems --no-build
nix run nixpkgs#nix-unit -- --flake .#tests
