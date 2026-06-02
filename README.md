<div align="center">

# 🚀 RaiseTunnel
**The Ultimate GRE Tunnel Auto-Installer & Manager for Linux**

[![Version](https://img.shields.io/badge/Version-v1.1.0-blue.svg?style=for-the-badge&logo=github)](https://github.com/FalconDNS/RaiseTunnel)
[![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey.svg?style=for-the-badge&logo=linux)](https://github.com/FalconDNS/RaiseTunnel)
[![Language](https://img.shields.io/badge/Script-Bash-4EAA25.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://github.com/FalconDNS/RaiseTunnel)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

*A powerful, interactive, and persistent command-line tool to establish GRE tunnels between servers in seconds.*

---
</div>

## ✨ Features

- **🪄 One-Click Installation:** Global command integration. Type `raisetunnel` anywhere!
- **🎨 Beautiful Interactive UI:** Colorful, menu-driven ASCII interface.
- **🛡️ Persistence (Systemd):** Tunnels survive server reboots automatically.
- **⚡ Auto-Cleanup:** Prevents interface overlaps and `File exists` kernel errors.
- **🌍 Bi-directional Logic:** Smart routing config based on your current server location.

---

## 🚀 One-Line Installation

Run the following command on your Linux terminal (requires `root` privileges) to download and install RaiseTunnel globally:

```bash
bash <(curl -Ls https://raw.githubusercontent.com/FalconDNS/RaiseTunnel/main/install.sh)
```

Note: Make sure curl is installed on your system (apt install curl or yum install curl).

## 🕹️ Usage

Once installed, you don't need to navigate to any specific directory. Just type the following command in your terminal:

```bash
raisetunnel
```
📋 Main Menu Options

    ⚙️ Configure and Install RaiseTunnel: Prompts for IPs and sets up a persistent systemd service.

    📊 Check Tunnel Status: Displays real-time kernel interface status and systemd logs.

    🗑️ Remove RaiseTunnel: Safely stops and completely removes all tunnel configurations.

📸 Preview

(Tip: You can add an animated GIF of your terminal here using tools like Terminalizer or vhs to make it look even more professional!)

    🟩 Dynamic Location: Choose your server location dynamically.

    🟨 Smart Defaults: Setup tunnel IPs with auto-suggested defaults.

    🟦 Real-time Status: Check systemd and IP interface directly.

    🟥 One-Click Removal: Safely remove the tunnel with a single click.

🧠 How it Works under the hood?

RaiseTunnel uses native Linux iproute2 (ip tunnel and ip link) to create a lightweight GRE (Generic Routing Encapsulation) tunnel.

Instead of saving settings in volatile memory, it dynamically generates a /etc/systemd/system/raisetunnel.service file to ensure 100% persistence across server reboots.
📜 License

This project is licensed under the MIT License - see the LICENSE file for details.
