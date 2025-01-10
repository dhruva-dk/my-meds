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
  State<CreateMedicationPage> createState() => _CreateMedicationPageState();
}

class _CreateMedicationPageState extends State<CreateMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _additionalInfoController;
  String _imageFileName = '';
  String? _selectedUnit;

  final List<String> _unitOptions = [
    'N/A', // Added "N/A" option
    'mg',
    'mL',
    'g',
    'mcg',
    'IU',
    '%'
  ];

  @override
  void initState() {
    super.initState();
    _imageFileName = widget.imageFileName ?? '';
    _nameController = TextEditingController(
      text: widget.initialDrug != null
          ? "Brand: ${widget.initialDrug!.brandName}\nGeneric: ${widget.initialDrug!.genericName}"
          : widget.imageFileName != null
              ? "Image"
              : '',
    );
    _dosageController = TextEditingController();
    _additionalInfoController = TextEditingController(
        text: widget.initialDrug != null
            ? "Dosage type: ${widget.initialDrug!.dosageForm}"
            : "");
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
      if (!mounted) return;
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
      if (!mounted) return;
      _showErrorSnackbar(context, e.toString());
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _accept(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final String dosage = _dosageController.text.trim().isEmpty
          ? ''
          : '${_dosageController.text} ${_selectedUnit == 'N/A' ? '' : _selectedUnit ?? ''}';
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

        // Only navigate if the operation is successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } catch (e) {
        // Stay on the current screen and show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add medication: $e')),
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
                            maxLines: null, // Allows the field to expand
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _dosageController,
                                  decoration: _inputDecoration(
                                      'Dosage (optional)'), // Updated label
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      final number = double.tryParse(value);
                                      if (number == null) {
                                        return 'Please enter a valid number';
                                      }
                                    }
                                    return null; // Allow empty values
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: DropdownButtonFormField<String>(
                                  value: _selectedUnit,
                                  decoration: _inputDecoration('Unit'),
                                  items: _unitOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedUnit = newValue;
                                    });
                                  },
                                  validator: (value) {
                                    // Only validate the unit if dosage is provided
                                    if (_dosageController.text.isNotEmpty &&
                                        value == null) {
                                      return 'Please select a unit';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _additionalInfoController,
                            decoration:
                                _inputDecoration('Additional Info (optional)'),
                            maxLines: null, // Allows the field to expand
                          ),
                          if (hasImage) ...[
                            const SizedBox(height: 16),
                            // Rounded Image with Caption
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: FutureBuilder<String>(
                                    future: Provider.of<LocalStorageService>(
                                            context,
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
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                          PhotoUploadButton(
                            onTakePhoto: _handleTakePhoto,
                            onUploadPhoto: _handleUploadFromGallery,
                            hasImage: hasImage,
                          ),
                          const SizedBox(height: 8),
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
