#!/usr/bin/env bash
set -Eeuo pipefail

# ============================================================
#                 SRNCLOUD Technologies
#              Proxmox VE Easy Installer
#
#                 Installer made by
#                    NegativeTier
#
#                 Debian 13 (Trixie)
# ============================================================

VERSION="1.0.0"
HOSTNAME="pve"
PVE_REPO="http://download.proxmox.com/debian/pve"
KEYRING="/usr/share/keyrings/proxmox-archive-keyring.gpg"
REPO_FILE="/etc/apt/sources.list.d/pve-install-repo.list"

# ------------------------------------------------------------
# Colors
# ------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ------------------------------------------------------------
# Functions
# ------------------------------------------------------------

log() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

success() {
    echo -e "${GREEN}[OK]${RESET} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${RESET} $1"
}

error() {
    echo -e "${RED}[ERROR]${RESET} $1"
}

die() {
    error "$1"
    exit 1
}

step() {
    echo
    echo -e "${CYAN}${BOLD}==> $1${RESET}"
    echo
}

# ------------------------------------------------------------
# Error handler
# ------------------------------------------------------------

trap 'error "Installation failed on line $LINENO."' ERR

# ------------------------------------------------------------
# Banner
# ------------------------------------------------------------

clear 2>/dev/null || true

echo -e "${CYAN}"
cat <<'EOF'

███████╗██████╗ ███╗   ██╗ ██████╗██╗      ██████╗ ██╗   ██╗██████╗
██╔════╝██╔══██╗████╗  ██║██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗
███████╗██████╔╝██╔██╗ ██║██║     ██║     ██║   ██║██║   ██║██║  ██║
╚════██║██╔══██╗██║╚██╗██║██║     ██║     ██║   ██║██║   ██║██║  ██║
███████║██████╔╝██║ ╚████║╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝
╚══════╝╚═════╝ ╚═╝  ╚═══╝ ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝

EOF
echo -e "${RESET}"

echo -e "${BOLD}        Proxmox VE Easy Installer${RESET}"
echo
echo -e "        ${GREEN}Installer made by NegativeTier${RESET}"
echo -e "        ${CYAN}From SRNCLOUD Technologies${RESET}"
echo
echo -e "        Version: ${VERSION}"
echo -e "        Target : Debian 13 (Trixie)"
echo

# ------------------------------------------------------------
# Root check
# ------------------------------------------------------------

if [[ "${EUID}" -ne 0 ]]; then
    die "Please run this installer as root."
fi

# ------------------------------------------------------------
# OS check
# ------------------------------------------------------------

step "Checking operating system"

if [[ ! -f /etc/os-release ]]; then
    die "Cannot detect operating system."
fi

source /etc/os-release

if [[ "${ID:-}" != "debian" ]]; then
    die "This installer requires Debian."
fi

if [[ "${VERSION_CODENAME:-}" != "trixie" ]]; then
    die "This installer requires Debian 13 (Trixie). Detected: ${VERSION_CODENAME:-unknown}"
fi

success "Debian 13 (Trixie) detected."

# ------------------------------------------------------------
# Architecture
# ------------------------------------------------------------

ARCH="$(dpkg --print-architecture)"

if [[ "$ARCH" != "amd64" ]]; then
    die "Unsupported architecture: $ARCH. Proxmox VE installation requires amd64 for this installer."
fi

success "Architecture: $ARCH"

# ------------------------------------------------------------
# Network check
# ------------------------------------------------------------

step "Checking network connectivity"

if ! ip route get 1.1.1.1 >/dev/null 2>&1; then
    die "No working IPv4 route detected."
fi

IP="$(ip -4 route get 1.1.1.1 | awk '{print $7; exit}')"

if [[ -z "$IP" ]]; then
    die "Unable to determine server IPv4 address."
fi

success "Server IPv4: $IP"

if ! getent hosts download.proxmox.com >/dev/null 2>&1; then
    die "DNS resolution is not working."
fi

success "DNS resolution working."

# ------------------------------------------------------------
# Update system
# ------------------------------------------------------------

step "Updating Debian"

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade -y

success "Debian packages updated."

# ------------------------------------------------------------
# Install dependencies
# ------------------------------------------------------------

step "Installing required packages"

apt-get install -y \
    wget \
    curl \
    gnupg2 \
    ca-certificates \
    apt-transport-https \
    iproute2 \
    hostname \
    systemd \
    systemd-sysv

success "Required packages installed."

# ------------------------------------------------------------
# Hostname
# ------------------------------------------------------------

step "Configuring hostname"

hostnamectl set-hostname "$HOSTNAME"

CURRENT_HOSTNAME="$(hostname)"

if [[ "$CURRENT_HOSTNAME" != "$HOSTNAME" ]]; then
    die "Failed to set hostname."
fi

