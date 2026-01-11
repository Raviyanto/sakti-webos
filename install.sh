#!/bin/sh

# Pastikan skrip dijalankan sebagai root
if [ "$(id -u)" -ne 0 ]; then
   echo "? Skrip ini harus dijalankan sebagai root!"
   exit 1
fi

echo "=== ?? Memulai Instalasi Sakti WebOS ==="

# --- BAGIAN 1: User & Environment ---
# Cek User 'kioskuser'
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

# Hapus driver vmware jika ada & aktifkan service penting
apk del xf86-video-vmware 2>/dev/null
rc-update add udev sysinit
rc-update add udev-trigger sysinit

# --- BAGIAN 3: Autologin (Modular) ---
echo "[+] Mengonfigurasi Autologin..."

# A. Matikan tty1 bawaan (beri tanda pagar # di depannya)
sed -i 's/^tty1:/#tty1:/g' /etc/inittab

# B. Suntikkan konfigurasi dari file system/autologin_tty
if ! grep -q "autologin kioskuser" /etc/inittab; then
    if [ -f "system/autologin_tty" ]; then
        echo "# Sakti WebOS Autologin" >> /etc/inittab
        cat system/autologin_tty >> /etc/inittab
        echo "[OK] Autologin berhasil ditambahkan dari system/autologin_tty."
    else
        echo "? ERROR: File system/autologin_tty tidak ditemukan!"
        exit 1
    fi
else
    echo "[INFO] Konfigurasi autologin sudah ada."
fi

# --- BAGIAN 4: Setup Aplikasi ---
echo "[+] Menyalin File Aplikasi..."
APP_DIR="/home/kioskuser"

# Pastikan folder tujuan bersih/siap
mkdir -p $APP_DIR

# Salin folder backend & frontend
cp -r backend $APP_DIR/
cp -r frontend $APP_DIR/

# --- BAGIAN 5: The Magic (Config Files) ---
echo "[+] Menerapkan Konfigurasi Sistem..."

# Salin dotfiles ke home directory user
cp system/dot_profile $APP_DIR/.profile
cp system/dot_xinitrc $APP_DIR/.xinitrc
chmod +x $APP_DIR/.xinitrc

# Setup Fluxbox (Window Manager)
mkdir -p $APP_DIR/.fluxbox
cp system/fluxbox_apps $APP_DIR/.fluxbox/apps

# Setup Sudoers (Shutdown tanpa password)
cp system/kiosk_shutdown /etc/sudoers.d/kiosk_shutdown
chmod 0440 /etc/sudoers.d/kiosk_shutdown

# --- FINALISASI ---
echo "[+] Memperbaiki Izin File..."
chown -R kioskuser:kioskuser $APP_DIR

echo " "
echo "=== ? Instalasi Selesai! ==="
echo "Silakan reboot sistem dengan mengetik: reboot"
