import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

/// Halaman detail untuk menampilkan seluruh informasi dari satu entri [Education].
class EducationDetailScreen extends StatefulWidget {
  const EducationDetailScreen({super.key, required this.education});

  final Education education;

  @override
  State<EducationDetailScreen> createState() => _EducationDetailScreenState();
}

class _EducationDetailScreenState extends State<EducationDetailScreen> {
  late Education _education;
  bool _hasChanged = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _education = widget.education;
  }

  Future<void> _handleEdit() async {
    if (_education.id == null) return;
    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;

    final updated = await Navigator.push<Education>(
      context,
      MaterialPageRoute<Education>(
        builder: (context) => EducationFormPage(initialEducation: _education),
      ),
    );

    if (updated != null) {
      setState(() {
        _education = updated;
        _hasChanged = true;
      });
    }
  }

  Future<void> _handleDelete() async {
    final id = _education.id;
    if (id == null) return;

    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Education?'),
        content: Text(
          'Apakah kamu yakin ingin menghapus riwayat pendidikan di "${_education.school}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final token = context.read<AuthState>().token;
    if (token == null) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await context.read<ApiClient>().deleteEducation(id, token: token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Education berhasil dihapus!')),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        await context.read<AuthState>().logout();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi login telah berakhir. Silakan login kembali.'),
          ),
        );
        await ensureLoggedIn(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus Education (HTTP ${e.statusCode}).'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final period = _education.endYear.trim().isEmpty
        ? '${_education.startYear} – Present'
        : '${_education.startYear} – ${_education.endYear}';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context, _hasChanged);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_education.school),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          actions: [
            if (_education.id != null) ...[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _isDeleting ? null : _handleEdit,
                tooltip: 'Edit Education',
              ),
              IconButton(
                onPressed: _isDeleting ? null : _handleDelete,
                tooltip: 'Hapus Education',
                icon: _isDeleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.delete),
              ),
            ],
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _education.school,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _education.degree,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 6),
                      Text(period, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  const Divider(height: 28),
                  Text(
                    'Description',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _education.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (_education.logo.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Logo Path / URL',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _education.logo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                  const Divider(height: 28),
                  Row(
                    children: [
                      Icon(
                        _education.isStarred ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_education.starCount} Star(s)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (_education.starredByNames.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Starred by: ${_education.starredByNames}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  if (_education.id != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Entry ID: #${_education.id}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
