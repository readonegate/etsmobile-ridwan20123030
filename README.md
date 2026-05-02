# etsmobile

# Ridwan - 20123030 - ETS - pemograman mobile lanjut


## Flutter Login MVVM dengan API & Local Storage

Dokumen ini menjelaskan langkah-langkah pembuatan fitur Login dengan mengimplementasikan pola arsitektur **MVVM (Model-View-ViewModel)** di Flutter, serta integrasi dengan API eksternal dan penyimpanan sesi menggunakan local storage.

---

## 1. Persiapan dan Dependencies
Langkah pertama dalam pembuatan project ini adalah menambahkan library yang dibutuhkan ke dalam `pubspec.yaml`. Kita menggunakan perintah berikut di terminal:

```bash
flutter pub add http provider shared_preferences
```
- **`http`**: Digunakan untuk melakukan *request* API jaringan (POST login).
- **`provider`**: Digunakan sebagai *State Management* penghubung antara *View* dan *ViewModel*.
- **`shared_preferences`**: Digunakan untuk menyimpan *token* secara persisten di penyimpanan perangkat agar status login tidak hilang saat aplikasi ditutup.

---

## 2. Struktur Arsitektur MVVM
Pola MVVM memisahkan kode menjadi 3 bagian utama untuk memastikan kemudahan pemeliharaan (*maintainability*):

- **Model**: Mendefinisikan struktur data.
- **View**: Hanya berisi kode antarmuka (UI). Tidak boleh ada logika bisnis HTTP di sini.
- **ViewModel**: Bertindak sebagai "otak". Menghubungkan View dengan layanan API dan mengatur *state* (misal: *isLoading*).

Struktur folder dibuat seperti ini:
```text
lib/
 ┣ models/
 ┃ ┗ user_model.dart
 ┣ services/
 ┃ ┗ api_service.dart
 ┣ viewmodels/
 ┃ ┗ login_viewmodel.dart
 ┣ views/
 ┃ ┣ home_view.dart
 ┃ ┣ login_view.dart
 ┃ ┗ splash_view.dart
 ┗ main.dart
```

---

## 3. Implementasi Kode

### A. Model (`lib/models/user_model.dart`)
Membuat kelas `UserModel` yang berguna untuk *mapping* respons JSON dari API (berisi `token` saat sukses, atau `error` saat gagal).

### B. Service (`lib/services/api_service.dart`)
Kelas `ApiService` memegang fungsi `login(email, password)`. Menggunakan package `http`, aplikasi mengirimkan request POST ke `https://reqres.in/api/login`. Mengembalikan objek `UserModel` terlepas dari apakah hasilnya sukses (status 200) atau gagal.

### C. ViewModel (`lib/viewmodels/login_viewmodel.dart`)
`LoginViewModel` *extends* `ChangeNotifier`.
Di sinilah logika inti berada:
1. Mengubah *state* `isLoading` menjadi `true` dan memanggil `notifyListeners()` agar tombol View berubah menjadi indikator *loading*.
2. Memanggil `ApiService.login()`.
3. Jika berhasil:
   - Menyimpan `token` ke `SharedPreferences` (local storage).
   - Menghilangkan *loading* dan mengembalikan nilai `true`.
4. Dilengkapi juga dengan metode `logout()` untuk menghapus token, serta `checkLoginStatus()` untuk melihat apakah *user* masih *login* saat aplikasi pertama kali dibuka.

### D. View

- **`LoginView` (`lib/views/login_view.dart`)**:
  Halaman UI dengan 2 TextFormField (Email & Password). Saat tombol Login ditekan, ia memanggil `viewModel.login()`. Jika kembaliannya `true`, maka berpindah ke `HomeView` dengan memunculkan `SnackBar` sukses.
- **`HomeView` (`lib/views/home_view.dart`)**:
  Halaman setelah berhasil login. Menampilkan `token` user. Memiliki tombol **Logout** yang memanggil `viewModel.logout()` dan kembali ke `LoginView`.
- **`SplashView` (`lib/views/splash_view.dart`)**:
  Layar kosong saat aplikasi pertama kali dibuka (memunculkan *CircularProgressIndicator* sesaat). Mengeksekusi `viewModel.checkLoginStatus()`. Jika token ada di *local storage*, langsung arahkan ke `HomeView`, jika tidak, arahkan ke `LoginView`.

---

## 4. Konfigurasi Root (`main.dart`)
File utama perlu dibungkus dengan `MultiProvider` agar `LoginViewModel` dapat diakses dari seluruh hirarki halaman. *Initial route* (halaman utama) diatur ke `SplashView()`.

```dart
// Potongan kode di main.dart
Widget build(BuildContext context) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LoginViewModel()),
    ],
    child: MaterialApp(
      home: const SplashView(),
    ),
  );
}
```


