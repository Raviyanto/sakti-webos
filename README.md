# Sakti WebOS

Sakti WebOS adalah proyek eksperimental untuk membangun Sistem Operasi modern berbasis web.

## Arsitektur

Proyek ini dibangun di atas tiga pilar utama:

1.  **Fondasi:** Alpine Linux (Ringan dan aman).
2.  **Backend (Otak):** Python (Flask/FastAPI) yang berfungsi sebagai jembatan antara antarmuka web dan kernel sistem.
3.  **Frontend (Wajah):** HTML/CSS/JS modern yang berjalan di atas Chromium Browser dalam mode Kiosk (layar penuh).

## Status Proyek

🚧 **Dalam Tahap Pengembangan Awal (Pre-Alpha)** 🚧

Saat ini proyek sedang dalam tahap pembangunan kerangka dasar dan arsitektur.

## Struktur Repositori

* `/backend`: Kode sumber Python untuk server lokal dan API sistem.
* `/frontend`: Kode sumber antarmuka pengguna berbasis web.
* `/system`: Skrip konfigurasi dan panduan instalasi untuk Alpine Linux.