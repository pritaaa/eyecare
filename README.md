# 👁️ EyeGuard — Eye Care App

Aplikasi mobile berbasis Flutter untuk membantu pengguna menjaga kesehatan mata di tengah tingginya intensitas penggunaan layar (screen time). EyeGuard memantau kebiasaan digital pengguna, mengingatkan waktu istirahat mata, menyediakan tes ketajaman penglihatan sederhana, hingga membantu menemukan klinik mata terdekat.

## ✨ Fitur

- **🔐 Autentikasi** — Alur login & signup dengan sesi tersimpan secara lokal.
- **🏠 Home Dashboard** — Ringkasan aktivitas harian lengkap dengan kartu "Tip of the Day".
- **👁️ Tes Ketajaman Mata** — Tes berbasis Snellen chart untuk mengecek kondisi penglihatan, lengkap dengan halaman hasil.
- **⏱️ Eye Break Timer** — Pengingat berkala untuk istirahatkan mata dari layar.
- **📊 Screen Time Tracker** — Pelacakan durasi penggunaan layar harian & mingguan, diambil langsung dari Usage Stats API Android via native `MethodChannel`.
- **📱 App Usage Tracker** — Rincian durasi pemakaian per aplikasi yang terpasang di perangkat.
- **⚠️ Peringatan Otomatis** — Notifikasi/dialog saat screen time harian melebihi batas wajar (>3 jam).
- **🤖 Chatbot Edukasi** — Asisten percakapan berbasis decision-tree (rule-based) seputar kesehatan mata.
- **🏥 Pencari Klinik Mata** — Menampilkan klinik mata terdekat berdasarkan lokasi pengguna (geolocation) dan membuka rute langsung ke Google Maps.
- **🔔 Push Notification** — Terintegrasi dengan Firebase Cloud Messaging.
- **🎨 UI Responsif** — Layout adaptif di berbagai ukuran layar menggunakan `flutter_screenutil` & `sizer`, dengan font Poppins.

## 🛠️ Tech Stack

| Kategori | Teknologi |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Provider |
| Backend Service | Firebase Core, Firebase Cloud Messaging |
| Lokasi | Geolocator, Geocoding |
| Penyimpanan Lokal | SharedPreferences |
| Native Integration | Kotlin (`MethodChannel` untuk Android Usage Stats API) |
| UI/Responsiveness | flutter_screenutil, sizer |
| Lainnya | url_launcher |

## 📂 Struktur Proyek

```
lib/
├── app_usage/       # Model, provider, service, & UI pelacak pemakaian aplikasi
├── auth/            # State management autentikasi (login/signup)
├── chatbot/         # Logic chatbot berbasis decision-tree
├── clinic/          # Data & model klinik mata
├── screen_time/     # Model, provider, service & warning dialog screen time
├── screens/         # Seluruh halaman UI (home, login, tes mata, timer, tips, dll)
├── theme/           # Warna & tipografi terpusat
├── widgets/         # Widget yang dipakai ulang (mis. bottom navigation)
└── main.dart        # Entry point aplikasi
```

## 🚀 Cara Menjalankan

### Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (channel stable, kompatibel dengan Dart `^3.10.0`)
- Android Studio / Xcode untuk emulator atau perangkat fisik
- Project Firebase aktif (untuk fitur notifikasi)

### Instalasi

```bash
# 1. Clone repository
git clone https://github.com/pritaaa/eyecare.git
cd eyecare/eye_care_app

# 2. Install dependencies
flutter pub get

# 3. Jalankan aplikasi
flutter run
```

### ⚙️ Setup Firebase

Aplikasi ini membutuhkan konfigurasi Firebase agar bisa berjalan penuh:

1. Buat project di [Firebase Console](https://console.firebase.google.com/).
2. Unduh `google-services.json` dan letakkan di `android/app/`.
3. (Opsional, untuk iOS) Unduh `GoogleService-Info.plist` dan letakkan di `ios/Runner/`.

### 🔑 Izin Perangkat (Android)

Beberapa fitur membutuhkan izin khusus yang perlu diaktifkan pengguna secara manual di Settings:

| Izin | Digunakan Untuk |
|---|---|
| Location (Fine/Coarse/Background) | Mencari klinik mata terdekat |
| Usage Access (`PACKAGE_USAGE_STATS`) | Melacak screen time & app usage |
| Notifications | Push notification & peringatan screen time |
| Boot Completed | Melanjutkan pemantauan setelah perangkat restart |

## 🗺️ Roadmap

- [ ] Sinkronisasi akun & data ke cloud (saat ini autentikasi masih lokal)
- [ ] Riwayat hasil tes mata dalam bentuk grafik
- [ ] Rekomendasi klinik berbasis rating/ulasan

## 🤝 Kontribusi

Pull request dan issue sangat terbuka. Untuk perubahan besar, mohon buka issue terlebih dahulu untuk didiskusikan.

## 👥 Author

- **Prita Ayu** — [@pritaaa](https://github.com/pritaaa)
- **Rafi Achmad** — [@rafiach](https://github.com/rafiach)
