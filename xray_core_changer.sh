#!/bin/bash

# Stop kardan service-ha
echo "🛑 Dar hal-e motevaghef kardan-e service-ha..."
service hiddify-xray stop
service hiddify-haproxy stop
clear

echo "🔍 Dar hal-e tashkhis-e me'mari-ye system..."
arch=$(uname -m)
case $arch in
    x86_64)
        arch_name="64"
        ;;
    aarch64)
        arch_name="arm64-v8a"
        ;;
    *)
        echo "❌ Me'mari-ye system poshtibani nemishavad: $arch"
        exit 1
        ;;
esac

# 1. XTLS Latest
echo "🌐 Gereftan-e version-e XTLS..."
latest_xtls=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
link_xtls="https://github.com/XTLS/Xray-core/releases/download/${latest_xtls}/Xray-linux-${arch_name}.zip"

# 2. GFW-knocker Latest
echo "🌐 Gereftan-e version-e GFW-knocker..."
latest_gfw=$(curl -s https://api.github.com/repos/GFW-knocker/Xray-core/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
link_gfw="https://github.com/GFW-knocker/Xray-core/releases/download/${latest_gfw}/Xray-linux-${arch_name}.zip"

echo ""
echo "📦 Entekhab-e Core:"
echo "────────────────────────────────────────────"
echo " 1. 🚀 XTLS Latest ($latest_xtls)"
echo " 2. 🛡️ GFW-knocker Latest ($latest_gfw)"
echo " 3. ✏️  Vared kardan-e link-e delkhah"
echo "────────────────────────────────────────────"

while true; do
    read -p "👉 Shomare ra vared konid: " choice
    case $choice in
        1) link=$link_xtls; break ;;
        2) link=$link_gfw; break ;;
        3) read -p "✍️ Link را وارد کنید: " custom_link; link=$custom_link; break ;;
        *) echo "❗ Gozine na-motabar." ;;
    esac
done

clear
echo "⬇️ Download az: $link"
# Download ba check kardan-e khat-a
wget -q --show-progress "$link" -O xray.zip

if [ $? -ne 0 ]; then
    echo "❌ Khata: Download anjam nashod! Lotfan link ya internet ra check konid."
    exit 1
fi

echo "🧹 Pak-sazi va Extract..."
rm -rf /opt/hiddify-manager/xray/bin/*
unzip -o xray.zip -d /opt/hiddify-manager/xray/bin/
rm xray.zip

chmod +x /opt/hiddify-manager/xray/bin/xray

echo "🚀 Restarting..."
bash /opt/hiddify-manager/restart.sh
bash /opt/hiddify-manager/apply_configs.sh

read -p "🔁 Reboot system? (y/n): " restart_ans
[[ "$restart_ans" == "y" ]] && sudo reboot
