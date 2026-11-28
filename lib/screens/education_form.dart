import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/screens/education_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

/// Halaman formulir untuk menambahkan riwayat pendidikan (Education) baru.
///
/// Menggunakan [StatefulWidget] dan [GlobalKey<FormState>] untuk mengelola
/// state input, validasi aturan model (field wajib, batas panjang karakter,
/// format 4 digit tahun, serta urutan tahun), dan menampilkan ringkasan data
/// dalam [AlertDialog] setelah seluruh input lolos validasi.
///
class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key, this.initialEducation});

  final Education?
  initialEducation; // Menyimpan data awal jika ada, untuk keperluan edit.

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  /// Kunci unik untuk mengakses state [Form] guna memicu validasi dan reset.
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _schoolController;
  late final TextEditingController _degreeController;
  late final TextEditingController _startYearController;
  late final TextEditingController _endYearController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _logoController;

  bool _isSubmitting = false;

  bool get _isEditing => widget.initialEducation != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialEducation;
    _schoolController = TextEditingController(text: initial?.school ?? '');
    _degreeController = TextEditingController(text: initial?.degree ?? '');
    _startYearController = TextEditingController(
      text: initial?.startYear ?? '',
    );
    _endYearController = TextEditingController(text: initial?.endYear ?? '');
    _descriptionController = TextEditingController(
      text: initial?.description ?? '',
    );
    _logoController = TextEditingController(text: initial?.logo ?? '');
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _degreeController.dispose();
    _startYearController.dispose();
    _endYearController.dispose();
    _descriptionController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  bool _isValidLogo(String value) {
    if (value.startsWith('/') &&
        !value.startsWith('//') &&
        !value.startsWith(r'/\')) {
      return true;
    }
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;

    final token = context.read<AuthState>().token;
    if (token == null) return;

    setState(() {
      _isSubmitting = true;
    });

    final payload = Education(
      id: widget.initialEducation?.id,
      school: _schoolController.text.trim(),
      degree: _degreeController.text.trim(),
      startYear: _startYearController.text.trim(),
      endYear: _endYearController.text.trim(),
      description: _descriptionController.text.trim(),
      logo: _logoController.text.trim(),
    );

    try {
      final apiClient = context.read<ApiClient>();
      final saved = _isEditing
          ? await apiClient.updateEducation(
              widget.initialEducation!.id!,
              payload,
              token: token,
            )
          : await apiClient.createEducation(payload, token: token);

      if (!mounted) return;

      if (_isEditing) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Education berhasil diperbarui!')),
        );
        Navigator.pop(context, saved);
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Education Created!'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Institusi: ${saved.school}'),
                Text('Jurusan / Gelar: ${saved.degree}'),
                Text(
                  'Periode: ${saved.startYear} – '
                  '${saved.endYear.isEmpty ? "Present" : saved.endYear}',
                ),
                Text('Deskripsi: ${saved.description}'),
                if (saved.logo.isNotEmpty) Text('Logo: ${saved.logo}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _formKey.currentState!.reset();
                _schoolController.clear();
                _degreeController.clear();
                _startYearController.clear();
                _endYearController.clear();
                _descriptionController.clear();
                _logoController.clear();
              },
              child: const Text('Tambah Lagi'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const EducationListScreen(),
                  ),
                );
              },
              child: const Text('Lihat Daftar'),
            ),
          ],
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        await context.read<AuthState>().logout();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
          ),
        );
        await ensureLoggedIn(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan education (HTTP ${e.statusCode}): ${e.message}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(_isEditing ? 'Edit Education' : 'Add Education Form'),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      drawer: _isEditing ? null : const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _schoolController,
                decoration: InputDecoration(
                  hintText: "Contoh: Universitas Indonesia",
                  labelText: "Nama Institusi",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return "Nama institusi tidak boleh kosong!";
                  }
                  if (trimmed.length > 255) {
                    return "Nama institusi maksimal 255 karakter!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _degreeController,
                decoration: InputDecoration(
                  hintText: "Contoh: S1",
                  labelText: "Jenjang Pendidikan (Degree)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return "Jenjang pendidikan wajib dipilih!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startYearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Contoh: 2025",
                  labelText: "Tahun Mulai",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return "Tahun mulai tidak boleh kosong!";
                  }
                  final year = int.tryParse(trimmed);
                  if (trimmed.length != 4 ||
                      year == null ||
                      year < 1950 ||
                      year > 2100) {
                    return "Masukkan 4 digit tahun yang valid (1950–2100)!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _endYearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Kosongkan jika masih berlangsung (Present)",
                  labelText: "Tahun Selesai (Opsional)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty || trimmed.toLowerCase() == 'present') {
                    return null;
                  }
                  final endYearInt = int.tryParse(trimmed);
                  if (trimmed.length != 4 ||
                      endYearInt == null ||
                      endYearInt < 1950 ||
                      endYearInt > 2100) {
                    return "Masukkan 4 digit tahun yang valid atau kosongkan!";
                  }
                  final startYearInt = int.tryParse(
                    _startYearController.text.trim(),
                  );
                  if (startYearInt != null && endYearInt < startYearInt) {
                    return "Tahun selesai tidak boleh lebih awal dari tahun mulai!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Aktivitas, organisasi, atau pencapaian",
                  labelText: "Deskripsi",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return "Deskripsi tidak boleh kosong!";
                  }
                  if (trimmed.length > 500) {
                    return "Deskripsi maksimal 500 karakter!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _logoController,
                decoration: const InputDecoration(
                  hintText: "Contoh: /assets/logo.png atau https://example.com/logo.png",
                  labelText: "Logo Path / URL (Opsional)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return null; // Logo opsional
                  }
                  if (!_isValidLogo(trimmed)) {
                    return "Gunakan URL http(s):// atau path lokal yang diawali /";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_isEditing ? 'Simpan Perubahan' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
