import 'package:flutter/material.dart';
import 'package:medication_tracker/data/model/user_profile_model.dart';
import 'package:medication_tracker/data/providers/profile_provider.dart';
import 'package:medication_tracker/ui/core/header.dart';
import 'package:medication_tracker/ui/core/no_profile_view.dart';
import 'package:medication_tracker/ui/core/profile_form.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<ProfileFormState> _profileFormKey = GlobalKey<ProfileFormState>();

  void _saveProfile(BuildContext context, String name, String dob, String pcp,
      String pharmacy, String healthConditions) async {
    final currentProfile =
        Provider.of<ProfileProvider>(context, listen: false).selectedProfile;
    if (currentProfile?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No profile selected to update')));
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
      await Provider.of<ProfileProvider>(context, listen: false)
          .updateProfile(profile);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile successfully updated')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.selectedProfile;

        if (profile == null) {
          return const NoProfileView(
            title: 'Your Profile',
            header: Header(
              title: 'Your Profile',
              showBackButton: false,
            ),
          );
        }

        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: const PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight + 80),
            child: Header(
              title: 'Your Profile',
              showBackButton: false,
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: ProfileForm(
                key: _profileFormKey,
                initialName: profile.name,
                initialDob: profile.dob,
                initialPcp: profile.pcp,
                initialPharmacy: profile.pharmacy,
                initialHealthConditions: profile.healthConditions,
                submitLabel: 'Save Profile',
                showSubmitButton: false,
                onSave: (name, dob, pcp, pharmacy, healthConditions) {
                  _saveProfile(context, name, dob, pcp, pharmacy, healthConditions);
                },
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _profileFormKey.currentState?.submit(),
            backgroundColor: theme.colorScheme.primary,
            elevation: 2,
            shape: const StadiumBorder(),
            label: Text(
              'Save Profile',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
            icon: Icon(Icons.save, color: theme.colorScheme.onPrimary),
          ),
        );
      },
    );
  }
}
