import 'package:flutter/material.dart';
import 'package:medication_tracker/providers/fda_api_provider.dart';
import 'package:medication_tracker/providers/medication_provider.dart';
import 'package:medication_tracker/providers/profile_provider.dart';
import 'package:medication_tracker/ui/homeview.dart'; // Import your StartPage
import 'package:medication_tracker/ui/startpage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstLaunch = prefs.getBool('first_launch') ?? true;
  prefs.setBool('first_launch', true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MedicationProvider()),
        ChangeNotifierProvider(create: (context) => FDAAPIServiceProvider()),
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
      ],
      child: MyApp(isFirstLaunch: isFirstLaunch),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;
  const MyApp({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        //... theme data ...
        colorScheme: ColorScheme.light(
          primary: Colors.black, // Color of the header and selected items
          onPrimary: Colors.white, // Color of text and icons on the header
          surface: Colors.white, // Background color of the picker
          onSurface: Colors.black, // Color of text and icons on the picker
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[200], // Default background color
        appBarTheme: AppBarTheme(
          color: Colors.grey[200], // AppBar background color
          iconTheme: IconThemeData(color: Colors.black), // AppBar icon color
          titleTextStyle: TextStyle(
              color: Colors.black, fontSize: 20), // AppBar title text style
        ),
        // Setting the popup menu theme
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.black, // Default popup menu background color
          textStyle:
              TextStyle(color: Colors.white), // Text color for popup menu items
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.white,
        ),
      ),
      home: isFirstLaunch ? StartPage() : const HomeScreen(),
    );
  }
}
