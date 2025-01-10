import 'package:flutter/material.dart';
import 'package:medication_tracker/data/providers/fda_api_provider.dart';
import 'package:medication_tracker/services/image/image_service.dart';
import 'package:medication_tracker/ui/core/primary_button.dart';
import 'package:medication_tracker/ui/create_medication/create_medication_view.dart';
import 'package:medication_tracker/ui/core/header.dart';
import 'package:medication_tracker/ui/core/photo_upload_button.dart';
import 'package:provider/provider.dart';
import 'package:medication_tracker/ui/search/search_tile.dart';
import 'dart:async';

class FDASearchPage extends StatefulWidget {
  const FDASearchPage({super.key});

  @override
  State<FDASearchPage> createState() => _FDASearchPageState();
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

  void _handleTakePhoto() async {
    final imagePickerService =
        Provider.of<ImageService>(context, listen: false);
    try {
      String imageFileName = await imagePickerService.takePhoto();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateMedicationPage(
            imageFileName: imageFileName,
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackbar(context, e.toString());
    }
  }

  void _handleUploadFromGallery() async {
    final imagePickerService =
        Provider.of<ImageService>(context, listen: false);
    try {
      String imageFileName = await imagePickerService.pickFromGallery();
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateMedicationPage(
            imageFileName: imageFileName,
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackbar(context, e.toString());
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 80),
        child: Header(
          title: 'Add Medication',
          showBackButton: Navigator.canPop(context),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: theme.colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align text to the left
                    children: [
                      // Subheading above the search box and buttons
                      Text(
                        'FDA Search',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(
                          height: 16), // Spacing below the subheading

                      // Search Box
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white, // Set background to white
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                          height: 16), // Spacing below the search box

                      // Buttons Row
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              title: "Manual Input",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CreateMedicationPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8), // Spacing between buttons
                          Expanded(
                            child: PhotoUploadButton(
                              onTakePhoto: _handleTakePhoto,
                              onUploadPhoto: _handleUploadFromGallery,
                              hasImage: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32), // Spacing below the buttons

                      // Subheading below the buttons
                      Text(
                        'Search Results',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8), // Spacing below the subheading

                      // Search Results List
                      Expanded(
                        child: Consumer<FDAAPIServiceProvider>(
                          builder: (context, provider, child) {
                            try {
                              if (provider.errorMessage.isNotEmpty) {
                                return Center(
                                    child: Text(provider.errorMessage));
                              }
                              if (provider.isLoading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              return ListView.builder(
                                itemCount: provider.searchResults.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CreateMedicationPage(
                                            initialDrug:
                                                provider.searchResults[index],
                                          ),
                                        ),
                                      );
                                    },
                                    child: SearchTile(
                                        drug: provider.searchResults[index]),
                                  );
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
