# 🚀 Proxmox VE Easy Installer

### ⚡ Fast & Simple Proxmox VE Installation for Debian 13

> **Installer made by NegativeTier**
> **From SRNCLOUD Technologies**

[![Debian](https://img.shields.io/badge/Debian-13%20Trixie-A81D33?style=for-the-badge\&logo=debian\&logoColor=white)](https://www.debian.org/)
[![Proxmox](https://img.shields.io/badge/Proxmox-VE-E57000?style=for-the-badge\&logo=proxmox\&logoColor=white)](https://www.proxmox.com/)
[![Bash](https://img.shields.io/badge/Language-Bash-121011?style=for-the-badge\&logo=gnu-bash\&logoColor=white)](https://www.gnu.org/software/bash/)
[![GitHub](https://img.shields.io/badge/GitHub-NegativeTiers-181717?style=for-the-badge\&logo=github\&logoColor=white)](https://github.com/NegativeTiers)

---

## 📖 About

**Proxmox VE Easy Installer** is a lightweight Bash installer designed to simplify the installation of **Proxmox VE** on a fresh **Debian 13 (Trixie)** server.

Instead of manually configuring repositories, hostname, networking, packages, and Proxmox services, the installer performs the main setup automatically.

### ✨ Features

* ⚡ One-command installation
* 🐧 Debian 13 (Trixie) validation
* 🔧 Automatic hostname configuration
* 🌐 Automatic IPv4 detection
* 📝 Automatic `/etc/hosts` configuration
* 🔑 Proxmox repository key installation
* 📦 Proxmox no-subscription repository setup
* 🚀 Proxmox VE installation
* 🧩 Proxmox kernel installation
* ⏱️ Chrony installation
* 💾 Open-iSCSI installation
* 🔄 Proxmox service configuration
* ❤️ Service health checks
* 🛡️ Basic installation validation
* 🎨 Clean terminal interface
* 🔁 Optional automatic reboot

---

# ⚙️ Requirements

Before running the installer, make sure your server meets these requirements:

| Requirement  | Details                                    |
| ------------ | ------------------------------------------ |
| OS           | Debian 13 (Trixie)                         |
| Architecture | amd64                                      |
| Access       | Root                                       |
| Internet     | Required                                   |
| IPv4         | Required                                   |
| Installation | Recommended on a fresh Debian installation |

> ⚠️ **Important:** This installer is intended for a fresh Debian 13 installation. Existing virtualization, networking, or package configurations may cause conflicts.

---

# 🚀 Installation

## Method 1 — Curl

Run:

```bash
curl -fsSL https://raw.githubusercontent.com/NegativeTiers/Proxmox-Installer/main/install-proxmox.sh | bash
```

## Method 2 — Wget

```bash
wget -qO- https://raw.githubusercontent.com/NegativeTiers/Proxmox-Installer/main/install-proxmox.sh | bash
```

---

# 🛠️ What The Installer Does

The installer performs the following process:

```text
1. Check root access
        ↓
2. Detect Debian version
        ↓
3. Verify Debian 13 / Trixie
        ↓
4. Check architecture
        ↓
5. Check network & DNS
        ↓
6. Update Debian
        ↓
7. Install required packages
        ↓
8. Configure hostname
        ↓
9. Detect server IPv4
        ↓
10. Configure /etc/hosts
        ↓
11. Install Proxmox repository key
        ↓
12. Configure Proxmox repository
        ↓
13. Install Proxmox VE
        ↓
14. Configure Proxmox services
        ↓
15. Verify services
        ↓
16. Reboot
```

---

# 🌐 After Installation

After the installation and reboot, access the Proxmox web interface:

```text
https://YOUR_SERVER_IP:8006
```

Example:

```text
https://192.168.1.100:8006
```

Login using:

```text
Username: root
Realm: Linux PAM
Password: Your Debian root password
```

Your browser may show a certificate warning because Proxmox initially uses its own certificate. This is expected on a fresh installation.

---

# 📦 Installed Components

The installer installs the main Proxmox components and supporting packages:

```text
proxmox-ve
proxmox-default-kernel
postfix
open-iscsi
chrony
```

---

# 🔧 Services

The installer configure
