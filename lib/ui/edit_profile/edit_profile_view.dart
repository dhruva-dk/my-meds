import 'package:flutter/material.dart';
import 'package:medication_tracker/data/model/user_profile_model.dart';
import 'package:medication_tracker/data/providers/profile_provider.dart';
import 'package:medication_tracker/ui/core/header.dart';
import 'package:medication_tracker/ui/core/profile_form.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  void _saveProfile(BuildContext context, String name, String dob, String pcp, String pharmacy, String healthConditions) async {
    final currentProfile = Provider.of<ProfileProvider>(context, listen: false).selectedProfile;
    if (currentProfile?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: No profile selected to update')));
      return;
    }

    final profile = UserProfile(
      id: currentProfile!.id,
      name: name,
      dob: dob,
      pcp: pcp,
      healthConditions: healthConditions,
      pharmacy: pharmacy,
    );

    try {
      await Provider.of<ProfileProvider>(context, listen: false).updateProfile(profile);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile successfully updated')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final profile = profileProvider.selectedProfile;

    if (profile == null) {
      return const Scaffold(body: Center(child: Text('No profile selected.')));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 80),
        child: Header(
          title: 'Your Profile',
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
                    initialName: profile.name,
                    initialDob: profile.dob,
                    initialPcp: profile.pcp,
                    initialPharmacy: profile.pharmacy,
                    initialHealthConditions: profile.healthConditions,
                    submitLabel: 'Save Profile',
                    onSave: (name, dob, pcp, pharmacy, healthConditions) {
                      _saveProfile(context, name, dob, pcp, pharmacy, healthConditions);
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
