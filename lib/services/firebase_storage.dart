import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageSerivce {
  static FirebaseStorage get storage => FirebaseStorage.instance;

  static Future<String> uploadUserImage({
    required String phoneNumber, // Use phone number to organize user images
    required File imageFile, // The image file to upload
  }) async {
    try {
      // Define the storage path
      final storagePath = 'user_images/$phoneNumber/profile_image.jpg';

      // Upload the file to Firebase Storage
      final uploadTask = await storage.ref(storagePath).putFile(imageFile);

      // Get the download URL of the uploaded file
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      print("Image uploaded successfully: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      rethrow;
    }
  }
}
