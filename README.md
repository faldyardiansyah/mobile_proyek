# 🏡 appkonkos_mobile

[![Flutter Version](https://img.shields.io/badge/Flutter-%E2%9C%93-02569B?style=flat&logo=flutter)](https://flutter.dev)
[![GetX State Management](https://img.shields.io/badge/State%20Management-GetX-29B6F6?style=flat)](https://pub.dev/packages/get)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-34A853?style=flat&logo=android)](https://flutter.dev)

**appkonkos_mobile** (Aplikasi Pencarian Kosan & Kontrakan) adalah aplikasi mobile berbasis Flutter yang dirancang khusus untuk memudahkan **User (Pencari Kos)** dalam menemukan, memilih, dan memesan properti hunian secara digital, cepat, dan transparan.

Aplikasi pada repositori ini dikembangkan khusus sebagai *client application* untuk sisi pengguna (tanpa panel admin) yang terintegrasi dengan **Dedicated Mobile RESTful API**, visual animasi interaktif, serta asisten AI cerdas untuk rekomendasi berbasis lokasi.

---

## ✨ Fitur Utama (Mobile User App)

- **🤖 Smart AI Chatbot Recommendation**: Fitur asisten virtual pintar yang dapat memberikan rekomendasi kosan secara otomatis berdasarkan kata kunci wilayah (Contoh: *"kosan di Indramayu"*). AI akan menyaring data secara cerdas untuk menampilkan kosan dengan **jarak terdekat (di bawah 10 km) dari lokasi user** serta mengurutkannya berdasarkan **rating tertinggi**.
- **🏠 Interactive House Moving Animation**: Mengintegrasikan animasi rumah bergerak modern berbasis **Lottie (JSON)** yang diimplementasikan pada komponen *Splash Screen* dan *Loading State* (seperti saat Chatbot AI sedang melakukan kalkulasi pencarian data kos). Menghadirkan visualisasi transisi aplikasi yang hidup, dinamis, dan interaktif.
- **📅 Sistem Booking Langsung**: User dapat melakukan pemesanan (*booking*) kamar kos atau kontrakan secara langsung melalui aplikasi mobile dengan proses yang cepat dan mudah.
- **✨ Smooth UI & Micro-animations**: Antarmuka interaktif yang memanfaatkan engine animasi pada elemen kartu properti dan tombol untuk memberikan pengalaman premium (*smooth user experience*) kepada user.
- **🔍 Filter Pencarian Cerdas**: Memungkinkan user mencari hunian berdasarkan titik lokasi, range harga, tipe kamar (putra/putri/campur), serta fasilitas yang tersedia.
- **🔐 Secure Authentication & Deep Linking**: Sistem registrasi dan login yang aman dibekali fitur **Deep Link Email Verification** untuk validasi akun langsung mengarah kembali ke aplikasi mobile.

---

## 🛠️ Arsitektur & Teknologi (Mobile & Dedicated API)

Sistem APPKONKOS menggunakan arsitektur terpisah (*decoupled architecture*). Repositori ini mencakup seluruh ekosistem mobile yang dibangun secara mandiri oleh **Faldy Ardiansyah**:

- **Mobile Client App (User Side)**: Dibangun menggunakan **Flutter (Dart)** dengan pola arsitektur **GetX** sebagai manajer status, rute navigasi, dan *dependency injection* agar aplikasi tetap ringan dan responsif.
- **Animation Engine**: Menggunakan library package `lottie` untuk merender komponen grafis vektor bergerak berkualitas tinggi tanpa membebani performa memori perangkat.
- **Dedicated Mobile API (Back-End)**: RESTful API khusus yang dirancang menggunakan **Laravel** untuk menangani seluruh logika pemesanan (*booking*), kalkulasi algoritma jarak & rating untuk AI Chatbot, manajemen database (MySQL/Oracle), serta autentikasi user.

> 💡 *Catatan Hubungan Sistem: Aplikasi mobile ini fokus 100% pada sisi User/Pencari Kos*

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
