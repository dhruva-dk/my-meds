import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:medication_tracker/providers/medication_provider.dart';
import 'package:medication_tracker/providers/profile_provider.dart';
import 'package:medication_tracker/ui/edit_medication_view.dart';
import 'package:medication_tracker/ui/fda_search_view.dart';
import 'package:medication_tracker/ui/select_profile_view.dart';
import 'package:medication_tracker/widgets/med_tile.dart';
import 'package:medication_tracker/widgets/nav_bar.dart';
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
                            fontFamily: 'OpenSans',
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
                          "Date of Birth: ${DOBOrNA(profileProvider.selectedProfile?.dob)}",
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 18,
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SelectProfilePage()),
                      );
                    },
                    icon: const Icon(
                      Icons
                          .switch_account, // Changed icon to be more descriptive
                      color: Colors.white,
                      size: 24,
                    ),
                    label: const Text(
                      'Switch\nProfile', // Added label for clarity
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
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
                                    fontFamily: 'OpenSans',
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 10),
        height: 64,
        width: 64,
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          elevation: 0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FDASearchPage()),
            );
          },
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 3, color: Colors.black),
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(
            Icons.add,
            color: Colors.black,
          ),
        ),
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}
