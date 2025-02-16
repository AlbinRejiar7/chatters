import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageSerivce {
  static FirebaseStorage get storage => FirebaseStorage.instance;

  static Future<String> uploadUserImage({
    required String phoneNumber, // Use phone number to organize user images
    required File imageFile, // The image file to upload
  }) async {
    try {
      if (!imageFile.existsSync()) {
        throw Exception("The file does not exist: ${imageFile.path}");
      }

      // Define the storage path
      final storagePath = 'user_images/$phoneNumber/profile_image.jpg';

      // Get a reference to the storage location
      final storageRef = storage.ref(storagePath);

      // Check if the path exists (Firebase handles this automatically)
      // Upload the file to Firebase Storage
      final uploadTask = await storageRef.putFile(imageFile);

      // Get the download URL of the uploaded file
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      print("Image uploaded successfully: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      rethrow;
    }
  }

  static Future<String> uploadUserAudio({
    required String
        phoneNumber, // Use phone number to organize user audio files
    required File audioFile, // The audio file to upload
  }) async {
    try {
      if (!audioFile.existsSync()) {
        throw Exception("The file does not exist: ${audioFile.path}");
      }

      // Define the storage path
      final storagePath =
          'user_audios/$phoneNumber/audio_${DateTime.now().millisecondsSinceEpoch}.mp3';

      // Get a reference to the storage location
      final storageRef = storage.ref(storagePath);

      // Upload the file to Firebase Storage
      final uploadTask = await storageRef.putFile(audioFile);

      // Get the download URL of the uploaded file
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      print("Audio uploaded successfully: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Error uploading audio: \$e");
      rethrow;
    }
  }
}
