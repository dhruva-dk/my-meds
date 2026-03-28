import 'package:flutter/material.dart';
import 'package:medication_tracker/services/image/image_service.dart';
import 'package:medication_tracker/services/storage/local_storage_service.dart';
import 'package:medication_tracker/ui/core/primary_button.dart';
import 'package:medication_tracker/ui/core/photo_upload_button.dart';
import 'package:medication_tracker/ui/edit_medication/zoomable_image.dart';
import 'package:provider/provider.dart';

class MedicationForm extends StatefulWidget {
  final String initialName;
  final String initialDosage;
  final String initialUnit;
  final String initialAdditionalInfo;
  final String initialImageFileName;
  final String submitLabel;
  final void Function(String name, String dosage, String unit, String additionalInfo, String imageFileName) onSave;

  const MedicationForm({
    Key? key,
    required this.initialName,
    required this.initialDosage,
    required this.initialUnit,
    required this.initialAdditionalInfo,
    required this.initialImageFileName,
    required this.submitLabel,
    required this.onSave,
  }) : super(key: key);

  @override
  State<MedicationForm> createState() => _MedicationFormState();
}

class _MedicationFormState extends State<MedicationForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _additionalInfoController;
  String _imageFileName = '';
  String? _selectedUnit;

  final List<String> _unitOptions = ['N/A', 'mg', 'mL', 'g', 'mcg', 'IU', '%'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _dosageController = TextEditingController(text: widget.initialDosage);
    _additionalInfoController = TextEditingController(text: widget.initialAdditionalInfo);
    _selectedUnit = _unitOptions.contains(widget.initialUnit) ? widget.initialUnit : 'N/A';
    _imageFileName = widget.initialImageFileName;
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
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.secondaryContainer,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
    );
  }

  void _handleTakePhoto() async {
    final imagePickerService = Provider.of<ImageService>(context, listen: false);
    try {
      String imageFileName = await imagePickerService.takePhoto();
      if (!mounted) return;
      setState(() => _imageFileName = imageFileName);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _handleUploadFromGallery() async {
    final imagePickerService = Provider.of<ImageService>(context, listen: false);
    try {
      String imageFileName = await imagePickerService.pickFromGallery();
      if (!mounted) return;
      setState(() => _imageFileName = imageFileName);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        _nameController.text,
        _dosageController.text.trim(),
        _selectedUnit ?? 'N/A',
        _additionalInfoController.text,
        _imageFileName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool hasImage = _imageFileName.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Medication Details',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a medication name';
                  }
                  return null;
                },
                maxLines: null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _dosageController,
                      decoration: _inputDecoration('Dosage (optional)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (double.tryParse(value) == null) {
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
                        setState(() => _selectedUnit = newValue);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _additionalInfoController,
                decoration: _inputDecoration('Additional Info (optional)'),
                maxLines: null,
              ),
              const SizedBox(height: 24),
              if (hasImage) ...[
                Text(
                  'Medication Image',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<String>(
                  future: Provider.of<LocalStorageService>(context, listen: false).getFilePath(_imageFileName),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: ZoomableImage(imagePath: snapshot.data!),
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                const SizedBox(height: 16),
              ],
              PhotoUploadButton(
                onTakePhoto: _handleTakePhoto,
                onUploadPhoto: _handleUploadFromGallery,
                hasImage: hasImage,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                title: widget.submitLabel,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
