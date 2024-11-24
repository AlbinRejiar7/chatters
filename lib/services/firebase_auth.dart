import 'dart:developer';

import 'package:chatter/auth/verify_otp.dart';
import 'package:chatter/view/bottom_bar_page/bottom_bar.dart';
import 'package:chatter/view/reg_details/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class FirebaseAuthServices {
  // static User get user => FirebaseAuth.instance.currentUser!;
  static FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  static void sendOtp(String number) {
    log("my number ${number}");
    firebaseAuth.verifyPhoneNumber(
      phoneNumber: number,
      verificationCompleted: (phoneAuthCredential) {},
      verificationFailed: (error) {
        Get.snackbar("ERROR", error.message.toString());
      },
      codeSent: (verificationId, forceResendingToken) {
        Get.to(
            () => VerifyOtpPage(
                  verificationId: verificationId,
                ),
            transition: Transition.cupertino);
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  static Future<void> verifyOtp({
    required String smsCode,
    required String verificationId,
  }) async {
    try {
      // Create credentials from the SMS code and verification ID
      final cred = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign in the user with the credential
      final userCredential = await firebaseAuth.signInWithCredential(cred);

      // Check if the user is new
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // Navigate to registration screen
        Get.to(() => SetProfilePage(), transition: Transition.cupertino);
      } else {
        // Navigate to home screen
        Get.to(() => const BottomBarPage(), transition: Transition.cupertino);
      }
    } on FirebaseAuthException catch (e) {
      log(e.message ?? "An error occurred during verification");
      // Show error to user (optional)
      Get.snackbar("ERROR", e.message ?? "Verification failed");
    } catch (e) {
      log("Unexpected error: $e");
      Get.snackbar("ERROR", "Something went wrong. Please try again.");
    }
  }
}
