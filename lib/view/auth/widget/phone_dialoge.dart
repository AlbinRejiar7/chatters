import 'package:chatter/constants/colors.dart';
import 'package:chatter/controller/country_selector.dart';
import 'package:chatter/services/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

void showPhoneNumberDialog(BuildContext context, String phoneNumber) {
  var ctr = Get.find<CountrySelectorController>();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounded corners
        ),
        title: Text(
          'Is the phone number below correct ?',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: AppColors.darkColor),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$phoneNumber',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: AppColors.darkColor.withOpacity(0.5)),
            ),
            Text(
              'A verification code will be sent to this number. Carrier rates may apply.',
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
            },
            child: const Text(
              'Edit number',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuthServices.sendOtp(
                  "+${ctr.selectedCountry.value}$phoneNumber");
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}
