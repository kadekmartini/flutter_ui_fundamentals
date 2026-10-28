# flutter_ui_fundamentals

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


# Course Explorer v2 - Architecture Audit
**Oleh: Kadek Martini Aristianti (2415051004)**

Berikut adalah tanggung jawab singkat dari masing-masing folder pada arsitektur aplikasi ini:

* **`models/`**: Berisi *blueprint* struktur data (contoh: `course.dart`). Layer ini murni representasi data.
* **`services/`**: Bertanggung jawab mengambil data dari sumber eksternal (membaca JSON dari `rootBundle` atau API). Sama sekali tidak mengandung elemen UI.
* **`repositories/`**: Menjadi jembatan perantara. Bertugas mengolah atau memetakan data mentah dari Service menjadi objek Model.
* **`providers/`**: Mengelola *state management*. Memanggil Repository, menyimpan data ke dalam memori (state), dan menggunakan `notifyListeners()` untuk memberi tahu UI. Provider ini murni logika dan tidak menyimpan `BuildContext`.
* **`screens/`**: Berisi halaman-halaman utama aplikasi. Hanya bertugas menampilkan UI dengan mendengarkan data dari Provider, dan tidak boleh membaca data dari sumber secara langsung (`rootBundle`).
* **`widgets/`**: Berisi potongan komponen UI kecil yang bisa dipakai berulang kali.

## Dokumentasi Endpoint REST API (Tahap 1)
* URL Endpoint: https://course-api-pearl.vercel.app/courses
* HTTP Method: GET
* Status Code: 200 OK
* Struktur JSON: id, code, title, credits, status

# Course Data Manager

Aplikasi Flutter untuk mengelola data mata kuliah (*course*) melalui database Supabase. Proyek ini merupakan pengembangan Course Explorer v2 pada praktikum Pemrograman Mobile.

## Identitas Mahasiswa

- **Nama:** Kadek Martini Aristianti
- **NIM:** 2415051004
- **Repository:** https://github.com/kadekmartini/flutter_ui_fundamentals

## Deskripsi Aplikasi

Course Data Manager digunakan untuk menampilkan dan mengelola data mata kuliah. Aplikasi menggunakan Supabase sebagai backend dan PostgreSQL sebagai database penyimpanan data course.

Data dibaca dari database melalui `CourseSupabaseService`, kemudian diteruskan melalui repository dan provider sebelum ditampilkan pada antarmuka Flutter.

## Fitur Aplikasi

- Membaca daftar mata kuliah dari Supabase.
- Menambahkan mata kuliah melalui form.
- Mengubah judul, jumlah SKS, dan status course.
- Menghapus course setelah konfirmasi pengguna.
- Menampilkan identitas mahasiswa.
- Menampilkan status loading, empty state, dan error beserta fitur retry.
- Memberikan feedback melalui SnackBar.
- Menyediakan halaman detail dan Favorites.
- Mempertahankan kode course sebagai kunci Favorites.
- Mendukung navigasi responsif menggunakan `NavigationBar` dan `NavigationRail`.

Fitur-fitur tersebut perlu diuji pada lingkungan aplikasi sebelum dinyatakan berfungsi sepenuhnya.

## Teknologi yang Digunakan

- Flutter dan Dart.
- Provider untuk state management.
- Supabase Flutter untuk mengakses backend Supabase.
- PostgreSQL sebagai database.
- Git dan GitHub untuk version control.
- REST API service sebagai alternatif sumber data yang tetap tersedia pada proyek.

## Arsitektur Aplikasi

Struktur aplikasi memisahkan tanggung jawab setiap bagian.

