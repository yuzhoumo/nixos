#!/usr/bin/env bash
#
# NixOS Autoprovision Script
#
# Run this on a fresh NixOS install to bootstrap the system from the
# flake-based config repo. It will:
#   1. Prompt for hostname and profile (desktop/server)
#   2. Clone the config repo
#   3. Generate hardware-configuration.nix
#   4. Scaffold the new host config
#   5. Register the host in flake.nix
#   6. Run nixos-rebuild switch
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/yuzhoumo/nixos/main/provision.sh | sudo bash
#   # or from a local copy:
#   sudo ./provision.sh

set -euo pipefail

REPO_URL="https://github.com/yuzhoumo/nixos.git"
INSTALL_DIR="/etc/nixos"
TIMEZONE="America/Los_Angeles"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }

# --- Preflight checks ---
[[ $EUID -eq 0 ]] || error "This script must be run as root (use sudo)."
command -v nixos-rebuild &>/dev/null || error "nixos-rebuild not found. Is this a NixOS system?"
command -v git &>/dev/null || {
  info "Installing git..."
  nix-env -iA nixos.git
}

# --- Interactive prompts ---
echo ""
echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   NixOS Autoprovision                ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
echo ""

read -rp "Hostname for this machine: " HOSTNAME
[[ -n "$HOSTNAME" ]] || error "Hostname cannot be empty."
[[ "$HOSTNAME" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]] || error "Invalid hostname. Use lowercase letters, digits, and hyphens."

echo ""
echo "Select a profile:"
echo "  1) desktop  — graphical environment, dev tools, gaming"
echo "  2) server   — headless, hardened, SSH-only"
echo ""
read -rp "Profile [1/2]: " PROFILE_CHOICE
case "$PROFILE_CHOICE" in
  1|desktop) PROFILE="desktop" ;;
  2|server)  PROFILE="server"  ;;
  *) error "Invalid selection." ;;
esac

read -rp "Timezone [$TIMEZONE]: " TZ_INPUT
TIMEZONE="${TZ_INPUT:-$TIMEZONE}"

read -rp "NixOS state version [25.11]: " SV_INPUT
STATE_VERSION="${SV_INPUT:-25.11}"

echo ""
info "Summary:"
echo "  Hostname:      $HOSTNAME"
echo "  Profile:       $PROFILE"
echo "  Timezone:      $TIMEZONE"
echo "  State version: $STATE_VERSION"
echo "  Repo:          $REPO_URL"
echo "  Install dir:   $INSTALL_DIR"
echo ""
read -rp "Proceed? [y/N]: " CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || { info "Aborted."; exit 0; }

# --- Clone or update repo ---
if [[ -d "$INSTALL_DIR/.git" ]]; then
  info "Existing repo found at $INSTALL_DIR, pulling latest..."
  git -C "$INSTALL_DIR" pull --ff-only
else
  info "Cloning config repo to $INSTALL_DIR..."
  # Back up existing config if present
  if [[ -d "$INSTALL_DIR" ]] && [[ "$(ls -A "$INSTALL_DIR" 2>/dev/null)" ]]; then
    BACKUP_DIR="/etc/nixos.bak.$(date +%s)"
    warn "Backing up existing $INSTALL_DIR to $BACKUP_DIR"
    mv "$INSTALL_DIR" "$BACKUP_DIR"
  fi
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

HOST_DIR="$INSTALL_DIR/hosts/$HOSTNAME"

# --- Check if host already exists ---
if [[ -d "$HOST_DIR" ]]; then
  warn "Host config '$HOSTNAME' already exists at $HOST_DIR"
  read -rp "Overwrite? [y/N]: " OVERWRITE
  [[ "$OVERWRITE" =~ ^[Yy]$ ]] || { info "Skipping host scaffold, proceeding to build."; }
  if [[ "$OVERWRITE" =~ ^[Yy]$ ]]; then
    rm -rf "$HOST_DIR"
  fi
fi

# --- Generate hardware config ---
if [[ ! -d "$HOST_DIR" ]]; then
  info "Creating host directory: $HOST_DIR"
  mkdir -p "$HOST_DIR"

  info "Generating hardware-configuration.nix..."
  nixos-generate-config --show-hardware-config > "$HOST_DIR/hardware-configuration.nix"
  ok "Hardware config written."

  # --- Scaffold host default.nix ---
  info "Generating host config for profile: $PROFILE"
  cat > "$HOST_DIR/default.nix" <<EOF
{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/all
    ../../common/$PROFILE
  ];

  networking.hostName = "$HOSTNAME";
  time.timeZone = "$TIMEZONE";

  system.stateVersion = "$STATE_VERSION";
}
EOF
  ok "Host config written: $HOST_DIR/default.nix"
fi

# --- Register host in flake.nix ---
FLAKE_FILE="$INSTALL_DIR/flake.nix"

if grep -q "\"$HOSTNAME\"" "$FLAKE_FILE" 2>/dev/null; then
  info "Host '$HOSTNAME' already registered in flake.nix, skipping."
else
  info "Registering '$HOSTNAME' in flake.nix..."

  # Build the module list based on profile
  MODULES="[\n            ./hosts/$HOSTNAME\n          ]"
  if [[ "$PROFILE" == "desktop" ]]; then
    MODULES="[\n            nix-index-database.nixosModules.nix-index\n            ./hosts/$HOSTNAME\n          ]"
  fi

  # Insert new host config before the closing of nixosConfigurations
  ENTRY="      $HOSTNAME = nixpkgs.lib.nixosSystem {\n        system = \"x86_64-linux\";\n        modules = $MODULES;\n      };"

  # Find the last closing brace+semicolon of a host block and insert after it
  sed -i "/^    nixosConfigurations = {/,/^    };/ {
    /^      };$/ {
      # Only insert after the last host block (before nixosConfigurations closing)
      /^      };$/a\\
$ENTRY
    }
  }" "$FLAKE_FILE"

  ok "Host registered in flake.nix"
fi

# --- Build and switch ---
echo ""
info "Running nixos-rebuild switch --flake $INSTALL_DIR#$HOSTNAME ..."
echo ""
nixos-rebuild switch --flake "$INSTALL_DIR#$HOSTNAME"

echo ""
ok "Provisioning complete!"
echo ""
echo -e "${GREEN}Your system '$HOSTNAME' is now configured.${NC}"
echo ""
echo "Next steps:"
echo "  - Review and customize: $HOST_DIR/default.nix"
echo "  - Commit changes:       cd $INSTALL_DIR && git add -A && git commit -m 'Add host: $HOSTNAME'"
echo "  - Rebuild after edits:  sudo nixos-rebuild switch --flake $INSTALL_DIR#$HOSTNAME"
echo ""
