# 📱 Sislantol Apps

Aplikasi mobile **Flutter** untuk sistem pengelolaan lalu lintas online (Sislantol).

---

## ⚙️ Versi yang Harus Diinstall (Wajib Sama!)

| Software | Versi | Link Download |
|---|---|---|
| **Flutter SDK** | `3.23.0-0.1.pre` (channel beta) | Lihat instruksi di bawah |
| **Dart SDK** | `3.5.0` (build 3.5.0-180.3.beta) | *(sudah termasuk dalam Flutter)* |
| **Java JDK** | `17.0.11` (OpenJDK Temurin) | https://adoptium.net/temurin/releases/?version=17 |
| **Android Studio** | Versi terbaru | https://developer.android.com/studio |
| **Git** | `2.52.0` atau lebih baru | https://git-scm.com/downloads |

> ⚠️ **PENTING**: Gunakan **Flutter channel beta** dan **Java 17** agar tidak ada error kompatibilitas.

---

## 🚀 Cara Setup Project (Pertama Kali)

### 1. Install Flutter (Channel Beta)

Setelah download dan extract Flutter SDK, ganti ke channel beta:
```bash
flutter channel beta
flutter upgrade
```

Verifikasi versi:
```bash
flutter --version
# Harus tampil: Flutter 3.23.0-0.1.pre
```

### 2. Install Java 17 (OpenJDK Temurin)
Download dari: https://adoptium.net/temurin/releases/?version=17
- Pilih: **Windows**, **x64**, **JDK**, **17**

### 3. Install Android Studio
Download dari: https://developer.android.com/studio
- Setelah install, buka Android Studio → SDK Manager
- Pastikan **Android SDK** terinstall

### 4. Clone Repository
```bash
git clone https://github.com/zaimulatqiya/sislantol_apps.git
cd sislantol_apps
```

### 5. Buat File `.env`
Buat file `.env` di root folder project:
```env
SUPABASE_URL=isi_dari_pemilik_project
SUPABASE_ANON_KEY=isi_dari_pemilik_project
```
> 📩 Minta file `.env` langsung ke pemilik project secara private.

### 6. Install Dependencies Flutter
```bash
flutter pub get
```

### 7. Jalankan App
Hubungkan HP Android atau buka emulator, lalu:
```bash
flutter run
```

---

## ✅ Cek Flutter Doctor

Setelah semua terinstall, jalankan:
```bash
flutter doctor
```
Pastikan semua tanda ✅ (tidak ada error merah). Jika ada yang ❌, ikuti instruksi yang muncul.

---

## 📦 Versi Dependency Utama

| Package | Versi |
|---|---|
| flutter_bloc | `^9.1.1` |
| supabase_flutter | `^2.14.2` |
| dio | `^5.9.2` |
| image_picker | `^1.1.2` |
| flutter_dotenv | `^6.0.1` |
| shared_preferences | `^2.3.3` |

---

## 🛠️ Cek Versi di Komputer

```bash
flutter --version
# Flutter 3.23.0-0.1.pre • channel beta

java -version
# openjdk version "17.0.11"
```
