import 'package:flutter/material.dart';
import 'package:medication_tracker/data/providers/profile_provider.dart';
import 'package:medication_tracker/ui/create_profile/create_profile_view.dart';
import 'package:medication_tracker/ui/core/header.dart';
import 'package:provider/provider.dart';

class SelectProfilePage extends StatelessWidget {
  /// Called after a profile is selected. When embedded in the tab shell,
  /// this switches to the Home tab. When null, the page pops instead.
  final VoidCallback? onProfileSelected;

  const SelectProfilePage({super.key, this.onProfileSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 80),
        child: Header(
          title: 'Select Profile',
          showBackButton: Navigator.canPop(context),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                color: theme.colorScheme.surface,
                child: Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    if (profileProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
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
                            "No profiles yet. Tap Add Profile below to get started.",
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
                            vertical: 4,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: InkWell(
                            onTap: () async {
                              try {
                                await profileProvider.selectProfile(profile.id!);
                                if (!context.mounted) return;
                                if (onProfileSelected != null) {
                                  onProfileSelected!();
                                } else {
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Failed to select profile: $e'),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 32,
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.name,
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme
                                              .colorScheme.onSecondaryContainer,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.cake,
                                            size: 16,
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              profile.dob,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (String result) async {
                                    if (result == 'delete') {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog.adaptive(
                                            title:
                                                const Text('Delete Profile'),
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
                                                                .onPrimary,
                                                          ),
                                                        ),
                                                        backgroundColor: theme
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                    );
                                                  } catch (e) {
                                                    if (!context.mounted) return;
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'Failed to delete profile: $e'),
                                                      ),
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
                                          Icon(
                                            Icons.delete,
                                            color: theme.colorScheme.error,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Delete',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateProfilePage(),
            ),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        elevation: 2,
        shape: const StadiumBorder(),
        label: Text(
          'Add Profile',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        icon: Icon(Icons.person_add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}
