import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:medication_tracker/data/providers/medication_provider.dart';
import 'package:medication_tracker/data/providers/profile_provider.dart';
import 'package:medication_tracker/ui/edit_medication/edit_medication_view.dart';
import 'package:medication_tracker/ui/search/fda_search_view.dart';
import 'package:medication_tracker/ui/select_profile/select_profile_view.dart';
import 'package:medication_tracker/ui/home/med_tile.dart';
import 'package:medication_tracker/ui/home/nav_bar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  String NameOrNA(String? text) {
    if (text == null || text.isEmpty) {
      return "Name N/A";
    }
    return text;
  }

  String DOBOrNA(String? text) {
    if (text == null || text.isEmpty) {
      return "N/A";
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Profile header section
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          DOBOrNA(profileProvider.selectedProfile?.name),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          minFontSize: 18,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${DOBOrNA(profileProvider.selectedProfile?.dob)}",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Medication list section
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white, // Changed to white for better contrast
                  // Removed border radius for cleaner look
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Consumer<MedicationProvider>(
                        builder: (context, medicationProvider, child) {
                          if (medicationProvider.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (medicationProvider.medications.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  "No medications. Add by pressing the + button below.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
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
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditMedicationPage(
                                          medication: medication),
                                    ),
                                  );
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FDASearchPage()),
          );
        },
        backgroundColor: Colors.black,
        elevation: 6,
        shape: const StadiumBorder(),
        label: const Text(
          'Add',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}
