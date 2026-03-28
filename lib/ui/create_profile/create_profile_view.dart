import 'package:flutter/material.dart';
import 'package:medication_tracker/data/model/user_profile_model.dart';
import 'package:medication_tracker/data/providers/profile_provider.dart';
import 'package:medication_tracker/ui/core/header.dart';
import 'package:medication_tracker/ui/core/profile_form.dart';
import 'package:provider/provider.dart';

class CreateProfilePage extends StatelessWidget {
  const CreateProfilePage({super.key});

  void _submitForm(BuildContext context, String name, String dob, String pcp,
      String pharmacy, String healthConditions) async {
    try {
      UserProfile profile = UserProfile(
        name: name,
        dob: dob,
        pcp: pcp,
        healthConditions: healthConditions,
        pharmacy: pharmacy,
      );

      await Provider.of<ProfileProvider>(context, listen: false)
          .addProfile(profile);

      if (!context.mounted) return;
      // Pop back to the Switch tab in the shell (or wherever we were pushed from).
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 80),
        child: Header(
          title: 'Add Profile',
          showBackButton: true,
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: ProfileForm(
            initialName: '',
            initialDob: '',
            initialPcp: '',
            initialPharmacy: '',
            initialHealthConditions: '',
            submitLabel: 'Continue',
            onSave: (name, dob, pcp, pharmacy, healthConditions) {
              _submitForm(context, name, dob, pcp, pharmacy, healthConditions);
            },
          ),
        ),
      ),
    );
  }
}
