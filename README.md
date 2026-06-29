# 🏡 appkonkos_mobile

[![Flutter Version](https://img.shields.io/badge/Flutter-%E2%9C%93-02569B?style=flat&logo=flutter)](https://flutter.dev)
[![GetX State Management](https://img.shields.io/badge/State%20Management-GetX-29B6F6?style=flat)](https://pub.dev/packages/get)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-34A853?style=flat&logo=android)](https://flutter.dev)

**appkonkos_mobile** (Aplikasi Pencarian Kosan & Kontrakan) adalah aplikasi mobile berbasis Flutter yang dirancang untuk mempermudah pencarian, pengelolaan, dan penyewaan properti seperti rumah kos dan kontrakan secara digital, efisien, dan transparan.

Aplikasi ini mengintegrasikan manajemen status yang responsif menggunakan **GetX** serta fitur modern seperti verifikasi email via deep linking, yang terhubung langsung dengan sistem backend RESTful API.

---

## ✨ Fitur Utama

- **Pencarian Properti Cerdas**: Cari kos atau kontrakan berdasarkan lokasi, fasilitas, harga, dan tipe kamar.
- **Manajemen Autentikasi**: Registrasi dan login pengguna yang aman dengan fitur **Deep Link Email Verification** untuk validasi akun.
- **Detail Properti Komplit**: Informasi lengkap mengenai fasilitas, foto properti, harga sewa, sisa kamar, serta integrasi peta lokasi.
- **Sistem Pengelolaan Properti (Owner)**: Pemilik kos dapat mengunggah properti, mengupdate ketersediaan kamar, dan memantau riwayat penyewa.
- **Riwayat & Status Transaksi**: Halaman riwayat pemesanan yang informatif untuk memantau status sewa dan pembayaran secara real-time.

---

## 🛠️ Arsitektur & Teknologi

Sebagai pengembang tunggal, sistem ini dibangun secara *end-to-end* menggunakan teknologi terkini untuk memastikan performa tinggi dan skalabilitas yang baik:

- **Mobile Client (Front-End)**: [Flutter](https://flutter.dev/) (Dart) dengan arsitektur **GetX** untuk manajemen status, rute, dan injeksi dependensi secara bersih dan responsif.
- **Deep Linking**: Penanganan verifikasi email menggunakan deep link yang langsung diarahkan kembali ke dalam aplikasi mobile.
- **RESTful API (Back-End)**: Dikembangkan secara mandiri menggunakan **Laravel** untuk menangani seluruh logika bisnis, database (MySQL/Oracle), autentikasi, serta komunikasi data yang aman dengan aplikasi mobile.

---

## 🚀 Memulai (Getting Started)

### Prasyarat
Sebelum menjalankan proyek ini, pastikan Anda telah menginstal:
- Flutter SDK (Versi terbaru disarankan)
- Android Studio / VS Code dengan ekstensi Flutter & Dart
- Emulator Android / iOS atau perangkat fisik yang terhubung

### Instalasi Langkah Demi Langkah

1. **Clone Repositori**
   ```bash
   git clone [https://github.com/faldyardiansyah/mobile_proyek.git](https://github.com/faldyardiansyah/mobile_proyek.git)
   cd mobile_proyek
