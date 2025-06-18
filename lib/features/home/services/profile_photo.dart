import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'df9j5vwur';
  static const String uploadPreset = 'default_rent';
  static const String apiKey = '791183161927126';

  static Future<String?> uploadImage(File imageFile) async {
    try {
      print('Starting image upload to Cloudinary...');
      print('File path: ${imageFile.path}');
      print('File exists: ${await imageFile.exists()}');

      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      print('Upload URL: $uri');

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      print('Sending upload request...');
      final response = await request.send();
      print('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        print('Response data: $responseData');

        final decodedData = jsonDecode(responseData);
        final imageUrl = decodedData['secure_url'];
        print('Upload successful. Image URL: $imageUrl');
        return imageUrl;
      } else {
        final errorData = await response.stream.bytesToString();
        print('Upload failed with status: ${response.statusCode}');
        print('Error response: $errorData');
        return null;
      }
    } catch (e, stackTrace) {
      print('Error uploading image: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
}

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> updateUserImage(String uid, String imageUrl) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'imageUrl': imageUrl});
      print('Image URL updated in Firestore successfully');
    } catch (e) {
      print('Error updating image URL in Firestore: $e');
      throw e;
    }
  }
}
