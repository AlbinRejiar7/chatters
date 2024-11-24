import 'dart:io';

import 'package:chatter/constants/colors.dart'; // Replace with your color constants file
import 'package:chatter/controller/set_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SetProfilePage extends StatelessWidget {
  final SetProfileController controller = Get.put(SetProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Your Profile',
            style: TextStyle(color: AppColors.whiteColor)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: IconThemeData(color: AppColors.whiteColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image Section
              Obx(
                () => GestureDetector(
                  onTap: controller.pickImage,
                  child: CircleAvatar(
                    radius: 50.r,
                    backgroundColor: AppColors.greyColor,
                    backgroundImage: controller.profileImage.value != null
                        ? FileImage(
                            File(controller.profileImage.value!.path),
                          )
                        : null,
                    child: controller.profileImage.value == null
                        ? Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: AppColors.primaryColor,
                          )
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // First Name Field (Required)
              TextFormField(
                controller: controller.firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  labelStyle: TextStyle(color: AppColors.primaryColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.primaryColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.greyColor),
                  ),
                ),
                cursorColor: AppColors.primaryColor,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Last Name Field (Optional)
              TextFormField(
                controller: controller.lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name (Optional)',
                  labelStyle: TextStyle(color: AppColors.primaryColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.primaryColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.greyColor),
                  ),
                ),
                cursorColor: AppColors.primaryColor,
              ),
              SizedBox(height: 30),

              // Save Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primaryColor, // Button background color
                  foregroundColor: AppColors.whiteColor, // Button text color
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (controller.validateForm()) {
                    Get.snackbar(
                      'Profile Saved',
                      'First Name: ${controller.firstName.value}\nLast Name: ${controller.lastName.value}',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.primaryColor,
                      colorText: AppColors.whiteColor,
                    );
                  }
                },
                child: Text('Save Profile', style: TextStyle(fontSize: 16.sp)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
