Nama : Nasywa Namira Suhendro
NPM : 2506532196
Kelas : PBP C

### Tugas 7

## Deskripsi Tugas 7

Pada Tugas 7, saya melanjutkan proyek Flutter dari Tutorial 08 untuk membangun halaman awal portofolio pribadi dengan fokus pada bagian **Education**. Halaman utama menampilkan tiga kartu identitas yang berisi NPM, nama lengkap, dan kelas PBP saya.

Menu utama menggunakan `StatelessWidget` karena belum membutuhkan pengelolaan state internal yang berubah. Kode bootstrap aplikasi tetap berada di `main.dart`, sedangkan halaman utama dan komponen kartunya berada di `menu.dart`. Widget `InfoCard` digunakan kembali untuk menampilkan setiap informasi identitas, sementara `ItemCard` digunakan untuk membangun tombol menu.

Terdapat tiga tombol, yaitu **Lihat Education**, **Tambah Education**, dan **Logout**. Setiap tombol memiliki ikon dan warna latar berbeda, yaitu biru, hijau, dan merah. Pengaturan warna dilakukan melalui atribut `Color color` pada model `ItemHomepage`, kemudian digunakan oleh widget `Material` melalui `item.color`. Dengan cara ini, warna setiap tombol dapat ditentukan melalui data tanpa menambahkan percabangan berdasarkan nama tombol.

Ketika tombol ditekan, aplikasi menampilkan SnackBar dengan pesan “Kamu telah menekan tombol [Nama Tombol]!”. Pesan mengambil nama dari `item.name` sehingga tetap sesuai dengan tombol yang dipilih. Sebelum menampilkan pesan baru, `hideCurrentSnackBar()` dipanggil untuk menyembunyikan SnackBar yang sedang tampil.

Pada tahap ini, tombol baru memberikan umpan balik berupa SnackBar. Halaman daftar pendidikan, form penambahan pendidikan, proses logout sebenarnya, dan integrasi API Django belum diimplementasikan.

## Pertanyaan Reflektif

1. **Jelaskan apa yang dimaksud dengan *widget tree* pada Flutter dan bagaimana hubungan induk-anak *(parent-child)* bekerja antar-widget!**

   Widget tree merupakan susunan widget yang membentuk tampilan aplikasi Flutter secara hierarkis. Sebuah widget dapat memiliki widget lain di dalamnya sehingga terbentuk hubungan induk-anak atau parent-child.

   Widget parent mengatur susunan dan batasan *layout* anaknya, sedangkan widget child membangun bagian tampilan sesuai batasan tersebut. Widget yang menampung satu anak biasanya menggunakan properti `child`, sedangkan widget yang menampung beberapa anak menggunakan `children`.

   Pada aplikasi saya, `Scaffold` memiliki `AppBar` dan bagian `body`. Di dalam `body` terdapat `Padding` yang membungkus `Column`. Lalu `Column` menampung susunan card identitas, text sambutan, dan action menu. Susunan tersebut merupakan contoh hubungan parent-child dalam widget tree.

2. **Sebutkan semua *widget* yang kamu gunakan dalam proyek ini dan jelaskan fungsinya masing-masing!**

   Widget bawaan FLutter yang saya gunakan adalah:

   - `MaterialApp`: menyediakan konfigurasi utama aplikasi, seperti judul, tema, dan halaman awal.
   - `Scaffold`: menyediakan struktur dasar halaman, termasuk `appBar` dan `body`.
   - `AppBar`: menampilkan judul aplikasi pada bagian atas halaman.
   - `Text`: menampilkan tulisan, seperti identitas user, nama button, dan pesan sambutan.
   - `Padding`: memberikan ruang di area sekeliling widget agar tampilan tidak terlalu rapat.
   - `Column`: menyusun widget secara vertikal.
   - `Row`: menyusun widget secara horizontal, yaitu pada bagian card identitas.
   - `SizedBox`: memberikan jarak antarbagian tampilan.
   - `Center`: menempatkan widget anak di tengah space yang tersedia.
   - `GridView.count`: menyusun card menu dalam kisi dengan jumlah kolom yang ditentukan.
   - `Card`: menampilkan informasi dalam bentuk kartu dengan efek elevasi.
   - `Container`: membungkus widget serta mengatur ukuran padding.
   - `Material`: menyediakan permukaan Material dan warna background untuk card/kartu menu.
   - `InkWell`: mendeteksi ketukan pengguna dan memberikan efek ripple pada kartu.
   - `Icon`: menampilkan ikon pada setiap tombol menu.
   - `SnackBar`: menampilkan pesan sementara ketika pengguna menekan tombol.

   Selain itu, dari Tutorial 8 saya membuat widget sendiri:
   - `MyApp`: membangun konfigurasi utama aplikasi melalui `MaterialApp`.
   - `MyHomePage`: membangun halaman utama yang berisi identitas dan menu Education.
   - `InfoCard`: membuat kartu informasi yang dapat digunakan kembali untuk NPM, nama, dan kelas.
   - `ItemCard`: membuat kartu tombol berdasarkan data nama, ikon, dan warna dari `ItemHomePage`.

   Widget yang dibuat menggunakan `StatelessWidget` sebagai kelas dasar. Sementara itu, `ItemHomePage` merupakan model data (bukan widget). 
   `ScaffoldMessenger.of(context)` digunakan untuk mengakses pengelola SnackBar yang tersedia pada widget tree.

