# Product Requirements Document (PRD)

## 1. Ringkasan Produk

Petanitech Mobile App adalah aplikasi mobile untuk mendukung petani dan pengguna agribisnis dalam mengelola lahan, memantau kondisi pertanian, mendapatkan informasi cuaca, mengakses berita dan komunitas, serta melakukan prediksi penyakit tanaman. Aplikasi ini dirancang sebagai platform digital yang menghubungkan kebutuhan operasional harian petani dengan data pertanian yang lebih terukur dan terstruktur.

Aplikasi ini sudah memiliki struktur modular yang mencerminkan aspek fungsional utama, seperti autentikasi, beranda, lahan, monitoring, artikel, komunitas, dan prediksi penyakit tanaman. Rute dan modul yang ada dapat dilihat pada [lib/core/app_module.dart](lib/core/app_module.dart) dan modul-modul di [lib/modules](lib/modules).

## 2. Latar Belakang dan Masalah

Petani sering menghadapi tantangan seperti:

- keterbatasan akses informasi cuaca dan rekomendasi pertanian;
- sulitnya memantau lahan secara teratur;
- belum adanya sistem yang memadukan data pertanian, edukasi, dan komunitas dalam satu platform;
- kurangnya dukungan untuk diagnosis awal penyakit tanaman;
- kebutuhan untuk mengakses informasi pertanian yang relevan, cepat, dan mudah dipahami di perangkat mobile.

Dengan platform mobile yang terintegrasi, diharapkan petani dapat mengambil keputusan yang lebih cepat, lebih tepat, dan lebih terinformasi dalam kegiatan pertanian mereka.

## 3. Tujuan Produk

### Tujuan utama

- Mempermudah akses informasi pertanian yang relevan untuk petani.
- Membantu pengelolaan lahan dan monitoring aktivitas pertanian.
- Memberikan gambaran kondisi cuaca dan prediksi untuk mendukung keputusan operasional.
- Menyediakan fitur edukasi dan komunitas berbasis pertanian.
- Membantu identifikasi dini penyakit tanaman melalui fitur prediksi.
- Menyediakan pengalaman autentikasi yang aman dan mudah digunakan.

### Tujuan bisnis

- Meningkatkan keterlibatan pengguna terhadap layanan pertanian digital.
- Mendorong penggunaan teknologi dalam aktivitas pertanian modern.
- Menjadi kanal utama informasi, edukasi, dan layanan petani.
- Menyiapkan fondasi produk yang dapat berkembang ke layanan berbasis data dan AI.

## 4. User dan Persona

### 4.1 Target pengguna utama

- Petani individu
- Kelompok tani
- Pengguna agribisnis/UMKM pertanian
- Pengguna baru yang ingin belajar dan memantau kegiatan pertanian

### 4.2 Persona utama

#### Petani pemula

- Ingin mendapatkan informasi sederhana dan mudah dipahami.
- Membutuhkan panduan penggunaan aplikasi yang jelas.
- Fokus pada cuaca, lahan, dan tips pertanian.

#### Petani berpengalaman

- Membutuhkan monitoring yang cepat dan data yang jelas.
- Menginginkan akses ke analisis, pratinjau aktivitas lahan, dan informasi terkini.
- Sering memanfaatkan fitur komunitas dan edukasi.

#### Pengelola lahan/agribisnis

- Memerlukan data lahan, penggunaan input, dan estimasi hasil.
- Membutuhkan sistem yang mendukung pengelolaan operasi lebih terstruktur.

## 5. Scope Produk

### Fitur yang sudah ada pada sistem

1. Autentikasi pengguna
   - Login
   - Register
   - Lupa password
   - Proteksi akses halaman utama dengan auth guard

2. Beranda aplikasi
   - Slider informasi
   - Komoditas unggulan
   - Postingan/bacaan pertanian
   - Komunitas pengguna

3. Lahan dan budidaya
   - Halaman lahan
   - Detail lahan
   - Pembuatan lahan baru
   - Estimasi hasil panen dan kebutuhan pupuk

4. Monitoring dan prediksi cuaca
   - Tampilan monitoring pertanian
   - Prediksi cuaca berbasis data eksternal
   - Saran aktivitas berdasarkan curah hujan

5. Konten dan komunitas
   - Daftar artikel atau informasi pertanian
   - Detail konten
   - Komunitas/aktivitas pengguna

6. Prediksi penyakit tanaman
   - Chat/diagnosis prediksi penyakit tanaman
   - Riwayat prediksi

7. Profil pengguna
   - Informasi akun
   - Navigasi pengguna di aplikasi

### Scope masa depan yang potensial

