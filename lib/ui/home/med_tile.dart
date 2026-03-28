import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medication_tracker/data/model/medication_model.dart';
import 'package:medication_tracker/data/providers/medication_provider.dart';
import 'package:medication_tracker/services/storage/local_storage_service.dart';
import 'package:medication_tracker/ui/edit_medication/edit_medication_view.dart';
import 'package:provider/provider.dart';

class MedicationTile extends StatelessWidget {
  final Medication medication;

  const MedicationTile({
    super.key,
    required this.medication,
  });

  @override
  Widget build(BuildContext context) {
    bool hasImage = medication.imageUrl.isNotEmpty;
    const double imageSize = 64.0;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        _goEditMedication(context, medication);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FutureBuilder<String>(
                  future:
                      Provider.of<LocalStorageService>(context, listen: false)
                          .getFilePath(medication.imageUrl),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Image.file(
                        File(snapshot.data!),
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error,
                              color: theme.colorScheme.error);
                        },
                      );
                    }
                    return SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (medication.dosage.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.medical_services,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            medication.dosage,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (medication.additionalInfo.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            medication.additionalInfo,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_vert,
                  color: theme.colorScheme.onSecondaryContainer),
              onPressed: () => _confirmDelete(context, medication.id!),
            ),
          ],
        ),
      ),
    );
  }

  void _goEditMedication(BuildContext context, Medication medication) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMedicationPage(medication: medication),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog.adaptive(
        title: const Text('Delete Medication'),
        content: const Text(
            'Are you sure you want to delete this medication? This cannot be undone.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _deleteMedication(context, id);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMedication(BuildContext context, int id) async {
    final theme = Theme.of(context);
    try {
      await Provider.of<MedicationProvider>(context, listen: false)
          .deleteMedication(id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Medication deleted successfully.',
            style: TextStyle(color: theme.colorScheme.onPrimary),
          ),
          backgroundColor: theme.colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete medication: $e')),
      );
    }
  }
}