3. **Apa fungsi dari widget `MaterialApp`? Jelaskan mengapa *widget* ini umumnya digunakan sebagai *root widget* pada aplikasi Flutter!**

   `MaterialApp` berfungsi sebagai pembungkus utama aplikasi yang menggunakan Material Design. Widget ini menyediakan konfigurasi aplikasi, seperti tema, halaman awal, dan dukungan lokalisasi.

   Pada aplikasi saya, `MaterialApp` mengatur judul `MyPortfolio`, tema melalui `ThemeData`, dan halaman awal melalui `home: MyHomePage()`.

   `MaterialApp` umumnya diletakkan di dekat root widget tree agar konfigurasi dan fasilitas tersebut dapat digunakan oleh widget di bawahnya secara konsisten. Pada proyek saya, widget yang diberikan langsung ke `runApp()` adalah `MyApp`, kemudian `MyApp` mengembalikan `MaterialApp`.

4. **Jelaskan perbedaan antara `StatelessWidget` dan `StatefulWidget`! Kapan kita sebaiknya memilih `StatelessWidget` dan kapan harus menggunakan `StatefulWidget`?**

   `StatelessWidget` merupakan widget yang tidak memiliki objek `State` untuk menyimpan keadaan internal yang berubah selama penggunaannya. Tampilannya dibangun berdasarkan konfigurasi yang diterima dan informasi dari `BuildContext`. Widget ini tetap dapat dibangun ulang ketika konfigurasi dari parent atau dependensi yang digunakannya berubah.

   `StatefulWidget` memiliki objek `State` terpisah untuk menyimpan keadaan yang dapat berubah. Ketika perubahaan tersebut memengaruhi tampilan, pemanggilan `setState()` dapat digunakan untuk meminta FLutter membangun ulang bagian tampilan terkait.

   Saya menggunakan `StatelessWidget` untuk `MyHomePage`, `InfoCard`, dan `ItemCard` karena widget tersebut belum perlu mengelola keadaan internal yang berubah. Menekan tombol hanya memunculkan SnackBar melalui `ScaffoldMessenger`.

   `StatefulWidget` cocok digunakan ketika widget perlu mengelola perubahan keadaan, misalnya jumlah penghitung, status pilihan pengguna, atau pengaturan mode terang dan gelap yang berubah setelah tombol ditekan.

5. **Apa itu `BuildContext` dan mengapa penting di Flutter? Bagaimana penggunaannya di dalam metode `build`?**

    `BuildContext`merupakan objek yang menunjukkan lokasi sebuah widget dalam widget tree. Lokasi ini penting karena Flutter menggunakannya untuk mencari informasi atau fasilitas yang tersedia dari ancestor, yaitu widget di atasnya.

    Pada method `Widget build(BuildContext context)`, parameter `context` digunakan saat menyusun tampilan dan mengakses informasi yang dibutuhkan widget.

    Dalam proyek saya, penggunaannya antara lain:

    - `Theme.of(context)`: mengambil tema untuk menentukan warna AppBar.
    - `MediaQuery.of(context)`: mengambil informasi ukuran tampilan untuk menentukan lebar kartu identitas.
    - `ScaffoldMessenger.of(context)`: mengakses pengelola SnackBar untuk menampilkan pesan ketika tombol ditekan.

    Penggunaan context harus sesuai dengan posisi widget. Sebagai contoh, context yang digunakan untuk mengambil tema aplikasi perlu berada di bawah  widget yang menyediakan tema tersebut.


