//file which generates pdf and returns file name in documents directory
import 'dart:io';
import 'package:medication_tracker/domain/model/medication_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class PDFShareService {
  Future<String> exportPDF(List<Medication> medications) async {
    final pdf = pw.Document();
    final List<pw.ImageProvider?> images = await loadImages(medications);

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          for (int i = 0; i < medications.length; i++) ...[
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Name: ${medications[i].name.isNotEmpty ? medications[i].name : 'N/A'}",
                  style: const pw.TextStyle(fontSize: 18),
                ),
                pw.Text(
                  "Dosage: ${medications[i].dosage.isNotEmpty ? medications[i].dosage : 'N/A'}",
                  style: const pw.TextStyle(fontSize: 18),
                ),
                pw.Text(
                  "Additional Info: ${medications[i].additionalInfo.isNotEmpty ? medications[i].additionalInfo : 'N/A'}",
                  style: const pw.TextStyle(fontSize: 18),
                ),
                if (medications[i].imageUrl.isNotEmpty && images[i] != null)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 20),
                    child: pw.Image(images[i]!, height: 300, width: 300),
                  ),
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
      throw PDFSaveException(e.toString());
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

  Future<void> shareMedicationsPDF(List<Medication> medications) async {
    try {
      String filePath = await exportPDF(medications);
      //get xfile from path
      XFile file = XFile(filePath);
      //share file
      final result =
          await Share.shareXFiles([file], text: "Medication List PDF");

      if (result.status == ShareResultStatus.dismissed) {
        throw PDFShareException('Export cancelled');
      }
    } on PDFSaveException catch (e) {
      // Rethrow the same exception for the UI to handle
      throw PDFSaveException(e.message);
    } catch (e) {
      // For any other type of error, throw a PDFShareException
      throw PDFShareException(e.toString());
    }
  }
}

class PDFSaveException implements Exception {
  final String message;
  PDFSaveException(this.message);
}

class PDFShareException implements Exception {
  final String message;
  PDFShareException(this.message);

  @override
  String toString() => 'PDFShareException: $message';
}
