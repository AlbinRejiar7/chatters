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
}
