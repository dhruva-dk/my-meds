import 'package:flutter/material.dart';

import 'package:medication_tracker/utils/image_ui_handler.dart';

import 'package:medication_tracker/data/repositories/fda_api_repository.dart';

import 'package:medication_tracker/ui/create_medication/create_medication_view.dart';
import 'package:medication_tracker/ui/core/ui/black_button.dart';
import 'package:medication_tracker/ui/core/ui/photo_upload_row.dart';
import 'package:provider/provider.dart';
import 'package:medication_tracker/ui/search/search_tile.dart';
//permission handler

//import async
import 'dart:async';

class FDASearchPage extends StatefulWidget {
  const FDASearchPage({super.key});

  @override
  _FDASearchPageState createState() => _FDASearchPageState();
}

class _FDASearchPageState extends State<FDASearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.length >= 3 && context.mounted) {
        Provider.of<FDAAPIServiceProvider>(context, listen: false)
            .searchMedications(_searchController.text.toLowerCase());
      }
    });
  }

  //methods for the image save:
  void _handleTakePhoto() async {
    await ImageService.handleTakePhoto(
      context,
    );
  }

  void _handleUploadFromGallery() async {
    await ImageService.handlePickFromGallery(context);
  }

  //ui build code

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FDA Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              // ... text field decoration ...
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            BlackButton(
                title: "Manual Input",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateMedicationPage()),
                  );
                }),
            const SizedBox(
              height: 8,
            ),
            PhotoUploadRow(
              onTakePhoto: _handleTakePhoto,
              onUploadPhoto: _handleUploadFromGallery,
              hasImage: false,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<FDAAPIServiceProvider>(
                builder: (context, provider, child) {
                  try {
                    if (provider.errorMessage.isNotEmpty) {
                      return Center(child: Text(provider.errorMessage));
                    }
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                      itemCount: provider.searchResults.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CreateMedicationPage(
                                        initialDrug:
                                            provider.searchResults[index])),
                              );
                            },
                            child: SearchTile(
                                drug: provider.searchResults[index]));
                      },
                    );
                  } catch (e) {
                    return Center(child: Text('Error: $e'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
