# 🏡 appkonkos_mobile

[![Flutter Version](https://img.shields.io/badge/Flutter-%E2%9C%93-02569B?style=flat&logo=flutter)](https://flutter.dev)
[![GetX State Management](https://img.shields.io/badge/State%20Management-GetX-29B6F6?style=flat)](https://pub.dev/packages/get)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-34A853?style=flat&logo=android)](https://flutter.dev)

**appkonkos_mobile** (Aplikasi Pencarian Kosan & Kontrakan) adalah aplikasi mobile berbasis Flutter yang dirancang untuk mempermudah pencarian, pengelolaan, dan penyewaan properti seperti rumah kos dan kontrakan secara digital, efisien, dan transparan.

Proyek pada repositori ini berfokus penuh pada **Mobile Client App** serta **Dedicated Mobile RESTful API** yang dibangun secara terintegrasi untuk menyajikan performa aplikasi yang cepat, aman, dan interaktif.

---

## ✨ Fitur Utama (Mobile App)

- **🤖 Smart AI Chatbot Assistant**: Fitur asisten virtual pintar terintegrasi di dalam aplikasi untuk membantu memberikan rekomendasi kosan terbaik dan menjawab pertanyaan pengguna secara real-time.
- **✨ Rich Animations & Smooth UI**: Antarmuka aplikasi yang interaktif memanfaatkan engine animasi modern (Lottie & Micro-animations) untuk transisi halaman dan interaksi elemen UI yang mulus.
- **Pencarian Properti Cerdas**: Fitur filter pencarian kos atau kontrakan berdasarkan lokasi, fasilitas, harga, dan tipe kamar.
- **Manajemen Autentikasi**: Registrasi dan login pengguna yang aman dengan dukungan fitur **Deep Link Email Verification** untuk validasi akun langsung ke aplikasi mobile.
- **Sistem Pengelolaan Properti (Owner)**: Modul khusus bagi pemilik kos untuk mengunggah properti, memperbarui ketersediaan kamar, dan memantau penyewa melalui genggaman.

---

## 🛠️ Arsitektur & Teknologi (Mobile & Dedicated API)

Dalam pengembangan sistem APPKONKOS, arsitektur dibagi menjadi beberapa *service* terpisah. Repositori ini mencakup seluruh ekosistem mobile yang dikembangkan secara mandiri oleh **Faldy Ardiansyah**:

- **Mobile Client App**: Dibangun menggunakan **Flutter (Dart)** dengan pola arsitektur **GetX** untuk manajemen status, rute navigasi, dan *dependency injection* yang efisien.
- **Dedicated Mobile API (Back-End)**: RESTful API khusus yang dirancang dan dibangun menggunakan **Laravel** untuk melayani seluruh pertukaran data, manajemen database (MySQL/Oracle), autentikasi aman, dan integrasi pihak ketiga (AI Core & Deep Linking) khusus untuk aplikasi mobile.

> 💡 *Catatan Sistem: Sistem ini beroperasi secara berdampingan dengan platform web APPKONKOS (Web Front-End & Back-End) yang dikembangkan secara terpisah oleh rekan tim (Hannif).*

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