| Bagian | Tanggung Jawab |
|---|---|
| `main.dart` | Menginisialisasi Supabase, memilih sumber data aktif, dan menjalankan aplikasi. |
| `models/course.dart` | Merepresentasikan data course serta konversi JSON. |
| `services/course_data_source.dart` | Mendefinisikan kontrak sumber data. |
| `services/course_api_service.dart` | Menangani akses REST API. |
| `services/course_supabase_service.dart` | Menangani operasi database Supabase. |
| `repositories/course_repository.dart` | Menjadi perantara antara service dan provider. |
| `providers/course_provider.dart` | Mengelola data course, loading, error, dan operasi CRUD. |
| `providers/course_state.dart` | Menyimpan state Favorites dengan kode course sebagai kunci. |
| `screens/` | Menyediakan halaman daftar, detail, form, Favorites, dan navigasi responsif. |
| `widgets/` | Menyediakan komponen UI yang digunakan kembali, termasuk kartu course dan tampilan error. |

Alur data utama:

`Supabase → CourseSupabaseService → CourseRepository → CourseProvider → Screen`

Sumber data aktif dipilih di `main.dart`, sehingga service dapat diganti melalui kontrak `CourseDataSource` tanpa memindahkan query database ke dalam screen atau provider.

## Database Supabase

Tabel utama yang digunakan adalah `public.courses`.

| Kolom | Tipe Data | Keterangan |
|---|---|---|
| `id` | bigint / identity | Primary key |
| `code` | text | Kode course |
| `title` | text | Judul course |
| `credits` | integer | Jumlah SKS |
| `status` | text | Status course |
| `created_at` | timestamptz | Waktu pembuatan |

Nilai status yang digunakan adalah `planned`, `active`, dan `done`. Kolom kode course sebaiknya unik, sedangkan batasan database digunakan untuk menjaga validitas data.

## Cara Menjalankan Aplikasi

### Persyaratan

- Flutter SDK.
- Dart SDK yang kompatibel dengan versi Flutter.
- Browser Chrome atau perangkat yang didukung Flutter.
- Project Supabase yang telah disiapkan untuk praktikum.

### Menyiapkan Dependensi

Buka terminal pada folder proyek, kemudian jalankan:

```bash
flutter pub get
```

### Konfigurasi Supabase

Pastikan file `lib/config/supabase_config.dart` berisi Project URL dan client publishable key dari project Supabase yang digunakan.

Jangan memasukkan password, secret key, atau `service_role` key ke dalam aplikasi Flutter maupun repository.

### Menjalankan Aplikasi

Untuk menjalankan pada Chrome:

```bash
flutter run -d chrome
```

Untuk memeriksa kode:

```bash
flutter analyze
```

## Pengujian

Pengujian praktikum mencakup:

1. READ: mengambil dan menampilkan data dari Supabase.
2. CREATE: menambahkan data course.
3. UPDATE: mengubah data course berdasarkan ID.
4. DELETE: menghapus course setelah konfirmasi.
5. Loading, empty state, error, dan retry.
6. Penanganan kegagalan koneksi dan validasi data.
7. Pengujian RLS dan pemeriksaan keamanan repository.
8. Verifikasi bahwa Favorites tetap menggunakan kode course sebagai kunci.

Hasil dan bukti pengujian dicatat berdasarkan hasil yang benar-benar diperoleh saat aplikasi dijalankan.

## Keamanan

- Jangan memasukkan service-role key atau secret key ke source code maupun GitHub.
- Jangan melakukan commit terhadap file `.env` yang berisi secret.
- Gunakan RLS dan policy untuk membatasi akses pada backend.
- Validasi form tidak menggantikan validasi database dan authorization.
- Jangan menampilkan credential atau data sensitif pada screenshot praktikum.
- Policy permisif yang digunakan untuk laboratorium tidak boleh dianggap sebagai konfigurasi produksi.

## Repository GitHub

Source code dan riwayat perubahan tersedia di:

https://github.com/kadekmartini/flutter_ui_fundamentals

Repository menggunakan Git untuk mencatat perubahan setiap tahap praktikum.

## Lisensi

Proyek ini dibuat untuk keperluan pembelajaran dan praktikum Pemrograman Mobile.