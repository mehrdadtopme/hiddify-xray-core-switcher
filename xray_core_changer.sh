cat << 'EOF' > /root/changer.sh
#!/bin/bash
service hiddify-xray stop
service hiddify-haproxy stop
clear
arch=$(uname -m)
case $arch in
    x86_64) arch_name="64" ;;
    aarch64) arch_name="arm64-v8a" ;;
    *) echo "Unsupported arch"; exit 1 ;;
esac
latest_xtls=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
link_xtls="https://github.com/XTLS/Xray-core/releases/download/${latest_xtls}/Xray-linux-${arch_name}.zip"
latest_gfw=$(curl -s https://api.github.com/repos/GFW-knocker/Xray-core/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
link_gfw="https://github.com/GFW-knocker/Xray-core/releases/download/${latest_gfw}/Xray-linux-${arch_name}.zip"
echo "1. XTLS ($latest_xtls)"
echo "2. GFW-knocker ($latest_gfw)"
echo "3. Custom Link"
read -p "Select: " choice
case $choice in
    1) link=$link_xtls ;;
    2) link=$link_gfw ;;
    3) read -p "Link: " link ;;
esac
rm -rf /opt/hiddify-manager/xray/bin/*
wget -q --show-progress "$link" -O xray.zip && unzip -o xray.zip -d /opt/hiddify-manager/xray/bin/
chmod +x /opt/hiddify-manager/xray/bin/xray
rm xray.zip
bash /opt/hiddify-manager/restart.sh
bash /opt/hiddify-manager/apply_configs.sh
EOF

chmod +x /root/changer.sh
/root/changer.sh
