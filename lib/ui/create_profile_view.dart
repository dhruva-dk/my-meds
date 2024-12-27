import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medication_tracker/data/model/user_profile_model.dart';
import 'package:medication_tracker/data/providers/profile_provider.dart';
import 'package:medication_tracker/ui/home_view.dart';
import 'package:medication_tracker/ui/core/black_button.dart';
import 'package:medication_tracker/widgets/header.dart';
import 'package:medication_tracker/widgets/privacy_policy_button.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({super.key});

  @override
  _CreateProfilePageState createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _pcpController = TextEditingController();
  final TextEditingController _healthConditionsController =
      TextEditingController();
  final TextEditingController _pharmacyController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final MaskTextInputFormatter _phoneNumberFormatter = MaskTextInputFormatter(
      mask: '(###) ###-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(
              title: 'Create Profile',
              showBackButton: Navigator.canPop(context),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration('Name (optional)'),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _dobController,
                            decoration:
                                _inputDecoration('Date of Birth (optional)'),
                            onTap: () => _selectDate(context),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _pcpController,
                            decoration: _inputDecoration(
                                'Primary Care Physician (optional)'),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _pharmacyController,
                            decoration:
                                _inputDecoration('Pharmacy Phone (optional)'),
                            inputFormatters: [_phoneNumberFormatter],
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _healthConditionsController,
                            decoration: _inputDecoration(
                                'Health Conditions (optional)'),
                            keyboardType: TextInputType.multiline,
                            minLines: 3,
                            maxLines: 6,
                          ),
                          const SizedBox(height: 16),
                          const PrivacyPolicyButton(),
                          const SizedBox(height: 8),
                          BlackButton(
                              title: "Continue", onTap: () => _submitForm()),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.black, width: 2)),
    );
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

  void _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _dobController.text.isNotEmpty &&
        _nameController.text.isNotEmpty) {
      UserProfile profile = UserProfile(
        name: _nameController.text,
        dob: _dobController.text,
        pcp: _pcpController.text,
        healthConditions: _healthConditionsController.text,
        pharmacy: _pharmacyController.text,
      );

      Provider.of<ProfileProvider>(context, listen: false).addProfile(profile);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }
}