- notifikasi cuaca dan peringatan penyakit;
- dashboard analitik lahan per musim;
- chatbot berbasis AI untuk konsultasi pertanian;
- integrasi marketplace produk pertanian;
- laporan dan ekspor data aktivitas pertanian.

## 6. User Needs dan Pain Points

### User needs

- Akses cepat ke informasi penting untuk keputusan harian.
- Visualisasi lahan dan cuaca yang jelas.
- Sumber edukasi yang relevan dengan pertanian.
- Kemampuan untuk mendiagnosis awal masalah tanaman.
- Alat yang memudahkan pengelolaan kegiatan di lahan.

### Pain points

- Informasi pertanian masih tersebar di banyak sumber.
- Data cuaca dan kondisi lahan belum terintegrasi dalam satu sistem.
- Kurangnya alat untuk mengelola aktivitas di lahan secara terstruktur.
- Diagnosa penyakit sering dilakukan terlambat.

## 7. Product Goals dan Success Metrics

### Goals

- Membuat aplikasi yang mudah digunakan untuk kebutuhan petani di mobile.
- Meningkatkan pengetahuan pengguna tentang pertanian modern.
- Menyediakan fitur operasional yang relevan untuk petani.
- Mempercepat pemahaman kondisi lahan dan lingkungan.

### Success metrics

- Tingkat onboarding pengguna berhasil > 80%.
- Retensi pengguna mingguan meningkat dalam 3 bulan pertama.
- Pengguna aktif menggunakan fitur utama seperti Home, Farming, Monitoring, dan Post.
- Tingkat penyelesaian tugas utama (login, melihat lahan, melihat cuaca, membaca konten) > 70%.
- Fitur diagnosis penyakit digunakan secara aktif oleh pengguna.

## 8. Requirements

### 8.1 Functional requirements

#### FR-01: Autentikasi

Pengguna harus dapat login, register, dan reset password untuk mengakses fitur terproteksi.

Acceptance criteria:

- pengguna dapat masuk dengan kredensial valid;
- sistem menolak login dengan data tidak valid;
- pengguna dapat berpindah ke halaman pendaftaran atau lupa password.

#### FR-02: Dashboard utama

Pengguna dapat melihat halaman utama yang berisi slider, komoditas, postingan, dan komunitas.

Acceptance criteria:

- halaman utama tampil setelah login;
- konten dapat di-refresh;
- semua komponen utama muncul secara berurutan.

#### FR-03: Manajemen lahan

Pengguna dapat melihat daftar lahan, membuat lahan baru, dan melihat detail lahan.

Acceptance criteria:

- daftar lahan dapat diakses dari fitur lahan;
- pengguna dapat menambahkan data lahan baru;
- detail lahan menampilkan informasi yang relevan.

#### FR-04: Monitoring pertanian

Pengguna dapat melihat laman monitoring yang memuat informasi penting terkait pertanian dan kondisi lingkungan.

Acceptance criteria:

- fitur monitoring tersedia di navigasi utama;
- pengguna dapat melihat ringkasan informasi yang relevan;
- tampilan dapat disesuaikan untuk layar mobile.

#### FR-05: Prediksi cuaca

Sistem menampilkan prediksi cuaca dan rekomendasi kegiatan berdasarkan curah hujan.

Acceptance criteria:

- data cuaca dapat dimuat dari layanan eksternal;
- pengguna dapat memilih rentang hari prediksi;
- rekomendasi muncul berdasarkan kondisi cuaca.

#### FR-06: Konten edukasi

Pengguna dapat membaca konten atau artikel pertanian dan melihat detailnya.

Acceptance criteria:

- daftar konten ditampilkan;
- detail konten dapat dibuka;
- pengguna dapat kembali ke daftar dengan mudah.

#### FR-07: Komunitas

Pengguna dapat mengakses komunitas pertanian dan melihat aktivitas terkait.

Acceptance criteria:

- halaman komunitas dapat dibuka;
- komponen komunitas muncul di beranda dan detail komunitas.

#### FR-08: Diagnosa penyakit tanaman

Pengguna dapat mengakses fitur prediksi penyakit tanaman dan melihat riwayat prediksi.

Acceptance criteria:

- fitur diagnosis tersedia dari navigasi yang sesuai;
- pengguna dapat memulai prediksi;
- hasil prediksi dan riwayat dapat ditampilkan.

#### FR-09: Profil pengguna

Pengguna dapat melihat profil akun dan informasi yang terkait dengan akun.

Acceptance criteria:

- data profil dapat ditampilkan;
- navigasi akun jelas dan mudah dipahami.

### 8.2 Non-functional requirements

#### NFR-01: Performance

