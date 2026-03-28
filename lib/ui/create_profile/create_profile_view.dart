import 'package:flutter/material.dart';
import 'package:medication_tracker/data/model/user_profile_model.dart';
import 'package:medication_tracker/data/providers/profile_provider.dart';
import 'package:medication_tracker/ui/core/header.dart';
import 'package:medication_tracker/ui/core/profile_form.dart';
import 'package:medication_tracker/ui/select_profile/select_profile_view.dart';
import 'package:provider/provider.dart';

class CreateProfilePage extends StatelessWidget {
  const CreateProfilePage({super.key});

  void _submitForm(BuildContext context, String name, String dob, String pcp, String pharmacy, String healthConditions) async {
    try {
      UserProfile profile = UserProfile(
        name: name,
        dob: dob,
        pcp: pcp,
        healthConditions: healthConditions,
        pharmacy: pharmacy,
      );

      await Provider.of<ProfileProvider>(context, listen: false).addProfile(profile);

      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SelectProfilePage()),
      );
    } catch (e) {
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 80),
        child: Header(
          title: 'Add Profile',
          showBackButton: Navigator.canPop(context),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: theme.colorScheme.surface,
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
            ),
          ],
        ),
      ),
    );
  }
}
