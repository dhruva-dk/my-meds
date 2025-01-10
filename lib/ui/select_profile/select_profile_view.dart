import 'package:flutter/material.dart';
import 'package:medication_tracker/data/providers/profile_provider.dart';
import 'package:medication_tracker/ui/create_profile/create_profile_view.dart';
import 'package:medication_tracker/ui/home/home_view.dart';
import 'package:medication_tracker/ui/core/primary_button.dart';
import 'package:medication_tracker/ui/core/header.dart';
import 'package:provider/provider.dart';

class SelectProfilePage extends StatelessWidget {
  const SelectProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(
              title: 'Select Profile',
              showBackButton: Navigator.canPop(context),
            ),
            Expanded(
              child: Container(
                color: theme.colorScheme.surface,
                child: Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    if (profileProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (profileProvider.errorMessage.isNotEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            profileProvider.errorMessage,
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    }

                    if (profileProvider.profiles.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "No profiles added yet. Add your first profile by pressing the button below.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: profileProvider.profiles.length,
                      itemBuilder: (context, index) {
                        final profile = profileProvider.profiles[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            onTap: () async {
                              try {
                                await profileProvider
                                    .selectProfile(profile.id!);
                                if (!context.mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                    'Failed to select profile: $e',
                                  )),
                                );
                              }
                            },
                            child: Row(
                              children: [
                                // Profile Icon
                                Icon(Icons.person,
                                    size: 32,
                                    color:
                                        theme.colorScheme.onSecondaryContainer),
                                const SizedBox(width: 16),

                                // Profile Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Profile Name
                                      Text(
                                        profile.name,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),

                                      // Date of Birth
                                      Row(
                                        children: [
                                          Icon(Icons.cake,
                                              size: 16,
                                              color:
                                                  theme.colorScheme.onSurface),
                                          const SizedBox(width: 8),
                                          Text(
                                            profile.dob,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Menu Button
                                PopupMenuButton<String>(
                                  onSelected: (String result) async {
                                    if (result == 'delete') {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog.adaptive(
                                            title: const Text('Delete Profile'),
                                            content: const Text(
                                                'Are you sure you want to delete this profile? This action cannot be undone.'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('Cancel'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: const Text('Delete'),
                                                onPressed: () async {
                                                  Navigator.of(context).pop();
                                                  try {
                                                    await profileProvider
                                                        .deleteProfile(
                                                            profile.id!);
                                                    if (!context.mounted) {
                                                      return;
                                                    }
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Profile deleted successfully.',
                                                          style: TextStyle(
                                                              color: theme
                                                                  .colorScheme
                                                                  .onPrimary),
                                                        ),
                                                        backgroundColor: theme
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                    );
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                        'Failed to delete profile: $e',
                                                      )),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  itemBuilder: (BuildContext context) => [
                                    PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete,
                                              color: theme.colorScheme.error,
                                              size: 20),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Delete',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: PrimaryButton(
          title: "Add Profile",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateProfilePage(),
              ),
            );
          },
        ),
      ),
    );
  }
}
