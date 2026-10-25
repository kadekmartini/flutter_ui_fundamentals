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