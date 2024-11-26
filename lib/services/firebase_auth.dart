import 'dart:developer';

import 'package:chatter/controller/country_selector.dart';
import 'package:chatter/model/user.dart';
import 'package:chatter/services/firebase_services.dart';
import 'package:chatter/services/local_service.dart';
import 'package:chatter/view/auth/verify_otp.dart';
import 'package:chatter/view/bottom_bar_page/bottom_bar.dart';
import 'package:chatter/view/reg_details/profile.dart';
import 'package:chatter/widgets/loading_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class FirebaseAuthServices {
  // static User get user => FirebaseAuth.instance.currentUser!;
  static FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  static void sendOtp(String number) {
    showLoading();
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
    required String number,
    required String verificationId,
  }) async {
    var ctr = Get.find<CountrySelectorController>();
    showLoading();
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
        Get.to(
            () => SetProfilePage(
                  phonNumber: number,
                ),
            transition: Transition.cupertino);
      } else {
        var formatedNumberId = "+${ctr.selectedCountry.value}${number}";
        log("FORMATED NUMBER as id $formatedNumberId");
        var userDetails = await getUserDetailsBydocId(formatedNumberId);
        LocalService.setProfileData(
          kimageUrl: userDetails?.profileImageUrl ?? "",
          kuserName: userDetails?.username ?? "",
          kphNumber: userDetails?.phoneNumber ?? "",
        );
        LocalService.setLoginStatus(true);
        Get.offAll(() => const BottomBarPage(),
            transition: Transition.cupertino);
      }
    } on FirebaseAuthException catch (e) {
      Get.back();
      log(e.message ?? "An error occurred during verification");
      // Show error to user (optional)
      Get.snackbar("ERROR", e.message ?? "Verification failed");
    } catch (e) {
      Get.back();
      log("Unexpected error: $e");
      Get.snackbar("ERROR", "Something went wrong. Please try again.");
    }
  }

  static Future<UserModel?> getUserDetailsBydocId(String docId) async {
    try {
      // Query the 'users' collection where the 'phoneNumber' field matches the given phone number
      log("DOC ID ${docId}");
      final querySnapshot = await FirebaseFireStoreServices.firestore
          .collection('users')
          .doc(docId)
          .get();

      // Check if a matching user exists
      if ((querySnapshot.data()?.isNotEmpty ?? false)) {
        // Convert the document to a UserModel instance and return it
        return UserModel.fromMap(querySnapshot.data() ?? {});
      } else {
        // No user found for the given phone number
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user details: $e");
      }
      return null;
    }
  }
}
