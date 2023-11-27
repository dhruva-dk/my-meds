import 'package:flutter/material.dart';

import 'dart:convert';

class TestStoragePage extends StatefulWidget {
  const TestStoragePage({super.key});

  @override
  _TestStoragePageState createState() => _TestStoragePageState();
}

class _TestStoragePageState extends State<TestStoragePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _additionalInfoController =
      TextEditingController();

  void _cancel() {
    //navigate back to home screen on same route
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Local Storage')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Medication Name')),
            TextField(
                controller: _dosageController,
                decoration: InputDecoration(labelText: 'Dosage')),
            TextField(
                controller: _additionalInfoController,
                decoration: InputDecoration(labelText: 'Additional Info')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: Text('Accept')),
            TextButton(onPressed: _cancel, child: Text('Cancel')),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: TestStoragePage()));
