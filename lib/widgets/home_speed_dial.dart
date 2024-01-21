import 'package:flutter/material.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:medication_tracker/export/pdf_save_service.dart';
import 'package:medication_tracker/export/pdf_share_service.dart';
import 'package:medication_tracker/providers/medication_provider.dart';
import 'package:medication_tracker/ui/fda_search_view.dart';
import 'package:provider/provider.dart';

class HomeSpeedDial extends StatelessWidget {
  // add key construct
  HomeSpeedDial({Key? key}) : super(key: key);
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
    return SpeedDial(
      // Provide an icon to display in the FAB
      icon: Icons.medication,
      activeIcon: Icons.close,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white, // it's the FloatingActionButton size
      visible: true,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.2,
      tooltip: 'Speed Dial',
      heroTag: 'speed-dial-hero-tag',
      elevation: 8.0,
      spacing: 15,
      shape: const CircleBorder(),
      children: [
        SpeedDialChild(
          child: const Icon(Icons.add),
          shape: const CircleBorder(),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          label: 'Add Medication',
          labelStyle: const TextStyle(fontSize: 18.0, fontFamily: 'OpenSans'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FDASearchPage()),
          ),
        ),
        SpeedDialChild(
          child: const Icon(Icons.share),
          shape: const CircleBorder(),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          label: 'Export as PDF',
          labelStyle: const TextStyle(fontSize: 18.0, fontFamily: 'OpenSans'),
          onTap: () {
            // Implement your export logic
            //print('Export');
            _shareMedications(context);
          },
        ),
      ],
    );
  }
}
