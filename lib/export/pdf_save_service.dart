//file which generates pdf and returns file name in documents directory
import 'dart:io';
import 'package:medication_tracker/model/medication_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFSaveService {
  Future<String> exportPDF(List<Medication> medications) async {
    final pdf = pw.Document();
    final List<pw.ImageProvider?> images = await loadImages(medications);

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          for (int i = 0; i < medications.length; i++) ...[
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Text(medications[i].name.isNotEmpty
                      ? medications[i].name
                      : 'N/A'),
                ),
                pw.Expanded(
                  child: pw.Text(medications[i].dosage.isNotEmpty
                      ? medications[i].dosage
                      : 'N/A'),
                ),
                pw.Expanded(
                  child: pw.Text(medications[i].additionalInfo.isNotEmpty
                      ? medications[i].additionalInfo
                      : 'N/A'),
                ),
                if (medications[i].imageUrl.isNotEmpty &&
                    images[i] != null) ...[
                  pw.Image(images[i]!, height: 100, width: 100),
                ],
              ],
            ),
            pw.Divider(),
          ],
        ],
      ),
    );

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/medications.pdf';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());
      return path;
    } catch (e) {
      throw PDFSaveException('Error generating PDF: $e');
    }
  }

  Future<List<pw.ImageProvider?>> loadImages(
      List<Medication> medications) async {
    return Future.wait(medications.map((medication) async {
      if (medication.imageUrl.isNotEmpty) {
        final image = await File(medication.imageUrl).readAsBytes();
        return pw.MemoryImage(image);
      }
      return null;
    }));
  }
}

class PDFSaveException implements Exception {
  final String message;
  PDFSaveException(this.message);
}
