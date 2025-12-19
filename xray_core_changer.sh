#!/bin/bash

set -e

# Stop services
service hiddify-xray stop || true
service hiddify-haproxy stop || true
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

# گرفتن آخرین نسخه رسمی XTLS
echo "🌐 Gereftan-e akharin version rasmi XTLS..."
xtls_version=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep tag_name | cut -d '"' -f4)
xtls_link="https://github.com/XTLS/Xray-core/releases/download/${xtls_version}/Xray-linux-${arch_name}.zip"

# گرفتن آخرین نسخه mahsa / GFW
echo "🌐 Gereftan-e akharin version mahsa (GFW-knocker)..."
mahsa_version=$(curl -s https://api.github.com/repos/GFW-knocker/Xray-core/releases/latest | grep tag_name | cut -d '"' -f4)
mahsa_link="https://github.com/GFW-knocker/Xray-core/releases/download/${mahsa_version}/Xray-linux-${arch_name}.zip"

options_links=(
    "$xtls_link"
    "$mahsa_link"
)

echo ""
echo "📦 Lotfan yeki az gozine-haye zir ra entekhab konid:"
echo "────────────────────────────────────────────"
echo " 1️⃣  XTLS (Resmi)  → $xtls_version"
echo " 2️⃣  Mahsa / GFW   → $mahsa_version"
echo " 3️⃣  ✏️  Vared kardan-e link-e delkhah"
echo "────────────────────────────────────────────"

while true; do
    read -p "👉 Shomare-ye gozine ra vared konid: " choice
    if [[ "$choice" == "1" ]]; then
        link="$xtls_link"
        break
    elif [[ "$choice" == "2" ]]; then
        link="$mahsa_link"
        break
    elif [[ "$choice" == "3" ]]; then
        read -p "✍️ Link-e delkhah ra vared konid: " link
        break
    else
        echo "❗ Gozine-ye sahih vared konid."
    fi
done

clear
echo "🧹 Pak kardan-e xray ghabli..."
rm -f /opt/hiddify-manager/xray/bin/xray

echo "⬇️ Download-e hسته..."
wget "$link" -O xray.zip

echo "🗂️ Extract..."
unzip -o xray.zip -d /opt/hiddify-manager/xray/bin/

echo "🧽 Pak kardan-e zip..."
rm -f xray.zip

chmod +x /opt/hiddify-manager/xray/bin/xray

echo "🚀 Restart service-ha..."
bash /opt/hiddify-manager/restart.sh
bash /opt/hiddify-manager/apply_configs.sh

echo "✅ Anjam shod."
