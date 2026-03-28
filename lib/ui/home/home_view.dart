import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:medication_tracker/data/providers/medication_provider.dart';
import 'package:medication_tracker/data/providers/profile_provider.dart';
import 'package:medication_tracker/services/export/pdf_service.dart';
import 'package:medication_tracker/ui/edit_medication/edit_medication_view.dart';
import 'package:medication_tracker/ui/home/med_tile.dart';
import 'package:medication_tracker/ui/core/no_profile_view.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _exportKey = GlobalKey();

  void _shareExport(BuildContext context) async {
    final pdfService = Provider.of<PDFService>(context, listen: false);
    final medicationProvider =
        Provider.of<MedicationProvider>(context, listen: false);

    final box = _exportKey.currentContext?.findRenderObject() as RenderBox?;
    final Rect? origin =
        box != null ? box.localToGlobal(Offset.zero) & box.size : null;

    try {
      await pdfService.shareMedications(medicationProvider.medications,
          shareOrigin: origin);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medications PDF shared successfully!')),
      );
    } catch (e) {
      if (!context.mounted) return;
      // Handle the case where 'e' is an Exception or a String, 
      // and remove the 'Exception: ' prefix for a cleaner UI.
      final String fullError = e.toString();
      final String cleanError = fullError.startsWith('Exception: ') 
          ? fullError.replaceFirst('Exception: ', '') 
          : fullError;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cleanError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: true);
    final selectedProfile = profileProvider.selectedProfile;

    if (selectedProfile == null) {
      return NoProfileView(
        title: 'Home',
        header: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(48),
              bottomRight: Radius.circular(48),
            ),
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            left: 32.0,
            right: 32.0,
            bottom: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                "Name N/A",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                overflow: TextOverflow.ellipsis,
                minFontSize: 18,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                "N/A",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 60),
        child: _buildHeader(context),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              color: theme.colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<MedicationProvider>(
                    builder: (context, medicationProvider, child) {
                      if (medicationProvider.medications.isNotEmpty) {
                        return Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                          child: Text(
                            'Your Medications',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  Expanded(
                    child: Consumer<MedicationProvider>(
                      builder: (context, medicationProvider, child) {
                        if (medicationProvider.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (medicationProvider.errorMessage.isNotEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                medicationProvider.errorMessage,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          );
                        }

                        if (medicationProvider.medications.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                "No medications. Add by tapping Add Med below.",
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: medicationProvider.medications.length,
                          itemBuilder: (context, index) {
                            final medication =
                                medicationProvider.medications[index];
                            return GestureDetector(
                              onTap: () async {
                                try {
                                  if (!context.mounted) return;
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditMedicationPage(
                                          medication: medication),
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Failed to edit medication: $e'),
                                    ),
                                  );
                                }
                              },
                              child: MedicationTile(medication: medication),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        key: _exportKey,
        onPressed: () => _shareExport(context),
        backgroundColor: theme.colorScheme.primary,
        elevation: 2,
        shape: const StadiumBorder(),
        label: Text(
          'Export',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        icon: Icon(Icons.share, color: theme.colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: true);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(48),
          bottomRight: Radius.circular(48),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 32.0,
        right: 32.0,
        bottom: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            _nameOrNA(profileProvider.selectedProfile?.name),
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.onSecondary,
            ),
            overflow: TextOverflow.ellipsis,
            minFontSize: 18,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Text(
            _dOBOrNA(profileProvider.selectedProfile?.dob),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _nameOrNA(String? text) =>
      text?.isNotEmpty == true ? text! : "Name N/A";
  String _dOBOrNA(String? text) => text?.isNotEmpty == true ? text! : "N/A";
}
