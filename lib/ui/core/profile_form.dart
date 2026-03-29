import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:medication_tracker/ui/core/primary_button.dart';
import 'package:medication_tracker/ui/core/privacy_policy_button.dart';

class ProfileForm extends StatefulWidget {
  final String initialName;
  final String initialDob;
  final String initialPcp;
  final String initialPharmacy;
  final String initialHealthConditions;
  final String submitLabel;
  /// If false, the submit button is omitted from the form body.
  /// Use [GlobalKey<ProfileFormState>] + [ProfileFormState.submit()] to
  /// trigger submission from outside (e.g. a FAB).
  final bool showSubmitButton;
  final void Function(String name, String dob, String pcp, String pharmacy, String healthConditions) onSave;

  const ProfileForm({
    super.key,
    required this.initialName,
    required this.initialDob,
    required this.initialPcp,
    required this.initialPharmacy,
    required this.initialHealthConditions,
    required this.submitLabel,
    required this.onSave,
    this.showSubmitButton = true,
  });

  @override
  ProfileFormState createState() => ProfileFormState();
}

// Public so callers can use GlobalKey<ProfileFormState> to call submit().
class ProfileFormState extends State<ProfileForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _pcpController;
  late TextEditingController _pharmacyController;
  late TextEditingController _healthConditionsController;

  final MaskTextInputFormatter _phoneNumberFormatter = MaskTextInputFormatter(
      mask: '(###) ###-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _dobController = TextEditingController(text: widget.initialDob);
    _pcpController = TextEditingController(text: widget.initialPcp);
    _pharmacyController = TextEditingController(text: widget.initialPharmacy);
    _healthConditionsController = TextEditingController(text: widget.initialHealthConditions);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _pcpController.dispose();
    _pharmacyController.dispose();
    _healthConditionsController.dispose();
    super.dispose();
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

  /// Public — call from a FAB via GlobalKey<ProfileFormState>.
  void submit() {
    if (_formKey.currentState!.validate() && _dobController.text.isNotEmpty && _nameController.text.isNotEmpty) {
      widget.onSave(
        _nameController.text,
        _dobController.text,
        _pcpController.text,
        _pharmacyController.text,
        _healthConditionsController.text,
      );
    }
  }

  InputDecoration _inputDecoration(String label, BuildContext context) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.secondaryContainer,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Personal Information',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Name', context),
              keyboardType: TextInputType.name,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Name is required';
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _dobController,
              decoration: _inputDecoration('Date of Birth', context),
              onTap: () => _selectDate(context),
              readOnly: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Date of Birth is required';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Health Information',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pcpController,
              decoration: _inputDecoration('Primary Care Physician (optional)', context),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _pharmacyController,
              decoration: _inputDecoration('Pharmacy Phone (optional)', context),
              keyboardType: TextInputType.phone,
              inputFormatters: [_phoneNumberFormatter],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _healthConditionsController,
              decoration: _inputDecoration('Health Conditions (optional)', context),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
            const SizedBox(height: 24),
            const PrivacyPolicyButton(),
            if (widget.showSubmitButton) ...[
              const SizedBox(height: 8),
              PrimaryButton(
                title: widget.submitLabel,
                onTap: submit,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
