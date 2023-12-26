import 'package:flutter/material.dart';
import 'package:medication_tracker/providers/fda_api_provider.dart';
import 'package:provider/provider.dart';
import 'package:medication_tracker/widgets/search_tile.dart';

//import async
import 'dart:async';

class FDASearchPage extends StatefulWidget {
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
      if (_searchController.text.length >= 5) {
        Provider.of<FDAAPIServiceProvider>(context, listen: false)
            .searchMedications(_searchController.text.toLowerCase());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FDA Search'),
        backgroundColor: Colors.grey[200],
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              // ... text field decoration ...
              decoration: InputDecoration(
                hintText: 'Search (min 5 characters))',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),
            SizedBox(height: 8),

            //button to skip to manual entry
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black, // Button color
                onPrimary: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24), // Rounded corners
                ),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                minimumSize:
                    Size(double.infinity, 45), // Maximum width and fixed height
              ),
              onPressed: () {
                // Add your onPressed code here!
              },
              child: Text(
                'Manual Input',
                style: TextStyle(fontSize: 14),
              ),
            ),

            SizedBox(height: 16),

            Expanded(
              child: Consumer<FDAAPIServiceProvider>(
                builder: (context, provider, child) {
                  try {
                    if (provider.searchResults.isEmpty) {
                      return Center(child: Text('No results'));
                    }
                    if (provider.errorMessage.isNotEmpty) {
                      return Center(child: Text(provider.errorMessage));
                    }
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                      itemCount: provider.searchResults.length,
                      itemBuilder: (context, index) {
                        return SearchTile(drug: provider.searchResults[index]);
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











/*import 'package:flutter/material.dart';

class FDASearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FDA Search'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Add additional functionality here
          ],
        ),
      ),
    );
  }
}*/
