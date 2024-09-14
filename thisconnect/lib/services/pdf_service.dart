import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PdfService {
  static Future<String?> downloadPDF(String qrId) async {
    final url = 'http://thisconnect.runasp.net/api/Pdf/DownloadPDF?qrId=$qrId';
    final response = await http.get(Uri.parse(url), headers: {
      'Accept': 'application/pdf',
    });

    if (response.statusCode == 200) {
      // Dosya adını başlıktan alma
      final contentDisposition = response.headers['content-disposition'];
      final fileName = _extractFileName(contentDisposition!);

      final downloadsDirectory = await getExternalStorageDirectory();
      final filePath = '${downloadsDirectory!.path}/$fileName';
      final file = File(filePath);

      // PDF verilerini dosyaya yaz
      await file.writeAsBytes(response.bodyBytes);

      // PDF okuyucuda dosyayı aç
      await OpenFile.open(filePath);
      return filePath;
    } else {
      print('Failed to download PDF');
      return null;
    }
  }

  static String _extractFileName(String contentDisposition) {
    final regex = RegExp(r'filename="([^"]+)"');
    final match = regex.firstMatch(contentDisposition);
    return match?.group(1) ?? 'default_filename.pdf';
  }
}
