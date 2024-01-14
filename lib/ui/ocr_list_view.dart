import 'package:flutter/material.dart';
import 'package:medication_tracker/model/ocr_title.dart'; // Assuming this is the model
import 'package:medication_tracker/model/medication_model.dart';
import 'package:medication_tracker/widgets/ocr_name_tile.dart'; // Or any other page you navigate to

class AddNamePage extends StatefulWidget {
  final List<OCRTitle> ocrTitles;
  final Medication medication;

  const AddNamePage(
      {Key? key, required this.ocrTitles, required this.medication})
      : super(key: key);

  @override
  _AddNamePageState createState() => _AddNamePageState();
}

class _AddNamePageState extends State<AddNamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Name'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black, // Black color for Skip button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                minimumSize: const Size(double.infinity, 50),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                // Handle the skip action, navigate or update state as needed
              },
              child: const Text(
                'Skip this step',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.ocrTitles.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () {},
                      child: OCRTile(title: widget.ocrTitles[index]));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
