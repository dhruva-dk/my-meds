import 'dart:io';
import 'package:medication_tracker/data/model/medication_model.dart';
import 'package:medication_tracker/services/storage/local_storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class PDFService {
  Future<void> shareMedications(List<Medication> medications) async {
    try {
      final filePath = await _generatePDF(medications);
      final file = XFile(filePath);
      final result =
          await Share.shareXFiles([file], text: "Medication List PDF");

      if (result.status == ShareResultStatus.dismissed) {
        throw Exception('PDF sharing was cancelled');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> _generatePDF(List<Medication> medications) async {
    final pdf = pw.Document();
    final images = await _loadImages(medications);

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          for (int i = 0; i < medications.length; i++) ...[
            _buildMedicationSection(medications[i], images[i]),
            pw.Divider(),
          ],
        ],
      ),
    );

    return await _savePDF(pdf);
  }

  pw.Widget _buildMedicationSection(
      Medication medication, pw.ImageProvider? image) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          "Name: ${medication.name.isNotEmpty ? medication.name : 'N/A'}",
          style: const pw.TextStyle(fontSize: 18),
        ),
        pw.Text(
          "Dosage: ${medication.dosage.isNotEmpty ? medication.dosage : 'N/A'}",
          style: const pw.TextStyle(fontSize: 18),
        ),
        pw.Text(
          "Additional Info: ${medication.additionalInfo.isNotEmpty ? medication.additionalInfo : 'N/A'}",
          style: const pw.TextStyle(fontSize: 18),
        ),
        if (medication.imageUrl.isNotEmpty && image != null)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 20),
            child: pw.Image(image, height: 300, width: 300),
          ),
      ],
    );
  }

  Future<List<pw.ImageProvider?>> _loadImages(
      List<Medication> medications) async {
    final directory = await getApplicationDocumentsDirectory();
    return Future.wait(medications.map((medication) async {
      if (medication.imageUrl.isNotEmpty) {
        try {
          final imagePath = '${directory.path}/${medication.imageUrl}';
          final image = await File(imagePath).readAsBytes();
          return pw.MemoryImage(image);
        } catch (e) {
          rethrow;
        }
      }
      return null;
    }));
  }

  Future<String> _savePDF(pw.Document pdf) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/medications.pdf';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());
      return path;
    } catch (e) {
      throw Exception('Failed to save PDF: ${e.toString()}');
    }
  }
}
