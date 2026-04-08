# Aplikasi Keuangan Flutter + Landing Page Netlify

## Gambaran Umum

Proyek ini terdiri dari dua bagian dalam satu GitHub repository:
1. **Flutter APK** — Aplikasi keuangan Android dengan backend Supabase
2. **Landing Page Statis** — Halaman web untuk deskripsi app & distribusi APK, di-deploy ke Netlify

---

## Struktur Repository (Monorepo)

```
/
├── app/                    # Flutter project
│   ├── lib/
│   ├── android/
│   ├── pubspec.yaml
│   └── .env               # Supabase URL & Key (gitignored)
│
├── web/                   # Static landing page (Netlify)
│   ├── index.html
│   ├── version.json       # { "version": "1.0.0", "url": "..." }
│   └── assets/
│       └── app-release.apk  # APK hasil build
│
├── .github/
│   └── workflows/
│       └── build-apk.yml  # GitHub Actions: build APK otomatis
│
└── README.md
```

---

## User Review Required

> [!IMPORTANT]
> **Supabase ENV di APK** — Ya, menyimpan `SUPABASE_URL` dan `SUPABASE_ANON_KEY` di `.env` APK adalah **masuk akal dan umum digunakan**. Namun perlu dicatat:
> - `anon key` memang dirancang untuk digunakan di client-side
> - Keamanan sesungguhnya diatur melalui **Row Level Security (RLS)** di Supabase
> - Jangan pernah simpan `service_role` key di APK

> [!IMPORTANT]
> **Version Check** — APK akan melakukan HTTP GET ke `https://[domain-netlify]/version.json` saat startup. File ini berisi versi terbaru dan URL download APK. Jika versi berbeda → tampilkan dialog update → redirect ke URL download APK baru.

> [!WARNING]
> **APK di GitHub/Netlify** — File APK bisa besar (>50MB). GitHub memiliki batas file 100MB, dan Git LFS mungkin diperlukan. Apakah Anda setuju menggunakan GitHub Releases sebagai hosting APK, dengan URL di `version.json` mengarah ke GitHub Releases? Ini lebih bersih dan gratis.

---

## Proposed Changes

### 1. Struktur Database Supabase

#### Tabel yang Dibutuhkan

```sql
-- Tabel User
CREATE TABLE table_user_id (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,      -- simpan sebagai hash (bcrypt)
  email TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Insert default admin
INSERT INTO table_user_id (user_id, password, email) 
VALUES ('admin', 'admin', 'admin@admin.com');

-- Tabel Data Keuangan
CREATE TABLE table_keuangan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT REFERENCES table_user_id(user_id),
  tipe TEXT NOT NULL,          -- 'pemasukan' | 'pengeluaran'
  keterangan TEXT NOT NULL,
  nominal BIGINT NOT NULL,
  tanggal DATE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

### 2. Flutter App (`/app`)

#### Halaman & Fitur

| Halaman | Fitur |
|---|---|
| **Splash Screen** | Cek koneksi internet + cek versi app |
| **Login** | Autentikasi via `table_user_id` |
| **Register** | Form pendaftaran user baru |
| **Dashboard** | Grafik & rekap data keuangan dengan filter tanggal |
| **Input Data** | Form input data keuangan |

#### Alur Aplikasi

```
Buka App
  └─ Cek Internet? 
      ├─ Tidak → Notifikasi "Perlu koneksi internet"
      └─ Ya → Cek versi ke version.json
            ├─ Ada update → Dialog update → Download APK
            └─ Up to date → Halaman Login
                    ├─ Login → Dashboard
                    │     ├─ [Tab] Dashboard (grafik)
                    │     └─ [Tab] Input Data Keuangan
                    └─ Daftar → Form Registrasi → Login
```

#### Dependencies Flutter

```yaml
dependencies:
  supabase_flutter: ^2.x       # Database client
  fl_chart: ^0.x              # Grafik line chart
  intl: ^0.x                  # Format Rupiah & tanggal
  connectivity_plus: ^5.x     # Cek koneksi internet
  http: ^1.x                  # HTTP request untuk cek versi
  flutter_dotenv: ^5.x        # ENV management
  url_launcher: ^6.x          # Buka link download APK
  shared_preferences: ^2.x    # Simpan session login
```

#### Desain

- **Tema**: Hijau retro-futuristik
- **Palet warna**:
  - Primary: `#00FF41` (Matrix green) atau `#2ECC71` (emerald)
  - Background: `#0D1117` (dark)
  - Surface: `#161B22`
  - Accent: `#39FF14` (neon green)
- **Font**: Monospaced + modern (Courier, Roboto Mono)
- **Grafik**: Line chart — hijau untuk pemasukan, merah untuk pengeluaran

---

### 3. Landing Page Netlify (`/web`)

#### Konten Halaman

- Header dengan nama app & logo
- Deskripsi singkat fitur
- Tombol **Download APK** (link ke GitHub Releases / Netlify assets)
- Panduan penggunaan singkat
- `version.json` yang bisa diakses publik

#### `version.json` (diupdate manual atau via CI/CD)

```json
{
  "version": "1.0.0",
  "release_date": "2026-04-05",
  "download_url": "https://[domain]/assets/app-release.apk",
  "changelog": "Rilis pertama"
}
```

---

### 4. GitHub Actions (CI/CD Opsional)

```yaml
# .github/workflows/build-apk.yml
# Trigger: push tag v*.*.*
# Steps:
# 1. Setup Flutter
# 2. Build APK release
# 3. Upload ke GitHub Releases
# 4. Update version.json di branch web/
```

> [!NOTE]
> GitHub Actions untuk auto-build APK bersifat **opsional**. Bisa juga build manual lalu upload APK ke Netlify/GitHub Releases.

---

## Open Questions

> [!IMPORTANT]
> **1. Hosting APK** — Pilih salah satu:
> - **Option A**: APK disimpan di folder `/web/assets/` → di-serve langsung via Netlify (lebih simpel, tapi Netlify punya batas 100MB per file)
> - **Option B**: APK di-upload ke **GitHub Releases** → `version.json` berisi URL ke GitHub Releases (lebih scalable, direkomendasikan)

> [!IMPORTANT]
> **2. Password Security** — Apakah password user di `table_user_id` perlu di-hash (bcrypt/argon2), atau untuk MVP bisa plaintext dulu? Plaintext lebih cepat dikerjakan tapi tidak aman.

> [!IMPORTANT]
> **3. Session Login** — Apakah setelah login, user perlu tetap login ketika buka app lagi (remember me / persistent session)? Atau harus login ulang setiap buka app?

> [!NOTE]
> **4. Nama Aplikasi** — Apa nama aplikasi keuangan ini? Ini akan dipakai di landing page, app title, dan package name Flutter.

---

## Verification Plan

### Manual Verification
1. Build Flutter APK di local → install di Android emulator/device
2. Test flow: splash → cek internet → cek versi → login → dashboard → input data
3. Deploy landing page ke Netlify → verifikasi `version.json` accessible
4. Test update check: ubah versi di `version.json` → buka app → pastikan muncul dialog update

### Database
- Verifikasi insert user berhasil ke `table_user_id`
- Verifikasi CRUD data keuangan ke `table_keuangan`
- Verifikasi filter tanggal & aggregasi di dashboard berjalan benar
