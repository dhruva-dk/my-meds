import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medication_tracker/database/objectbox.dart';
import 'package:medication_tracker/objectbox.g.dart';
import 'package:medication_tracker/services/medication_provider.dart';
import 'package:medication_tracker/views/homeview.dart';

void main() async {
  //initialzie with providerscope
  WidgetsFlutterBinding.ensureInitialized();
  await openStore();

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,

        // Setting the popup menu theme
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.black, // Default popup menu background color
          textStyle:
              TextStyle(color: Colors.white), // Text color for popup menu items
        ),
      ),
      home: HomeScreen(),
    );
  }
}
