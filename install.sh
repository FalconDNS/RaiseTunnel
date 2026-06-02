#!/bin/bash

# ==========================================
# RaiseTunnel - GRE Tunnel Auto-Installer & Manager
# ==========================================

SCRIPT_VERSION="v1.1.0"
APP_NAME="RaiseTunnel"
TUNNEL_IF="raisetun"
SERVICE_NAME="raisetunnel.service"
SERVICE_PATH="/etc/systemd/system/${SERVICE_NAME}"

# Define ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\e[36m'
MAGENTA="\e[95m"
NC='\033[0m' # No Color

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root!${NC}" 
   sleep 1
   exit 1
fi

# Fetch Server IP
SERVER_IP=$(hostname -I | awk '{print $1}')

# just press key to continue
press_key(){
    read -p "Press Enter to continue..."
}

# Function to display ASCII logo
display_logo() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
 ____       _          _____                      _ 
|  _ \ __ _(_)___  ___|_   _|   _ _ __  _ __   ___| |
| |_) / _` | / __|/ _ \ | || | | | '_ \| '_ \ / _ \ |
|  _ < (_| | \__ \  __/ | || |_| | | | | | | |  __/ |
|_| \_\__,_|_|___/\___| |_| \__,_|_| |_|_| |_|\___|_|
 
EOF
    echo -e "${NC}${GREEN}${APP_NAME} Interactive Installer - Version: ${YELLOW}${SCRIPT_VERSION}${NC}\n"
}

# Function to display server and service info
display_status_header() {
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo -e "Service Status : ${GREEN}Active & Running${NC}"
    else
        echo -e "Service Status : ${RED}Not Running / Not Installed${NC}"
    fi
    echo -e "Server IP      : ${CYAN}$SERVER_IP${NC}"
    echo -e "═══════════════════════════════════════════"
}

# Function to configure and install tunnel
install_tunnel() {
    clear
    display_logo
    echo -e "${YELLOW}--- Configure New ${APP_NAME} ---${NC}\n"

    # 1. Get Public IPs
    read -p "[*] Enter IRAN Server IP (Public): " IRAN_IP
    read -p "[*] Enter KHAREJ Server IP (Public): " KHAREJ_IP

    echo
    # 2. Determine Location
    echo -e "${CYAN}Where are you running this script right now?${NC}"
    echo "1) IRAN Server"
    echo "2) KHAREJ Server"
    read -p "Enter choice (1 or 2): " LOC_CHOICE

    if [[ "$LOC_CHOICE" == "1" ]]; then
        LOCAL_IP=$IRAN_IP
        REMOTE_IP=$KHAREJ_IP
        DEF_TUN="10.20.20.1/30"
    elif [[ "$LOC_CHOICE" == "2" ]]; then
        LOCAL_IP=$KHAREJ_IP
        REMOTE_IP=$IRAN_IP
        DEF_TUN="10.20.20.2/30"
    else
        echo -e "${RED}Invalid choice! Operation canceled.${NC}"
        sleep 1
        return
    fi

    echo
    # 3. Get Tunnel IP with Default value
    read -p "[*] Enter Tunnel IP [Default: $DEF_TUN]: " TUNNEL_IP
    TUNNEL_IP=${TUNNEL_IP:-$DEF_TUN}

    echo -e "\n${CYAN}Creating Systemd Service for Persistence...${NC}"

    # Clean existing interface if present to avoid conflicts
    ip link show $TUNNEL_IF &> /dev/null && ip link delete $TUNNEL_IF

    # 4. Write Systemd Service File (This makes it permanent)
    cat << EOF > "$SERVICE_PATH"
[Unit]
Description=${APP_NAME} Service
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/sbin/ip tunnel add $TUNNEL_IF mode gre remote $REMOTE_IP local $LOCAL_IP ttl 255
ExecStart=/sbin/ip link set $TUNNEL_IF up
ExecStart=/sbin/ip addr add $TUNNEL_IP dev $TUNNEL_IF
ExecStop=/sbin/ip link set $TUNNEL_IF down
ExecStop=/sbin/ip tunnel del $TUNNEL_IF

[Install]
WantedBy=multi-user.target
EOF

    # 5. Enable and Start Service
    systemctl daemon-reload
    systemctl enable "$SERVICE_NAME" >/dev/null 2>&1
    systemctl start "$SERVICE_NAME"

    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo -e "\n${GREEN}✔ ${APP_NAME} successfully configured and started!${NC}"
        echo -e "✔ The tunnel is now ${YELLOW}permanent${NC} and will start automatically on boot."
    else
        echo -e "\n${RED}✘ Failed to start the tunnel. Check logs with: journalctl -xeu $SERVICE_NAME${NC}"
    fi
    
    echo
    press_key
}

# Function to check detailed status
check_status() {
    clear
    display_logo
    echo -e "${CYAN}--- ${APP_NAME} Status ---${NC}\n"
    
    ip link show $TUNNEL_IF &>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✔] Interface '$TUNNEL_IF' is ACTIVE.${NC}\n"
        ip -4 addr show $TUNNEL_IF
        echo
        ip tunnel show $TUNNEL_IF
    else
        echo -e "${RED}[✘] Interface '$TUNNEL_IF' is DOWN or NOT EXISTS.${NC}"
    fi

    echo -e "\n${YELLOW}Systemd Service Status:${NC}"
    if [[ -f "$SERVICE_PATH" ]]; then
        systemctl status "$SERVICE_NAME" --no-pager | head -n 8
    else
        echo -e "${CYAN}Service file not found. It might not be installed yet.${NC}"
    fi

    echo
    press_key
}

# Function to safely remove the tunnel
remove_tunnel() {
    clear
    echo -e "${YELLOW}Removing ${APP_NAME}...${NC}\n"
    
    # Check and remove Systemd service
    if [[ -f "$SERVICE_PATH" ]]; then
        systemctl stop "$SERVICE_NAME" &>/dev/null
        systemctl disable "$SERVICE_NAME" &>/dev/null
        rm -f "$SERVICE_PATH"
        systemctl daemon-reload
        echo -e "${GREEN}✔ Systemd service removed.${NC}"
    else
        echo -e "${CYAN}No systemd service found to remove.${NC}"
    fi

    # Remove network interface
    ip link show $TUNNEL_IF &> /dev/null
    if [ $? -eq 0 ]; then
        ip link delete $TUNNEL_IF &>/dev/null
        echo -e "${GREEN}✔ Interface '$TUNNEL_IF' deleted.${NC}"
    fi

    echo -e "\n${GREEN}Tunnel completely removed from the system.${NC}\n"
    press_key
}

# Main Menu Loop
while true; do
    display_logo
    display_status_header
    
    echo -e " ${GREEN}1.${NC} Configure and Install ${APP_NAME}"
    echo -e " ${CYAN}2.${NC} Check Tunnel Status"
    echo -e " ${RED}3.${NC} Remove ${APP_NAME}"
    echo -e " ${YELLOW}0.${NC} Exit"
    echo -e "\n-------------------------------"
    
    read -p "Enter your choice [0-3]: " opt
    
    case $opt in
        1) install_tunnel ;;
        2) check_status ;;
        3) remove_tunnel ;;
        0) clear; exit 0 ;;
        *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
    esac
done
