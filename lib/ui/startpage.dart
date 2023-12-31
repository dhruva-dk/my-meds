import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _pcpController = TextEditingController();
  final TextEditingController _healthConditionsController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Welcome!',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                    'To continue, please fill in the following information',
                    style: TextStyle(fontSize: 18)),
              ),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
              ),
              TextFormField(
                controller: _dobController,
                decoration: _inputDecoration('Date of Birth'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your date of birth' : null,
                onTap: () => _selectDate(context),
              ),
              TextFormField(
                controller: _pcpController,
                decoration:
                    _inputDecoration('Primary Care Physician (optional)'),
              ),
              TextFormField(
                controller: _healthConditionsController,
                decoration: _inputDecoration('Health Conditions (optional)'),
                keyboardType: TextInputType.multiline,
                maxLines: 4,
              ),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                    minimumSize: Size(double.infinity, 50)),
                onPressed: _submitForm,
                child: Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.black, width: 2)),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Handle form submission
    }
  }
}
