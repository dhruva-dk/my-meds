//PDF share service
import 'package:share_plus/share_plus.dart';
import 'pdf_save_service.dart'; // Import PdfSaveService
import 'package:medication_tracker/domain/model/medication_model.dart'; // Import your Medication model

class PDFShareService {
  final PDFSaveService _pdfSaveService = PDFSaveService();

  Future<void> shareMedicationsPDF(List<Medication> medications) async {
    try {
      String filePath = await _pdfSaveService.exportPDF(medications);
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
      throw PDFShareException('${e.toString()}');
    }
  }
}

class PDFShareException implements Exception {
  final String message;
  PDFShareException(this.message);

  @override
  String toString() => 'PDFShareException: $message';
}
