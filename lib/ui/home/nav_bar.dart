import 'package:flutter/material.dart';
import 'package:medication_tracker/services/export/pdf_service.dart';
import 'package:medication_tracker/data/providers/medication_provider.dart';
import 'package:medication_tracker/ui/edit_profile/edit_profile_view.dart';
import 'package:medication_tracker/ui/select_profile/select_profile_view.dart'; // Import the SelectProfilePage
import 'package:provider/provider.dart';

class NavBar extends StatelessWidget {
  NavBar({super.key});

  void _shareMedications(BuildContext context) async {
    final pdfService = Provider.of<PDFService>(context, listen: false);
    final medications =
        Provider.of<MedicationProvider>(context, listen: false).medications;

    try {
      await pdfService.shareMedications(medications);

      // Show success message if no exception occurred
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medications PDF shared successfully!')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 40.0, top: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _navItem(
                icon: Icons.account_circle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditProfilePage()),
                  );
                },
              ),
              _navItem(
                icon: Icons.save,
                onTap: () {
                  _shareMedications(context);
                },
              ),
              _navItem(
                icon: Icons.switch_account,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SelectProfilePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: Colors.white),
        ],
      ),
    );
  }
}
