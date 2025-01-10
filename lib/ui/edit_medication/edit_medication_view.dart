import 'package:flutter/material.dart';
import 'package:medication_tracker/data/model/medication_model.dart';
import 'package:medication_tracker/data/providers/medication_provider.dart';
import 'package:medication_tracker/services/image/image_service.dart';
import 'package:medication_tracker/services/storage/local_storage_service.dart';
import 'package:medication_tracker/ui/core/black_button.dart';
import 'package:medication_tracker/ui/core/header.dart';
import 'package:medication_tracker/ui/core/photo_upload_button.dart';
import 'package:medication_tracker/ui/edit_medication/zoomable_image.dart';
import 'package:medication_tracker/ui/home/home_view.dart';
import 'package:provider/provider.dart';

class EditMedicationPage extends StatefulWidget {
  final Medication medication;

  const EditMedicationPage({Key? key, required this.medication})
      : super(key: key);

  @override
  State<EditMedicationPage> createState() => _EditMedicationPageState();
}

class _EditMedicationPageState extends State<EditMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _additionalInfoController;
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
    _nameController = TextEditingController(text: widget.medication.name);
    _additionalInfoController =
        TextEditingController(text: widget.medication.additionalInfo);

    // Parse the dosage to separate the value and unit
    final dosageParts = widget.medication.dosage.split(' ');
    if (dosageParts.length > 1) {
      _dosageController = TextEditingController(text: dosageParts[0]);
      // Check if the unit is in the _unitOptions list
      _selectedUnit = _unitOptions.contains(dosageParts[1])
          ? dosageParts[1]
          : 'N/A'; // Fallback to 'N/A' if the unit is unknown
    } else {
      _dosageController = TextEditingController(text: widget.medication.dosage);
      _selectedUnit = 'N/A'; // Default to "N/A" if no unit is present
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
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

  void _saveMedication(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final String dosage = _dosageController.text.trim().isEmpty
          ? ''
          : '${_dosageController.text} ${_selectedUnit == 'N/A' ? '' : _selectedUnit ?? ''}';
      final String additionalInfo = _additionalInfoController.text;
      final String imageUrl =
          Provider.of<MedicationProvider>(context, listen: false)
              .medications
              .firstWhere((medication) => medication.id == widget.medication.id)
              .imageUrl;

      Medication updatedMedication = Medication(
        id: widget.medication.id,
        name: name,
        dosage: dosage,
        additionalInfo: additionalInfo,
        imageUrl: imageUrl,
        profileId: widget.medication.profileId,
      );

      try {
        await Provider.of<MedicationProvider>(context, listen: false)
            .updateMedication(updatedMedication);

        if (!context.mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update medication: $e')),
        );
      }
    }
  }

  void _handleTakePhoto() async {
    final imagePickerService =
        Provider.of<ImageService>(context, listen: false);
    try {
      String imageFileName = await imagePickerService.takePhoto();
      // Check if the widget is still mounted before using the context
      if (!mounted) return;

      _updateMedicationImage(imageFileName);
    } catch (e) {
      // Check if the widget is still mounted before using the context
      if (!mounted) return;

      _showErrorSnackbar(context, e.toString());
    }
  }

  void _handleUploadFromGallery() async {
    final imagePickerService =
        Provider.of<ImageService>(context, listen: false);
    try {
      String imageFileName = await imagePickerService.pickFromGallery();
      // Check if the widget is still mounted before using the context
      if (!mounted) return;

      _updateMedicationImage(imageFileName);
    } catch (e) {
      // Check if the widget is still mounted before using the context
      if (!mounted) return;

      _showErrorSnackbar(context, e.toString());
    }
  }

  void _updateMedicationImage(String imageFileName) {
    Medication updatedMedication =
        widget.medication.copyWith(imageUrl: imageFileName);
    Provider.of<MedicationProvider>(context, listen: false)
        .updateMedication(updatedMedication);
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasImage = Provider.of<MedicationProvider>(context)
        .medications
        .firstWhere((medication) => medication.id == widget.medication.id)
        .imageUrl
        .isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Header(
              title: 'Edit Medication',
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
                                  decoration:
                                      _inputDecoration('Dosage (optional)'),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      final number = double.tryParse(value);
                                      if (number == null) {
                                        return 'Please enter a valid number';
                                      }
                                    }
                                    return null;
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
                            maxLines: null,
                          ),
                          if (hasImage) ...[
                            const SizedBox(height: 16),
                            Consumer<MedicationProvider>(
                              builder: (context, provider, child) {
                                Medication updatedMedication = provider
                                    .medications
                                    .firstWhere((medication) =>
                                        medication.id == widget.medication.id);
                                return FutureBuilder<String>(
                                  future: Provider.of<LocalStorageService>(
                                          context,
                                          listen: false)
                                      .getFilePath(updatedMedication.imageUrl),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: ZoomableImage(
                                            imagePath: snapshot.data!),
                                      );
                                    }
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  },
                                );
                              },
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
                            title: "Update Medication",
                            onTap: () => _saveMedication(context),
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
