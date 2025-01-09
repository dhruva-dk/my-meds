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
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28), // Reduced bottom padding
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black, // iOS style background
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _navItem(
                icon: Icons.account_circle,
                label: 'Profile',
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
                label: 'Export',
                onTap: () {
                  _shareMedications(context);
                },
              ),
              _navItem(
                icon: Icons.switch_account,
                label: 'Switch',
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
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            color: Colors.white, // iOS blue color
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white, // iOS blue color
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
