import 'package:flutter/material.dart';
import 'package:medication_tracker/data/model/fda_drug_model.dart';

class SearchTile extends StatelessWidget {
  final FDADrug drug;
  final VoidCallback? onTap;

  const SearchTile({super.key, required this.drug, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(128, 128, 128, 0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Brand Name
            Text(
              drug.brandName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),

            // Generic Name
            Text(
              drug.genericName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              maxLines: 2, // Limit to 2 lines
              overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
            ),
            const SizedBox(height: 8),

            // Dosage Form and NDC
            Row(
              children: [
                const Icon(Icons.medical_services,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  drug.dosageForm,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.confirmation_number,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'NDC: ${drug.ndc}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
