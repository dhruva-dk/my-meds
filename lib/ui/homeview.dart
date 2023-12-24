import 'package:flutter/material.dart';

import 'package:medication_tracker/providers/medication_provider.dart';
import 'package:medication_tracker/ui/addtest.dart';
import 'package:medication_tracker/widgets/med_tile.dart';
// Import your medication provider

//import provider
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(
    BuildContext context,
  ) {
    // Listening to the medicationListProvider
    /// placeholder medication data in medicationList

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
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text(
                'John Doe',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),

            //padding only on left 16px, 0 on top and a subheader in grey with the current date
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                "Date of Birth: 01/01/2000",
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
                  borderRadius: BorderRadius.only(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TestStoragePage()),
          );
        },
        backgroundColor: Colors.black,
        child: Icon(Icons.add, color: Colors.white, size: 20),
        shape: CircleBorder(),
        elevation: 3.0,
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
