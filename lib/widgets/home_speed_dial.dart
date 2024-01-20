import 'package:flutter/material.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:medication_tracker/ui/fda_search_view.dart';

class HomeSpeedDial extends StatelessWidget {
  // add key construct
  const HomeSpeedDial({Key? key}) : super(key: key);

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
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
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
            print('Export');
          },
        ),
      ],
    );
  }
}
