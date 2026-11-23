import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';


/// Kartu aksi interaktif pada halaman utama yang menampilkan ikon, label,
/// dan warna latar unik sesuai properti [ItemHomepage].
///
/// Menampilkan umpan balik [SnackBar] saat ditekan dan membuka halaman formulir
/// terkait menggunakan [Navigator.push] agar pengguna dapat kembali lewat
/// tombol Back perangkat atau browser.
class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      // Menggunakan warna sekunder dari skema tema aplikasi.
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        // Aksi ketika kartu ditekan oleh pengguna.
        onTap: () {
          // Menampilkan SnackBar dengan pesan interaktif.
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text("Kamu telah menekan tombol ${item.name}!"))
            );
            if (item.name == "Tambah Proyek") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProjectFormPage()),
              );
            } else if (item.name == "Tambah Education") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EducationFormPage()),
              );
            }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  color: Colors.white,
                  size: 30.0,
                ),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}