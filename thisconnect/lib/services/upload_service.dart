import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thisconnect/models/attachment_model.dart';

class UploadService {
  static const String baseUrl = "http://thisconnect.runasp.net/api";
  static Future<String?> uploadProfilePhoto(String userId, File image) async {
    final uri = Uri.parse("$baseUrl/api/Upload/UploadProfilePhoto/${userId}");
    var request = http.MultipartRequest('POST', uri);
    var pic = http.MultipartFile.fromBytes(
      'file',
      await image.readAsBytes(),
      filename: image.path.split('/').last,
    );
    request.files.add(pic);

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var result = json.decode(String.fromCharCodes(responseData));
        return result['fileUrl'];
      } else {
        print('Upload failed: ${response.statusCode}');
        final responseBody = await response.stream.bytesToString();
        print('Response body: $responseBody');
        return null;
      }
    } catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }

  static Future<Attachment?> uploadFile(String userId, File file) async {
    final url = Uri.parse('$baseUrl/Upload/UploadFile/$userId');
    final request = http.MultipartRequest('POST', url);
    final tempFile = http.MultipartFile.fromBytes(
      'file',
      await file.readAsBytes(),
      filename: file.path.split('/').last,
    );
    request.files.add(tempFile);

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final result = json.decode(String.fromCharCodes(responseData));
        return Attachment.fromJson(result);
      } else {
        print('Upload failed: ${response.statusCode}');
        final responseBody = await response.stream.bytesToString();
        print('Response body: $responseBody');
        return null;
      }
    } catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }

  static Future<Attachment> getAttachmentById(String attachmentId) async {
    final String apiUrl = '$baseUrl/Upload/GetAttachmentById/$attachmentId';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return Attachment.fromJson(jsonResponse);
    } else {
      print('Failed to load attachment: ${response.statusCode}');
      return Attachment(
          attachmentId: attachmentId, fileType: "", fileUrl: "", fileName: "");
    }
  }

  static Future<File?> downloadFile(String attachmentId) async {
    Attachment attachment = await getAttachmentById(attachmentId);
    final response = await http.get(Uri.parse(attachment.fileUrl));

    if (response.statusCode == 200) {
      final directory = await getExternalStorageDirectory();
      final file = File('${directory!.path}/${attachment.fileName}');
      await file.writeAsBytes(response.bodyBytes);
      print('Dosya indirildi: ${file.path}');
      //await OpenFile.open(file.path);
      return file;
    } else {
      print('Dosya indirilemedi: ${response.statusCode}');
      return null;
    }
  }
}
