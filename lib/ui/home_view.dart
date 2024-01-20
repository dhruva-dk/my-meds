import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:medication_tracker/providers/medication_provider.dart';
import 'package:medication_tracker/providers/profile_provider.dart';
import 'package:medication_tracker/ui/edit_medication_view.dart';
import 'package:medication_tracker/ui/edit_profile_view.dart';
import 'package:medication_tracker/ui/fda_search_view.dart';
import 'package:medication_tracker/widgets/home_speed_dial.dart';
import 'package:medication_tracker/widgets/med_tile.dart';
// Import your medication provider

//import provider
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(
    BuildContext context,
  ) {
    // Listening to the medicationListProvider
    /// placeholder medication data in medicationList
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //padding only on laqeft 16px and a header saying "Your Medications"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  // Moved Expanded to wrap Padding
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                    child: AutoSizeText(
                      profileProvider.userProfile?.name ?? "Name not available",
                      style: const TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      minFontSize: 18,
                      maxLines:
                          1, // You might want to set a maximum number of lines
                    ),
                  ),
                ),
                //iconbutton to go to edit profile
                Padding(
                  padding: const EdgeInsets.only(right: 16, top: 8.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.account_circle,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      // Navigate to the Edit Profile page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditProfilePage()),
                      );
                    },
                  ),
                ),
              ],
            ),

            //padding only on left 16px, 0 on top and a subheader in grey with the current date
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                "Date of Birth: ${profileProvider.userProfile?.dob ?? "No date of birth"}",
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
                                "No medications. Add by pressing the medication button in the bottom right.",
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

                        //if is loading, return circular progress indicator

                        return ListView.builder(
                          itemCount: medicationList.length,
                          itemBuilder: (context, index) {
                            final medication = medicationList[index];
                            return MedicationTile(
                                medication:
                                    medication); // Using your custom MedicationTile widget
                          },
                        );
                      },
                    )),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const HomeSpeedDial(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
