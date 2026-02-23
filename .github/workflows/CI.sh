set -euo pipefail
set -x

DARWIN=("macbook-pro")
LINUX=("desktop")

for HOSTNAME in "${DARWIN[@]}"; do
  echo "################# Instantiating ${HOSTNAME} #################"
  nix eval --extra-experimental-features pipe-operators ".#darwinConfigurations.${HOSTNAME}.config.system.build.toplevel.drvPath"
  echo -e "\n"
done

for HOSTNAME in "${LINUX[@]}"; do
  echo "################# Instantiating ${HOSTNAME} #################"
  nix eval --extra-experimental-features pipe-operators ".#nixosConfigurations.${HOSTNAME}.config.system.build.toplevel.drvPath"
  echo -e "\n"
done
