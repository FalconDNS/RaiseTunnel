#!/bin/bash

GREEN='\033[0;32m'
CYAN='\e[36m'
NC='\033[0m'

echo -e "${CYAN}Downloading and Installing RaiseTunnel...${NC}"

# دانلود فایل اصلی از گیت‌هاب و ذخیره در مسیر دستورات اجرایی لینوکس
curl -Ls https://raw.githubusercontent.com/FalconDNS/RaiseTunnel/main/raisetunnel.sh -o /usr/local/bin/raisetunnel

# دادن دسترسی اجرا به فایل
chmod +x /usr/local/bin/raisetunnel

echo -e "${GREEN}✔ RaiseTunnel installed successfully!${NC}"
echo -e "You can now type ${CYAN}raisetunnel${NC} anywhere in your terminal to manage your tunnels."
echo -e "================================================="
sleep 2

# اجرای اتوماتیک اسکریپت بعد از پایان نصب
raisetunnel
