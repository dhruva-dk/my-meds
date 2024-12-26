import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:medication_tracker/data/repositories/medication_provider.dart';
import 'package:medication_tracker/data/repositories/profile_provider.dart';
import 'package:medication_tracker/ui/edit_medication/edit_medication_view.dart';
import 'package:medication_tracker/ui/search/fda_search_view.dart';
import 'package:medication_tracker/ui/home/med_tile.dart';
import 'package:medication_tracker/ui/home/nav_bar.dart';
// Import your medication provider

//import provider
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
                      "${DOBOrNA(profileProvider.userProfile?.name)}",
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
                /*Padding(
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
                ),*/
              ],
            ),

            //padding only on left 16px, 0 on top and a subheader in grey with the current date
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                "Date of Birth: ${DOBOrNA(profileProvider.userProfile?.dob)}",
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

                        //if is loading, return circular progress indicator

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
      //FAB code
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 10),
        height: 64,
        width: 64,
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          elevation: 0,
          onPressed: () {
            // Navigate to the Add Medication page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FDASearchPage()),
            );
          },
          shape: RoundedRectangleBorder(
            side:
                const BorderSide(width: 3, color: Colors.black), // Black border
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(
            Icons.add,
            color: Colors.black, // Black icon
          ),
        ),
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}
