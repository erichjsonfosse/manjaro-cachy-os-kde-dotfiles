#!/usr/bin/env bash
set -eo pipefail

# Source utilities
source "./utilities/during-install/utilities.sh"

echo "Testing stepRequiresRoot..."
stepRequiresRoot "installPacmanPackages" || { echo "FAIL: installPacmanPackages should require root"; exit 1; }
stepRequiresRoot "configureDocker" || { echo "FAIL: configureDocker should require root"; exit 1; }
stepRequiresRoot "configureGit" && { echo "FAIL: configureGit should not require root"; exit 1; }
stepRequiresRoot "configureZsh" && { echo "FAIL: configureZsh should not require root"; exit 1; }
echo "stepRequiresRoot passed!"

echo "Testing keepalive life-cycle functions exist..."
type startSudoKeepalive &>/dev/null || { echo "FAIL: startSudoKeepalive not found"; exit 1; }
type stopSudoKeepalive &>/dev/null || { echo "FAIL: stopSudoKeepalive not found"; exit 1; }
echo "Keepalive functions defined successfully!"
