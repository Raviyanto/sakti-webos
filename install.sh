#!/bin/sh

# Pastikan skrip dijalankan sebagai root
if [ "$(id -u)" -ne 0 ]; then
   echo "❌ Skrip ini harus dijalankan sebagai root!"
   exit 1
fi

echo "=== 🚀 Memulai Instalasi Sakti WebOS ==="

# --- BAGIAN 1: User & Environment ---
if id "kioskuser" >/dev/null 2>&1; then
    echo "[OK] User 'kioskuser' ditemukan."
else
    echo "[+] Membuat user 'kioskuser'..."
    adduser -D kioskuser
fi

# --- BAGIAN 2: Paket Sistem ---
echo "[+] Menginstal Paket Sistem (Mohon tunggu)..."
setup-xorg-base
apk add chromium xf86-video-vesa xf86-video-fbdev xf86-input-libinput \
    eudev mesa-dri-gallium font-noto python3 py3-flask fluxbox \
    xterm sudo util-linux

apk del xf86-video-vmware 2>/dev/null
rc-update add udev sysinit
rc-update add udev-trigger sysinit

# --- BAGIAN 3: Autologin (Modular) ---
echo "[+] Mengonfigurasi Autologin..."
sed -i 's/^tty1:/#tty1:/g' /etc/inittab
if ! grep -q "autologin kioskuser" /etc/inittab; then
    if [ -f "system/autologin_tty" ]; then
        echo "# Sakti WebOS Autologin" >> /etc/inittab
        cat system/autologin_tty >> /etc/inittab
        echo "[OK] Autologin berhasil ditambahkan."
    else
        echo "❌ ERROR: File system/autologin_tty tidak ditemukan!"
        exit 1
    fi
else
    echo "[INFO] Konfigurasi autologin sudah ada."
fi

# --- BAGIAN 4: Setup Aplikasi ---
echo "[+] Menyalin File Aplikasi..."
APP_DIR="/home/kioskuser"
mkdir -p $APP_DIR

# [TAMBAHAN BARU]: Menyalin file browser utama Sakti OS
if [ -f "browser_sakti.py" ]; then
    cp browser_sakti.py $APP_DIR/
    chmod +x $APP_DIR/browser_sakti.py
    echo "[OK] browser_sakti.py berhasil dipasang."
fi

# Salin folder backend & frontend secara rekursif
# Ini otomatis mengangkut template baru & folder static (favicon, dll)
cp -r backend $APP_DIR/
cp -r frontend $APP_DIR/

# --- BAGIAN 5: The Magic (Config Files) ---
echo "[+] Menerapkan Konfigurasi Sistem..."
cp system/dot_profile $APP_DIR/.profile
cp system/dot_xinitrc $APP_DIR/.xinitrc
chmod +x $APP_DIR/.xinitrc

mkdir -p $APP_DIR/.fluxbox
cp system/fluxbox_apps $APP_DIR/.fluxbox/apps

cp system/kiosk_shutdown /etc/sudoers.d/kiosk_shutdown
chmod 0440 /etc/sudoers.d/kiosk_shutdown

# --- FINALISASI ---
echo "[+] Memperbaiki Izin File..."
chown -R kioskuser:kioskuser $APP_DIR

echo " "
echo "=== 🎉 Instalasi Selesai! ==="
echo "Silakan reboot sistem dengan mengetik: reboot"