success "Hostname set to: $HOSTNAME"

# ------------------------------------------------------------
# /etc/hosts
# ------------------------------------------------------------

step "Configuring /etc/hosts"

cp /etc/hosts "/etc/hosts.backup.$(date +%Y%m%d-%H%M%S)"

# Remove old pve entries
sed -i \
    -e '/[[:space:]]pve$/d' \
    -e '/pve\.localdomain/d' \
    /etc/hosts

echo "$IP pve.localdomain pve" >> /etc/hosts

if ! getent hosts pve >/dev/null 2>&1; then
    die "Hostname pve does not resolve correctly."
fi

success "Hostname resolution configured."

# ------------------------------------------------------------
# Proxmox GPG key
# ------------------------------------------------------------

step "Installing Proxmox repository key"

mkdir -p "$(dirname "$KEYRING")"

wget \
    --quiet \
    --show-progress \
    -O "$KEYRING" \
    https://enterprise.proxmox.com/debian/proxmox-release-trixie.gpg

chmod 0644 "$KEYRING"

if [[ ! -s "$KEYRING" ]]; then
    die "Proxmox repository key was not downloaded correctly."
fi

success "Proxmox repository key installed."

# ------------------------------------------------------------
# Repository
# ------------------------------------------------------------

step "Configuring Proxmox repository"

cat > "$REPO_FILE" <<EOF
deb [signed-by=$KEYRING] $PVE_REPO trixie pve-no-subscription
EOF

success "Proxmox no-subscription repository configured."

apt-get update

# ------------------------------------------------------------
# Remove conflicting packages if present
# ------------------------------------------------------------

step "Checking for package conflicts"

apt-get install -y proxmox-ve

success "Proxmox VE package available."

# ------------------------------------------------------------
# Install Proxmox
# ------------------------------------------------------------

step "Installing Proxmox VE"

apt-get install -y \
    proxmox-default-kernel \
    proxmox-ve \
    postfix \
    open-iscsi \
    chrony

success "Proxmox VE installed."

# ------------------------------------------------------------
# Kernel check
# ------------------------------------------------------------

step "Checking Proxmox kernel"

if ! dpkg -l | grep -q "proxmox-default-kernel"; then
    die "Proxmox kernel package was not installed."
fi

success "Proxmox kernel package detected."

# ------------------------------------------------------------
# Services
# ------------------------------------------------------------

step "Configuring Proxmox services"

SERVICES=(
    pve-cluster
    pvedaemon
    pvestatd
    pveproxy
    chrony
    open-iscsi
)

for SERVICE in "${SERVICES[@]}"; do
    systemctl enable "$SERVICE" >/dev/null 2>&1 || true
done

systemctl restart pve-cluster
systemctl restart pvedaemon
systemctl restart pvestatd
systemctl restart pveproxy
systemctl restart chrony
systemctl restart open-iscsi || true

success "Proxmox services configured."

# ------------------------------------------------------------
# Service verification
# ------------------------------------------------------------

step "Verifying Proxmox services"

FAILED=0

for SERVICE in pve-cluster pvedaemon pvestatd pveproxy; do
    if systemctl is-active --quiet "$SERVICE"; then
        success "$SERVICE is running"
    else
        error "$SERVICE is NOT running"
        FAILED=1
    fi
done

if [[ "$FAILED" -ne 0 ]]; then
    warn "One or more Proxmox services failed."
    warn "Showing recent service logs:"
    journalctl -u pve-cluster -u pvedaemon -u pvestatd -u pveproxy \
        --no-pager -n 30 || true
fi

# ------------------------------------------------------------
# Final information
# ------------------------------------------------------------

echo
echo -e "${GREEN}${BOLD}"
echo "============================================================"
echo "             PROXMOX VE INSTALLATION COMPLETE"
echo "============================================================"
echo -e "${RESET}"

echo -e "${BOLD}Hostname:${RESET} $HOSTNAME"
echo -e "${BOLD}IPv4:${RESET}     $IP"
echo
echo -e "${BOLD}Web Interface:${RESET}"
echo -e "${CYAN}https://$IP:8006${RESET}"
echo
echo -e "${BOLD}Username:${RESET} root"
echo
echo -e "${YELLOW}IMPORTANT:${RESET}"
echo "The Proxmox web interface normally becomes fully available"
echo "after rebooting into the Proxmox kernel."
echo

# ------------------------------------------------------------
# Reboot confirmation
# ------------------------------------------------------------

read -r -p "Reboot this server now? [Y/n]: " ANSWER

if [[ -z "$ANSWER" || "$ANSWER" =~ ^[Yy]$ ]]; then
    echo
    log "Rebooting in 5 seconds..."
    sleep 5
    reboot
else
    echo
    warn "Reboot skipped."
    echo
    echo "Run:"
    echo
    echo "    reboot"
    echo
fi
