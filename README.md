# Cash-in 💰

> Aplikasi Android manajemen keuangan pribadi berbasis Flutter + Supabase

[![Download APK](https://img.shields.io/badge/Download-APK-00C853?style=for-the-badge&logo=android)](https://github.com/YOUR_USERNAME/cash-in/releases/latest)

---

## 📁 Struktur Repository

```
cash-in/
├── app/                    # Flutter Android app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/         # Data models
│   │   ├── screens/        # UI screens
│   │   ├── services/       # API & business logic
│   │   └── utils/          # Theme & formatters
│   ├── pubspec.yaml
│   └── .env               # ← BUAT SENDIRI, jangan commit!
│
├── web/                   # Landing page (Netlify)
│   ├── index.html
│   ├── version.json       # Versi terbaru APK
│   └── netlify.toml
│
├── supabase/
│   └── schema.sql         # Script SQL untuk setup database
│
└── .github/
    └── workflows/
        └── build-apk.yml  # Auto build & release APK
```

---

## 🚀 Setup

### 1. Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/cash-in.git
cd cash-in
```

### 2. Setup Supabase

1. Buat project baru di [supabase.com](https://supabase.com)
2. Buka **SQL Editor** dan jalankan `supabase/schema.sql`
3. Salin **Project URL** dan **anon key** dari Settings → API

### 3. Konfigurasi `.env`

```bash
# Di dalam folder app/
cp .env .env.bak  # backup template
nano app/.env
```

Isi dengan kredensial Supabase Anda:

```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
VERSION_CHECK_URL=https://your-app.netlify.app/version.json
```

> ⚠️ **Jangan commit file `.env` ke GitHub!** File ini sudah ada di `.gitignore`.

### 4. Install & Run

```bash
cd app
flutter pub get
flutter run
```

### 5. Build APK

```bash
cd app
flutter build apk --release
# APK ada di: app/build/app/outputs/flutter-apk/app-release.apk
```

---

## 🌐 Deploy Landing Page (Netlify)

1. Push repository ke GitHub
2. Buka [netlify.com](https://netlify.com) → **Add new site** → **Import from Git**
3. Set **Base directory** ke `web`
4. Set **Publish directory** ke `web`
5. Deploy!

Setelah deploy, update `VERSION_CHECK_URL` di `.env` dengan URL Netlify Anda.

---

## 🔄 Release Update APK

1. Tambahkan secrets di **GitHub → Settings → Secrets and variables → Actions**:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `VERSION_CHECK_URL`

2. Push tag baru untuk trigger build otomatis:

```bash
git tag v1.0.1
git push origin v1.0.1
```

GitHub Actions akan otomatis:
- Build APK release
- Upload ke GitHub Releases
- Update `web/version.json`

---

## 🛠️ Tech Stack

| Teknologi | Kegunaan |
|---|---|
| **Flutter** | Framework Android app |
| **Supabase** | PostgreSQL database & auth |
| **fl_chart** | Grafik line chart |
| **Netlify** | Hosting landing page |
| **GitHub Actions** | CI/CD auto build |

---

## 👤 Default Login

| User ID | Password |
|---|---|
| `admin` | `admin` |

---

## 📄 License

MIT License. Bebas digunakan dan dimodifikasi.
