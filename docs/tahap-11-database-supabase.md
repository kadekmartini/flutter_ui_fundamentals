# Tahap 11. Membuat Tabel Database `courses`

## 1. Struktur Tabel Database

Tabel `public.courses` dibuat pada Supabase dengan struktur berikut.

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| `id` | `bigint` / identity | Primary key |
| `code` | `text` | Kode course |
| `title` | `text` | Judul course |
| `credits` | `integer` | Jumlah SKS/credit |
| `status` | `text` | Status course: `planned`, `active`, atau `done` |
| `created_at` | `timestamptz` | Waktu pembuatan data |

## 2. Data Awal

Tabel diisi dengan tiga data awal berikut melalui SQL Editor Supabase.

| Kode | Judul Course | Credits | Status |
|---|---|---:|---|
| `SUP101` | Pengenalan Supabase | 3 | `planned` |
| `DB101` | Basis Data PostgreSQL | 3 | `active` |
| `API101` | Integrasi REST API | 2 | `done` |

## 3. Kesesuaian dengan Model Dart

Nama kolom database yang digunakan adalah `id`, `code`, `title`, `credits`, `status`, dan `created_at`. Nama key tersebut perlu dicocokkan dengan implementasi `Course.fromJson()` dan `Course.toJson()` pada model Dart di proyek Flutter.

## 4. CHECK Constraint

Kolom `status` dibatasi agar hanya menerima nilai `planned`, `active`, atau `done`. Kolom `credits` juga diberi batasan agar nilainya lebih besar dari nol.

## 5. Konfigurasi RLS dan Policy

Row Level Security (RLS) diaktifkan pada tabel `public.courses`. Policy praktikum disiapkan untuk operasi membaca, menambahkan, mengubah, dan menghapus data melalui role `anon`.

Policy yang permisif ini hanya untuk kebutuhan laboratorium/praktikum. Konfigurasi tersebut bukan pola keamanan untuk aplikasi produksi; aplikasi nyata harus membatasi akses berdasarkan autentikasi dan kebutuhan pengguna.

## 6. Bukti Praktikum Tahap 11

Screenshot yang disiapkan untuk dilampirkan pada lembar praktikum:

1. Table Editor Supabase yang memperlihatkan tabel `courses` dan tiga data awal.
2. Struktur kolom atau SQL pembuatan tabel yang memperlihatkan constraint.
3. SQL Editor atau pengaturan policy yang memperlihatkan RLS dan policy.
4. File model Dart `Course` yang memperlihatkan key `fromJson()` dan `toJson()`.

## 7. Catatan/Temuan

Tabel `public.courses` dibuat pada Supabase dan diisi dengan tiga data awal. Nama kolom disiapkan agar sesuai dengan key JSON pada model Dart `Course`. CHECK constraint digunakan untuk membatasi nilai `status` dan memastikan `credits` lebih besar dari nol. RLS dan policy dikonfigurasikan untuk keperluan praktikum. Policy permisif hanya digunakan untuk laboratorium dan tidak disarankan untuk aplikasi produksi.

Sebelum laporan dikumpulkan, pastikan implementasi `Course.fromJson()` dan `Course.toJson()` memang menggunakan key yang sama dengan kolom database.

## 8. Git Checkpoint Tahap 11

Perintah yang digunakan untuk mencatat dan mengirim dokumentasi ke repository GitHub:

```bash
git status
git add .
git commit -m "Dokumentasikan schema database Supabase"
git push
git rev-parse --short HEAD
```

**Hash commit tahap ini:** Diisi menggunakan hasil perintah `git rev-parse --short HEAD` setelah commit berhasil.

**URL repository GitHub:** https://github.com/kadekmartini/flutter_ui_fundamentals
