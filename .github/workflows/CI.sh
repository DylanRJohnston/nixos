set -euo pipefail

DARWIN=("macbook-pro" "AU-L-0226")
LINUX=("work-dell" "desktop" "ipad")

for HOSTNAME in "${DARWIN[@]}"; do
  echo "Instantiating ${HOSTNAME}"
  nix eval ".#darwinConfigurations.${HOSTNAME}.config.system.build.toplevel.drvPath"
  echo "\n"
done

for HOSTNAME in "${LINUX[@]}"; do
  echo "Instantiating ${HOSTNAME}"
  nix eval ".#nixosConfigurations.${HOSTNAME}.config.system.build.toplevel.drvPath"
  echo "\n"
done