- waktu buka layar utama harus cepat dan responsif;
- refresh data tidak melebihi waktu yang memadai untuk pengalaman mobile.

#### NFR-02: Reliability

- aplikasi harus menangani error jaringan dengan baik;
- gagal memuat data tidak boleh menghentikan seluruh pengalaman pengguna.

#### NFR-03: Security

- halaman yang memerlukan autentikasi harus terlindungi dengan auth guard;
- token/session harus ditangani secara aman.

#### NFR-04: Usability

- navigasi harus sederhana dan konsisten;
- teks dan ikon harus mudah dipahami oleh pengguna dengan latar belakang non-teknis.

#### NFR-05: Maintainability

- struktur modul harus tetap dipelihara sesuai arsitektur modular.
- fitur harus dipisahkan berdasarkan modul dan concern.

## 9. User Stories

- Sebagai petani, saya ingin login ke aplikasi agar dapat mengakses fitur yang relevan.
- Sebagai petani, saya ingin melihat daftar lahan agar saya dapat mengelola aktivitas pertanian saya.
- Sebagai petani, saya ingin melihat prediksi cuaca agar saya dapat merencanakan tindakan di lahan.
- Sebagai pengguna, saya ingin membaca artikel dan tips pertanian agar saya memperluas pengetahuan.
- Sebagai pengguna, saya ingin mendapatkan rekomendasi kesehatan tanaman agar saya dapat mengambil tindakan cepat jika terjadi masalah.
- Sebagai pengguna, saya ingin melihat profil saya agar saya dapat memastikan akun saya benar.

## 10. User Flow Utama

1. Pengguna membuka aplikasi.
2. Sistem menampilkan splash screen.
3. Jika belum login, pengguna diarahkan ke halaman autentikasi.
4. Setelah login, pengguna masuk ke dashboard utama.
5. Dari dashboard, pengguna dapat memilih fitur: Home, Farming, Monitoring, Post, Community, atau Profile.
6. Pengguna dapat membuka detail lahan, artikel, or prediksi sesuai kebutuhan.
7. Sistem menampilkan data terbaru dan menyimpan riwayat aktivitas jika diperlukan.

## 11. Product Roadmap

### MVP (Versi saat ini)

- autentikasi
- home dashboard
- lahan
- monitoring
- prediksi cuaca
- konten dan komunitas
- prediksi penyakit tanaman

### Fase berikutnya

- notifikasi cuaca dan peringatan tanaman
- fitur AI konsultasi pertanian
- integrasi data lahan lebih detail
- analitik kinerja panen
- ekspor laporan dan data agribisnis

## 12. Risks dan Open Questions

### Risks

- ketergantungan pada API eksternal (cuaca, data pertanian);
- perbedaan kualitas data pada pengguna yang berbeda;
- kebutuhan onboarding yang mungkin tinggi untuk pengguna pertanian non-digital.

### Open questions

- apakah aplikasi akan dioptimalkan untuk petani skala kecil atau besar?
- apakah fitur diagnosis penyakit akan berbasis AI, rule-based, atau integrasi ke model eksternal?
- apakah aplikasi akan mendukung multi bahasa secara penuh?
- apakah data lahan akan disimpan secara lokal atau melalui backend terpusat?

## 13. Kesimpulan

Petanitech Mobile App memiliki arah yang jelas sebagai platform digital pertanian yang menggabungkan informasi, monitoring, edukasi, dan pengelolaan lahan dalam satu pengalaman mobile. Produk ini sesuai dengan kebutuhan petani modern yang membutuhkan solusi simple, cepat, dan berbasis data untuk menjalankan aktivitas pertanian secara lebih terukur.

Dengan struktur modul yang sudah terbentuk pada proyek ini, produk dapat terus dikembangkan secara bertahap tanpa mengganggu arsitektur inti. PRD ini menjadi fondasi untuk perencanaan fitur, pengembangan berkelanjutan, dan evaluasi keberhasilan produk di masa depan.

## 14. Referensi Sistem

- [README.md](README.md)
- [lib/main.dart](lib/main.dart)
- [lib/core/app_module.dart](lib/core/app_module.dart)
- [lib/modules/auth/auth_module.dart](lib/modules/auth/auth_module.dart)
- [lib/modules/main/main_module.dart](lib/modules/main/main_module.dart)
- [lib/modules/farm/farm_module.dart](lib/modules/farm/farm_module.dart)
- [lib/modules/monitoring/monitoring_module.dart](lib/modules/monitoring/monitoring_module.dart)
- [lib/modules/post/post_module.dart](lib/modules/post/post_module.dart)
- [lib/modules/disesase/disease_modul.dart](lib/modules/disesase/disease_modul.dart)
