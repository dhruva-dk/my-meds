import 'package:flutter/material.dart';
import 'package:medication_tracker/services/export/pdf_service.dart';
import 'package:medication_tracker/services/export/pdf_share_service.dart';
import 'package:medication_tracker/data/providers/medication_provider.dart';
import 'package:medication_tracker/ui/edit_profile_view.dart';
import 'package:provider/provider.dart';

class NavBar extends StatelessWidget {
  NavBar({super.key});
  final PDFShareService _pdfShareService = PDFShareService();

  void _shareMedications(BuildContext context) async {
    try {
      await _pdfShareService.shareMedicationsPDF(
          Provider.of<MedicationProvider>(context, listen: false).medications);

      // Show success message if no exception occurred
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medications PDF shared successfully!')),
      );
    } on PDFSaveException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${e.message}')),
      );
    } on PDFShareException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${e.message}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unknown error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.black,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _navItem(
            icon: Icons.account_circle,
            label: "Profile",
            onTap: () {
              //navigate to profile page
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EditProfilePage()),
              );
            },
          ),
          const SizedBox(width: 16), // Placeholder for FAB
          _navItem(
            icon: Icons.save,
            label: "Export PDF",
            onTap: () {
              // Implement Export functionality
              _shareMedications(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _navItem(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: Colors.white),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}
