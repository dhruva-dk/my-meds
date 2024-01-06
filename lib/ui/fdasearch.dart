import 'package:flutter/material.dart';
import 'package:medication_tracker/local_service/camera_helper.dart';
import 'package:medication_tracker/model/medication_model.dart';
import 'package:medication_tracker/providers/fda_api_provider.dart';
import 'package:medication_tracker/providers/medication_provider.dart';
import 'package:medication_tracker/ui/createmedication.dart';
import 'package:provider/provider.dart';
import 'package:medication_tracker/widgets/search_tile.dart';
//permission handler
import 'package:permission_handler/permission_handler.dart';

//import async
import 'dart:async';

class FDASearchPage extends StatefulWidget {
  const FDASearchPage({super.key});

  @override
  _FDASearchPageState createState() => _FDASearchPageState();
}

class _FDASearchPageState extends State<FDASearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.length >= 3) {
        Provider.of<FDAAPIServiceProvider>(context, listen: false)
            .searchMedications(_searchController.text.toLowerCase());
      }
    });
  }

  //methods for the image save:
  void _handleTakePhoto() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      String? imagePath = await CameraHelper
          .captureAndSaveImage(); // NB: image picker handled in
      //camera helper
      if (imagePath != null) {
        _createAndSaveMedication(imagePath);
      } else {
        // Handle image capture failure with snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error capturing image'),
            ),
          );
        }
      }
    } else {
      // Handle permission denial
      _showPermissionDeniedDialog();
    }
  }

  void _createAndSaveMedication(String imagePath) {
    Medication newMedication = Medication(
      name: "Photo",
      dosage: "Tap to edit details",
      additionalInfo: "",
      imageUrl: imagePath,
    );

    // Save newMedication to state management solution
    // For example, using Provider:
    Provider.of<MedicationProvider>(context, listen: false)
        .addMedication(newMedication);

    // Navigate back to the Home Screen
    Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Camera Permission Needed"),
          content:
              Text("Camera access is required to take pictures of medications. "
                  "Please enable camera access in your device settings."),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Open Settings"),
              onPressed: () {
                openAppSettings(); // This requires 'package:permission_handler/permission_handler.dart'
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  //ui build code

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FDA Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              // ... text field decoration ...
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          Colors.black, // Black color for Manual Input
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      // Navigate to create medication page with no initial drug
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateMedicationPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Manual Input',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Spacing between buttons
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, // Text color
                      backgroundColor:
                          Colors.grey[100], // Button background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(color: Colors.black, width: 2),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16), // Increased padding
                    ),
                    onPressed: () {
                      // Add your onPressed code here for taking a picture
                      _handleTakePhoto();
                    },
                    child: const Text(
                      'Take a Picture',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<FDAAPIServiceProvider>(
                builder: (context, provider, child) {
                  try {
                    if (provider.errorMessage.isNotEmpty) {
                      return Center(child: Text(provider.errorMessage));
                    }
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                      itemCount: provider.searchResults.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CreateMedicationPage(
                                        initialDrug:
                                            provider.searchResults[index])),
                              );
                            },
                            child: SearchTile(
                                drug: provider.searchResults[index]));
                      },
                    );
                  } catch (e) {
                    return Center(child: Text('Error: $e'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
