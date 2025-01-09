import 'package:flutter/material.dart';
import 'package:medication_tracker/data/model/fda_drug_model.dart';
import 'package:medication_tracker/data/model/medication_model.dart';
import 'package:medication_tracker/data/providers/medication_provider.dart';
import 'package:medication_tracker/data/providers/profile_provider.dart';
import 'package:medication_tracker/services/image/image_service.dart';
import 'package:medication_tracker/services/storage/local_storage_service.dart';
import 'package:medication_tracker/ui/core/black_button.dart';
import 'package:medication_tracker/ui/core/header.dart';
import 'package:medication_tracker/ui/core/photo_upload_button.dart';
import 'package:medication_tracker/ui/edit_medication/zoomable_image.dart';
import 'package:medication_tracker/ui/home/home_view.dart';
import 'package:provider/provider.dart';

class CreateMedicationPage extends StatefulWidget {
  final FDADrug? initialDrug;
  final String? imageFileName;

  const CreateMedicationPage({super.key, this.initialDrug, this.imageFileName});

  @override
  _CreateMedicationPageState createState() => _CreateMedicationPageState();
}

class _CreateMedicationPageState extends State<CreateMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _additionalInfoController;
  String _imageFileName = '';

  @override
  void initState() {
    super.initState();
    _imageFileName = widget.imageFileName ?? '';
    _nameController = TextEditingController(
      text: widget.initialDrug != null
          ? "Brand: ${widget.initialDrug!.brandName} - Generic: ${widget.initialDrug!.genericName}"
          : widget.imageFileName != null
              ? "Image"
              : '',
    );
    _dosageController = TextEditingController();
    _additionalInfoController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  void _handleTakePhoto() async {
    final imagePickerService =
        Provider.of<ImageService>(context, listen: false);
    try {
      String imageFileName = await imagePickerService.takePhoto();
      setState(() => _imageFileName = imageFileName);
    } catch (e) {
      _showErrorSnackbar(context, e.toString());
    }
  }

  void _handleUploadFromGallery() async {
    final imagePickerService =
        Provider.of<ImageService>(context, listen: false);
    try {
      String imageFileName = await imagePickerService.pickFromGallery();
      setState(() => _imageFileName = imageFileName);
    } catch (e) {
      _showErrorSnackbar(context, e.toString());
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _accept(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final String dosage = _dosageController.text;
      final String additionalInfo = _additionalInfoController.text;

      Medication newMedication = Medication(
        name: name,
        dosage: dosage,
        additionalInfo: additionalInfo,
        profileId: context.read<ProfileProvider>().selectedProfile!.id!,
        imageUrl: _imageFileName,
      );

      try {
        await Provider.of<MedicationProvider>(context, listen: false)
            .addMedication(newMedication);
        if (!context.mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving medication')),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasImage = _imageFileName.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Header(
              title: 'Add Medication',
              showBackButton: Navigator.canPop(context),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration('Name'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a medication name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _dosageController,
                            decoration: _inputDecoration('Dosage (optional)'),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _additionalInfoController,
                            decoration:
                                _inputDecoration('Additional Info (optional)'),
                          ),
                          if (hasImage) ...[
                            const SizedBox(height: 16),
                            FutureBuilder<String>(
                              future: Provider.of<LocalStorageService>(context,
                                      listen: false)
                                  .getFilePath(_imageFileName),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ZoomableImage(
                                      imagePath: snapshot.data!);
                                }
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          PhotoUploadButton(
                            onTakePhoto: _handleTakePhoto,
                            onUploadPhoto: _handleUploadFromGallery,
                            hasImage: hasImage,
                          ),
                          const SizedBox(height: 16),
                          BlackButton(
                            title: "Add Medication",
                            onTap: () => _accept(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
