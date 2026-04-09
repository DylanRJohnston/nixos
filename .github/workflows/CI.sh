set -euo pipefail
set -x

nix flake check --all-systems --no-build
