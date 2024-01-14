import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medication_tracker/model/user_profile.dart';
import 'package:medication_tracker/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _pcpController = TextEditingController();
  final TextEditingController _healthConditionsController =
      TextEditingController();
  final TextEditingController _pharmacyController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final profile = profileProvider.userProfile;
    if (profile != null) {
      _nameController.text = profile.name;
      _dobController.text = profile.dob;
      _pcpController.text = profile.pcp;
      _healthConditionsController.text = profile.healthConditions;
      _pharmacyController.text = profile.pharmacy;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final profile = UserProfile(
        name: _nameController.text,
        dob: _dobController.text,
        pcp: _pcpController.text,
        healthConditions: _healthConditionsController.text,
        pharmacy: _pharmacyController.text,
      );
      Provider.of<ProfileProvider>(context, listen: false).saveProfile(profile);
      // Navigate back or show a success message
      // show snack bar: profile updated

      // Show a Snackbar indicating profile successfully updated
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile successfully updated'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _dobController,
                  decoration: _inputDecoration('Date of Birth'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your date of birth' : null,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _pcpController,
                  decoration: _inputDecoration(
                      'Primary Care Physician / Phone number (optional)'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _pharmacyController,
                  decoration:
                      _inputDecoration('Pharmacy / Phone number (optional)'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _healthConditionsController,
                  decoration: _inputDecoration('Health Conditions (optional)'),
                  keyboardType: TextInputType.multiline,
                  maxLines: 6,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _saveProfile,
                  child: const Text('Save Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
}
