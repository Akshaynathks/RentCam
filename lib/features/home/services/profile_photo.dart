import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName =
      'df9j5vwur'; 
  static const String uploadPreset =
      'default_rent'; 
  static const String apiKey =
      '791183161927126'; 

  static Future<String?> uploadImage(File imageFile) async {
    try {
      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = jsonDecode(responseData);
        return decodedData[
            'secure_url']; 
      } else {
        print('Image upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
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
