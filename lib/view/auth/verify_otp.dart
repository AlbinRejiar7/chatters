import 'package:chatter/view/auth/send_otp.dart';
import 'package:chatter/controller/send_otp.dart';
import 'package:chatter/services/firebase_auth.dart';
import 'package:chatter/utils/sizedboxwidget.dart';
import 'package:chatter/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class VerifyOtpPage extends StatelessWidget {
  final String verificationId;
  const VerifyOtpPage({super.key, required this.verificationId});

  @override
  Widget build(BuildContext context) {
    var ctr = Get.find<SendOtpContrller>();
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: (20.w), vertical: (40.h)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Verification Code",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 25),
            ),
            kHeight(10.h),
            Text(
              'A verification code will be sent to this number. Carrier rates may apply.',
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 10.sp,
              ),
            ),
            kHeight(10.h),
            Row(
              children: [
                TextFieldCustom(
                  controller: ctr.otpController,
                  hintText: "Enter otp",
                  maxLength: 6,
                ),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomElevatedButton(
                    text: 'Continue',
                    onPressed: () {
                      if (ctr.otpController.text.length == 6) {
                        FirebaseAuthServices.verifyOtp(
                            number: ctr.phoneController.text,
                            smsCode: ctr.otpController.text,
                            verificationId: verificationId);
                      } else {
                        Get.snackbar("Mismatch", "Check OTP and try again");
                      }
                    }),
              ],
            )
          ],
        ),
      ),
    ));
  }
}
