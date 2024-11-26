import 'package:chatter/services/firebase_auth.dart';
import 'package:chatter/services/local_service.dart';
import 'package:chatter/view/auth/send_otp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // For navigation

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  Future<void> _logout() async {
    try {
      await FirebaseAuthServices.firebaseAuth.signOut().then(
        (value) {
          LocalService.clearDataOnLogout();
          Get.offAll(() => SendOtpPage());
        },
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to logout: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logout"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 100, color: Colors.red),
            SizedBox(height: 20),
            Text(
              "Are you sure you want to logout?",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              child: Text("Logout"),
              style: ElevatedButton.styleFrom(),
            ),
          ],
        ),
      ),
    );
  }
}
