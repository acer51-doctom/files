#!/bin/bash

# Ensure the script exits on any error
set -e

echo "--- NordVPN Arch Installer ---"

# 1. Update system
echo "[1/6] Updating system..."
sudo pacman -Syu --noconfirm

# 2. Check for AUR helper
if command -v yay &> /dev/null; then
    AUR_HELPER="yay"
elif command -v paru &> /dev/null; then
    AUR_HELPER="paru"
else
    read -p "No AUR helper (yay/paru) found. Install 'yay' now? (y/n): " install_yay
    if [[ $install_yay =~ ^[Yy]$ ]]; then
        sudo pacman -S --needed base-devel git --noconfirm
        git clone https://aur.archlinux.org/yay.git
        cd yay && makepkg -si --noconfirm && cd ..
        rm -rf yay
        AUR_HELPER="yay"
    else
        echo "An AUR helper is required. Exiting."
        exit 1
    fi
fi

# 3. Install NordVPN CLI and dependencies
echo "[2/6] Installing NordVPN CLI (nordvpn-bin)..."
$AUR_HELPER -S nordvpn-bin --noconfirm

# 4. Install NordVPN GUI
echo "[3/6] Installing NordVPN GUI (nordvpn-gui-bin)..."
$AUR_HELPER -S nordvpn-gui-bin --noconfirm

# 5. Enable and start the service
echo "[4/6] Setting up systemd services..."
sudo systemctl enable --now nordvpnd.service

# 6. User Group Permissions
echo "[5/6] Adding $USER to the nordvpn group..."
sudo usermod -aG nordvpn $USER

echo "--------------------------------------------------"
echo "SUCCESS: NordVPN CLI and GUI are installed."
echo "NOTE: As it is a must to reboot or log out and log back it,"
echo "We will promptly reboot in 10 seconds. To cancel, immediately press Ctrl+C!!"
echo "(So you can later reboot on your own)"
echo "--------------------------------------------------"

# Loop from 10 down to 1
for i in {10..1}
do
    # -n keeps the output on the same line
    echo -n "$i... "
    # Wait for 1 second
    sleep 1
done

echo "0!"
echo "Goodbye!"
sudo reboot
