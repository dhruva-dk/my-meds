import 'package:flutter/material.dart';

import 'package:medication_tracker/providers/medication_provider.dart';
import 'package:medication_tracker/providers/profile_provider.dart';
import 'package:medication_tracker/ui/createmedication.dart';
import 'package:medication_tracker/ui/editmedication.dart';
import 'package:medication_tracker/ui/editprofile.dart';
import 'package:medication_tracker/ui/fdasearch.dart';
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
        top: true,
        left: false,
        right: false,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //padding only on left 16px and a header saying "Your Medications"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                  child: Text(
                    profileProvider.userProfile?.name ?? "Name not available",
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
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
                            ); // Using your custom MedicationTile widget
                          },
                        );
                      },
                    )),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FDASearchPage()),
          );
        },
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        elevation: 3.0,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        child: const Icon(Icons.add, color: Colors.white, size: 20),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
