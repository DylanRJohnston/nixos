set -euo pipefail
set -x

DARWIN=("odin")
LINUX=("loki")

for HOSTNAME in "${DARWIN[@]}"; do
  echo "################# Instantiating ${HOSTNAME} #################"
  nix eval ".#darwinConfigurations.${HOSTNAME}.config.system.build.toplevel.drvPath"
  echo -e "\n"
done

for HOSTNAME in "${LINUX[@]}"; do
  echo "################# Instantiating ${HOSTNAME} #################"
  nix eval ".#nixosConfigurations.${HOSTNAME}.config.system.build.toplevel.drvPath"
  echo -e "\n"
done
