import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/education.dart';

/// Halaman detail untuk menampilkan seluruh informasi dari satu entri [Education].
class EducationDetailScreen extends StatelessWidget {
  const EducationDetailScreen({super.key, required this.education});

  final Education education;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final period = education.endYear.trim().isEmpty
        ? '${education.startYear} – Present'
        : '${education.startYear} – ${education.endYear}';

    return Scaffold(
      appBar: AppBar(
        title: Text(education.school),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
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
                  education.school,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  education.degree,
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
                Text(education.description, style: theme.textTheme.bodyMedium),
                if (education.logo.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Logo Path / URL',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    education.logo,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
                const Divider(height: 28),
                Row(
                  children: [
                    Icon(
                      education.isStarred ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${education.starCount} Star(s)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (education.starredByNames.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Starred by: ${education.starredByNames}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                if (education.id != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Entry ID: #${education.id}',
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
    );
  }
}
