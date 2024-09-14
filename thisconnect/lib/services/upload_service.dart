import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class UploadService {
  static Future<String?> uploadProfilePhoto(String userId, File image) async {
    final uri = Uri.parse(
        'http://thisconnect.runasp.net/api/Upload/UploadProfilePhoto/${userId}');
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
}
