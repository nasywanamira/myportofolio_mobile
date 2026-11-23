import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Halaman formulir untuk menambahkan riwayat pendidikan (Education) baru.
///
/// Menggunakan [StatefulWidget] dan [GlobalKey<FormState>] untuk mengelola
/// state input, validasi aturan model (field wajib, batas panjang karakter,
/// format 4 digit tahun, serta urutan tahun), dan menampilkan ringkasan data
/// dalam [AlertDialog] setelah seluruh input lolos validasi.
/// 
class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  /// Kunci unik untuk mengakses state [Form] guna memicu validasi dan reset.
  final _formKey = GlobalKey<FormState>();

  String _institution = "";
  String _degree = "S1";
  String _major = "";
  String _startYear = "";
  String _endYear = "";
  String _description = "";

  final List<String> _degrees = [
    'SMA/SMK',
    'D3',
    'D4',
    'S1',
    'S2',
    'S3',
    'Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Add Education Form'),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Institusi ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Contoh: Universitas Indonesia",
                    labelText: "Nama Institusi",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _institution = value ?? "";
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Nama institusi tidak boleh kosong!";
                    }
                    if (value.trim().length > 255) {
                      return "Nama institusi maksimal 255 karakter!";
                    }
                    return null;
                  },
                ),
              ),

              // === Jenjang / Degree ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Jenjang Pendidikan (Degree)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  initialValue: _degree,
                  items: _degrees
                      .map(
                        (degree) => DropdownMenuItem(
                          value: degree,
                          child: Text(degree),
                        ),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _degree = newValue;
                      });
                    }
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Jenjang pendidikan wajib dipilih!";
                    }
                    return null;
                  },
                ),
              ),

              // === Jurusan / Major ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Contoh: Sistem Informasi",
                    labelText: "Jurusan / Program Studi",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _major = value ?? "";
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Jurusan tidak boleh kosong!";
                    }
                    if (value.trim().length > 100) {
                      return "Jurusan maksimal 100 karakter!";
                    }
                    return null;
                  },
                ),
              ),

              // === Tahun Mulai ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Contoh: 2025",
                    labelText: "Tahun Mulai",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _startYear = value ?? "";
                    });
                  },
                  validator: (String? value) {
                    final trimmed = value?.trim() ?? "";
                    if (trimmed.isEmpty) {
                      return "Tahun mulai tidak boleh kosong!";
                    }
                    final year = int.tryParse(trimmed);
                    if (trimmed.length != 4 || year == null || year < 1950 || year > 2100) {
                      return "Masukkan 4 digit tahun yang valid (1950–2100)!";
                    }
                    return null;
                  },
                ),
              ),

              // === Tahun Selesai (Opsional) ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Kosongkan jika masih berlangsung (Present)",
                    labelText: "Tahun Selesai (Opsional)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _endYear = value ?? "";
                    });
                  },
                  validator: (String? value) {
                    final trimmed = value?.trim() ?? "";
                    if (trimmed.isEmpty || trimmed.toLowerCase() == "present") {
                      return null;
                    }
                    final endYearInt = int.tryParse(trimmed);
                    if (trimmed.length != 4 || endYearInt == null || endYearInt < 1950 || endYearInt > 2100) {
                      return "Masukkan 4 digit tahun yang valid atau kosongkan!";
                    }
                    final startYearInt = int.tryParse(_startYear.trim());
                    if (startYearInt != null && endYearInt < startYearInt) {
                      return "Tahun selesai tidak boleh lebih awal dari tahun mulai!";
                    }
                    return null;
                  },
                ),
              ),

              // === Deskripsi (Opsional) ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Aktivitas, organisasi, atau pencapaian (opsional)",
                    labelText: "Deskripsi",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _description = value ?? "";
                    });
                  },
                  validator: (String? value) {
                    if (value != null && value.trim().length > 500) {
                      return "Deskripsi maksimal 500 karakter!";
                    }
                    return null;
                  },
                ),
              ),

              // === Tombol Simpan ===
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(primaryColor),
                    ),
                    onPressed: () {
                      // Memvalidasi seluruh field sebelum menampilkan AlertDialog ringkasan data.
                      if (_formKey.currentState!.validate()) {
                        final displayedEndYear = _endYear.trim().isEmpty
                            ? "Present"
                            : _endYear.trim();
                        final displayedDesc = _description.trim().isEmpty
                            ? "-"
                            : _description.trim();

                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Edukasi berhasil ditambahkan!'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Institusi: ${_institution.trim()}'),
                                    Text('Jenjang: $_degree'),
                                    Text('Jurusan: ${_major.trim()}'),
                                    Text('Tahun Mulai: ${_startYear.trim()}'),
                                    Text('Tahun Selesai: $displayedEndYear'),
                                    Text('Deskripsi: $displayedDesc'),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _formKey.currentState!.reset();
                                    setState(() {
                                      _institution = "";
                                      _degree = "S1";
                                      _major = "";
                                      _startYear = "";
                                      _endYear = "";
                                      _description = "";
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: const Text(
                      "Simpan",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}