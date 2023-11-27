import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medication_tracker/models/medication_model.dart';
import 'package:medication_tracker/views/addtest.dart';
import 'package:medication_tracker/widgets/med_tile.dart';
// Import your medication provider

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listening to the medicationListProvider
    /// placeholder medication data in medicationList
    final medicationList = new List<Medication>.generate(
        6,
        (i) => new Medication(
            name: 'Medication ',
            dosage: 'Dosage ',
            additionalInfo: 'Additional Info '));

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
                'Your Medications',
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
                'Today, ${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}',
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
                  child: ListView.builder(
                    itemCount: medicationList.length,
                    itemBuilder: (context, index) {
                      final medication = medicationList[index];
                      return MedicationTile(
                          medication:
                              medication); // Using your custom MedTile widget
                    },
                  ),
                ),
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