6. **Jelaskan konsep *hot reload* di Flutter dan apa perbedaannya dengan *hot restart*! Kapan kita tidak bisa hanya mengandalkan *hot reload* dan harus melakukan *hot restart* atau *full restart*?**

    Hot reload merupakan fitur untuk menerapkan perubahan kode ke aplikasi yang sedang berjalan sambil mempertahankan state yang ada. Flutter membangun ulang tampilan menggunakan perubahan tersebut tanpa menjalankan ulang `main()` dan `initState()`.

    Hot reload cocok untuk perubahan tampilan, seperti mengubah teks, warna, padding, atau susunan widget.

    Hot restart menjalankan ulang aplikasi Flutter dari awal, termasuk `main()`, sehingga state sebelumnya hilang dan inisialisasi aplikasi diulang. Proses ini diperlukan ketika perubahan bergantung pada kode inisialisasi yang tidak dijalankan kembali oleh hot reload.

    Full restart dilakukan dengan menghentikan aplikasi, lalu membangun dan menjalankannya kembali. Proses ini diperlukan untuk perubahan kode native, seperti Kotlin, Java, Swift, atau Objective-C, serta perubahan konfigurasi platform yang memerlukan build ulang.

    Jadi, saya menggunakan hot reload untuk mencoba perubahan tampilan, hot restart untuk mengulang inisialisasi atau mereset state, dan full restart ketika perubahan memerlukan pembangunan ulang aplikasi pada platform yang digunakan.

## AI Disclosure

- Tool yang digunakan  
  ChatGPT

- Tautan Log / Sesi Percakapan  
  [ChatGPT](https://chatgpt.com/share/6af43ef9-6a08-83ec-ad53-388f3d129f1b)

- Strategi Prompting  
  Saya menggunakan AI sebagai mentor untuk memahami instruksi tugas dan melakukan implementasi secara bertahap. Saya melampirkan PDF tutorial dan tugas, serta tangkapan layar kode dan hasil aplikasi. Pertanyaan diberikan berdasarkan bagian yang sedang dikerjakan, mulai dari penyesuaian menu Education, pengaturan warna tombol, penggunaan Git. Saya juga meminta penjelasan mengenai bagian kode yang perlu diubah agar dapat memahami penerapannya pada proyek.

- Bagian yang Dibantu AI

  1. Memberikan contoh penambahan atribut `Color color` pada model `ItemHomePage` agar setiap tombol dapat memiliki warna berbeda.
  2. Menjelaskan penggunaan `item.color` pada widget `Material` dan penyesuaian nama serta ikon tombol untuk menu Education.
  3. Menjelaskan hubungan nama tombol dengan pesan SnackBar yang menggunakan `item.name`.

- Keterbatasan AI

  AI memberikan saran berdasarkan berkas dan tangkapan layar yang dilampirkan sehingga belum tentu mengetahui seluruh kondisi proyek terbaru. AI juga tidak menjalankan aplikasi pada laptop saya, sehingga saran kode tidak dapat langsung dianggap sebagai bukti bahwa aplikasi bebas masalah.

  Selain itu, AI sempat menyarankan fitur tambahan seperti mode terang dan gelap serta layout responsif. Saran tersebut belum saya implementasikan, sehingga tidak dicantumkan sebagai fitur yang sudah tersedia. Contoh nama menu dari AI juga perlu disesuaikan agar konsisten dengan implementasi saya.

- Penyesuaian Manual

    Saya menyesuaikan nama tombol menjadi **Lihat Education** dan **Tambah Education** agar sesuai dengan bagian portofolio yang dipilih. Saya menerapkan perubahan pada `menu.dart`, menjalankan aplikasi, dan mencoba tampilan serta respons tombol secara langsung.

- Refleksi Penggunaan AI

    AI membantu memperjelas langkah pengerjaan dan memberikan contoh penerapan konsep Flutter pada kode saya. Tetapi saya tetap perlu memahami hubungan antara model data dan widget, memeriksa hasil perubahan, serta memastikan dokumentasi sesuai dengan fitur yang benar-benar tersedia.