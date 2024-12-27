import 'package:flutter/material.dart';
import 'package:medication_tracker/providers/profile_provider.dart';
import 'package:medication_tracker/ui/create_profile_view.dart';
import 'package:medication_tracker/ui/home_view.dart';
import 'package:provider/provider.dart';

class SelectProfilePage extends StatelessWidget {
  const SelectProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Profile'),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          return ListView.builder(
            itemCount: profileProvider.profiles.length,
            itemBuilder: (context, index) {
              final profile = profileProvider.profiles[index];
              return ListTile(
                title: Text(profile.name),
                subtitle: Text('DOB: ${profile.dob}'),
                onTap: () {
                  profileProvider.selectProfile(profile.id!);
                  print(
                      'Selected profile: ${profile.name}, selectedProfileId: ${profile.id}');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateProfilePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
