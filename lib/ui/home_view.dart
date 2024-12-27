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
  Widget build(
    BuildContext context,
  ) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                    child: AutoSizeText(
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16, top: 8.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.account_circle,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      // Navigate to the Select Profile page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SelectProfilePage()),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                "Date of Birth: ${DOBOrNA(profileProvider.selectedProfile?.dob)}",
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 18,
                  color: Colors.grey[300],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Consumer<MedicationProvider>(
                    builder: (context, medicationProvider, child) {
                      final medicationList = medicationProvider.medications;
                      if (medicationProvider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (medicationList.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "No medications. Add by pressing the + button below.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'OpenSans',
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: medicationList.length,
                        itemBuilder: (context, index) {
                          final medication = medicationList[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditMedicationPage(
                                        medication: medication)),
                              );
                            },
                            child: MedicationTile(medication: medication),
                          );
                        },
                      );
                    },
                  ),
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
