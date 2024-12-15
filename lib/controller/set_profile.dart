import 'dart:io';

import 'package:chatter/controller/contacts.dart';
import 'package:chatter/controller/country_selector.dart';
import 'package:chatter/services/firebase_services.dart';
import 'package:chatter/services/firebase_storage.dart';
import 'package:chatter/services/local_service.dart';
import 'package:chatter/view/bottom_bar_page/bottom_bar.dart';
import 'package:chatter/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SetProfileController extends GetxController {
  var profileImage = Rx<XFile?>(null);
  var firstName = ''.obs;
  var lastName = ''.obs;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImage.value = image;
    }
  }

  bool validateForm() {
    if (formKey.currentState!.validate()) {
      firstName.value = firstNameController.text.trim();
      lastName.value = lastNameController.text.trim();
      return true;
    }
    return false;
  }

  Future<void> registerUser({
    required String username,
    String? email,
    required String phoneNumber,
    String? bio,
  }) async {
    var ctr = Get.find<CountrySelectorController>();
    var phNumberWithCountryCode = "+${ctr.selectedCountry.value}${phoneNumber}";
    try {
      showLoading();
      var firestore = FirebaseFireStoreServices.firestore;
      var profileImageUrl = '';

      if ((profileImage.value?.path.isNotEmpty) ?? false) {
        profileImageUrl = await FirebaseStorageSerivce.uploadUserImage(
            phoneNumber: phNumberWithCountryCode,
            imageFile: File(profileImage.value!.path));
      }

      // Prepare user data for Firestore
      Map<String, dynamic> userData = {
        "id": phNumberWithCountryCode,
        "username": username,
        "email": email,
        "phoneNumber": phNumberWithCountryCode,
        "profileImageUrl": profileImageUrl,
        "bio": bio,
        "isOnline": true,
        "lastSeen": DateTime.now().toUtc(),
        "blockedUsers": [],
        "createdAt": DateTime.now().toUtc(),
        "updatedAt": DateTime.now().toUtc(),
      };

      // Save the user data in the Firestore database
      await firestore
          .collection('users')
          .doc(phNumberWithCountryCode)
          .set(userData);
      LocalService.setProfileData(
          kimageUrl: profileImageUrl,
          kuserName: username,
          kphNumber: phNumberWithCountryCode);
      LocalService.setLoginStatus(true);
      Get.put(ContactsController());
      Get.offAll(() => BottomBarPage());
      print("User registered and data saved to Firestore successfully.");
    } catch (e) {
      Get.back();
      print("Error registering user: $e");
      rethrow;
    }
  }
}
