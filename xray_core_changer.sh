#!/bin/bash

# Stop kardan service-ha
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

# 1. Gereftan-e akharin version XTLS
echo "🌐 Dar hal-e gereftan-e akharin version XTLS Xray-core..."
latest_xtls=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep tag_name | cut -d '"' -f4)
link_xtls="https://github.com/XTLS/Xray-core/releases/download/${latest_xtls}/Xray-linux-${arch_name}.zip"

# 2. Gereftan-e akharin version GFW-knocker
echo "🌐 Dar hal-e gereftan-e akharin version GFW-knocker Xray-core..."
latest_gfw=$(curl -s https://api.github.com/repos/GFW-knocker/Xray-core/releases/latest | grep tag_name | cut -d '"' -f4)
link_gfw="https://github.com/GFW-knocker/Xray-core/releases/download/${latest_gfw}/Xray-linux-${arch_name}.zip"

echo ""
echo "📦 Lotfan yeki az gozine-haye zir ra entekhab konid:"
echo "────────────────────────────────────────────"
echo " 1. 🚀 XTLS Latest ($latest_xtls)"
echo " 2. 🛡️ GFW-knocker Latest ($latest_gfw)"
echo " 3. ✏️  Vared kardan-e link-e delkhah"
echo "────────────────────────────────────────────"

# Gereftan-e entekhab az karbar
while true; do
    read -p "👉 Shomare-ye gozine را وارد کنید: " choice
    case $choice in
        1)
            link=$link_xtls
            echo "✅ Shoma XTLS ra entekhab kardid."
            break
            ;;
        2)
            link=$link_gfw
            echo "✅ Shoma GFW-knocker ra entekhab kardid."
            break
            ;;
        3)
            read -p "✍️ Lotfan link-e delkhah-e khod ra vared konid: " custom_link
            link=$custom_link
            echo "✅ Link-e delkhah-e shoma: $link"
            break
            ;;
        *)
            echo "❗ Lotfan gozine-ye sahih (1, 2 ya 3) vared konid."
            ;;
    esac
done

# Edame-ye nasb
clear
echo "🧹 Dar hal-e pak kardan-e file-haye ghabli..."
rm -rf /opt/hiddify-manager/xray/bin/*

echo "⬇️ Dar hal-e download-e file Xray..."
wget "$link" -O xray.zip || { echo "❌ Download ba moshkel movajeh shod."; exit 1; }

echo "🗂️ Dar hal-e extract kardan-e file..."
unzip -o xray.zip -d /opt/hiddify-manager/xray/bin/

echo "🧽 Dar hal-e hazf-e file-e zip..."
rm xray.zip

echo "🔐 Dadan-e dastرسی-ye ejraei..."
chmod +x /opt/hiddify-manager/xray/bin/xray

# Ejra-ye script-haye restart
echo "🚀 Dar hal-e restart-e service-ha..."
bash /opt/hiddify-manager/restart.sh
bash /opt/hiddify-manager/apply_configs.sh

# Pishnahad-e reboot
read -p "🔁 Aya mikhahid system ra reboot konid? (y/n): " restart_ans
if [[ "$restart_ans" == "y" ]]; then
    sudo reboot
fi
