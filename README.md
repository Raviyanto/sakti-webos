# Sakti WebOS (Kiosk Edition)

**Sakti WebOS** adalah resep sistem operasi eksperimental berbasis **Alpine Linux** dan **Web Technology (Flask + HTML)**.
Proyek ini mengubah instalasi Alpine Linux standar menjadi mesin Kiosk (Single App Mode) yang ringan, cepat, dan modern.

## Struktur Repository
* **backend/**: Otak sistem (Flask).
* **frontend/**: Wajah sistem (HTML/CSS).
* **system/**: Konfigurasi vital OS.
* **install.sh**: Skrip instalasi otomatis.

## Panduan Instalasi

### Prasyarat
1. Alpine Linux (Standard Version) sudah terinstal.
2. Login sebagai **root**.
3. Koneksi internet aktif.

### Langkah 1: Persiapan
Instal Git dan clone repository ini:
```bash
apk add git
git clone https://github.com/Raviyanto/sakti-webos.git
cd sakti-webos
```

### Langkah 2: Instalasi (Pilih Salah Satu)

#### A. Cara Otomatis (Direkomendasikan)
Jalankan skrip instalasi yang sudah disediakan:
```bash
chmod +x install.sh
./install.sh
```

#### B. Cara Manual (Langkah demi Langkah)
Jika skrip otomatis gagal atau Anda ingin belajar:

**1. Instal Paket Sistem**
```bash
setup-xorg-base
apk add chromium xf86-video-vesa xf86-video-fbdev xf86-input-libinput eudev mesa-dri-gallium font-noto python3 py3-flask fluxbox xterm sudo util-linux
apk del xf86-video-vmware
rc-update add udev sysinit
rc-update add udev-trigger sysinit
```

**2. Buat User & Autologin**
```bash
adduser -D kioskuser
# Edit /etc/inittab manual, atau jalankan:
sed -i "s/^tty1:/#tty1:/g" /etc/inittab
echo "tty1::respawn:/sbin/agetty --autologin kioskuser --noclear tty1 linux" >> /etc/inittab
```

**3. Setup Aplikasi**
```bash
cp -r backend /home/kioskuser/
cp -r frontend /home/kioskuser/
chown -R kioskuser:kioskuser /home/kioskuser
```

**4. Setup Konfigurasi Sistem**
```bash
cp system/dot_profile /home/kioskuser/.profile
cp system/dot_xinitrc /home/kioskuser/.xinitrc
chmod +x /home/kioskuser/.xinitrc
mkdir -p /home/kioskuser/.fluxbox
cp system/fluxbox_apps /home/kioskuser/.fluxbox/apps
cp system/kiosk_shutdown /etc/sudoers.d/kiosk_shutdown
chmod 0440 /etc/sudoers.d/kiosk_shutdown
```

**5. Selesai**
Jalankan perintah `reboot`.

## Lisensi
GPL-3.0 License
