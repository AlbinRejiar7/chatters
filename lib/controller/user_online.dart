import 'package:chatter/utils/format_time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserOnlineStatusController extends GetxController {
  final String otherUserId;

  UserOnlineStatusController({required this.otherUserId});

  RxString lastSeenString = "".obs;

  void listenToAppTerminationStatus(String otherUserId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();

        if (data != null && data.containsKey('lastSeen')) {
          var lastSeenRaw = data['lastSeen'];

          // Ensure 'lastSeen' is not null and is a Timestamp
          if (lastSeenRaw is Timestamp) {
            DateTime lastSeenTime = lastSeenRaw.toDate();
            String formattedTime = formatTime(lastSeenTime);

            lastSeenString.value =
                "Last seen on $formattedTime"; // Update UI value
          } else if (lastSeenRaw == null) {
            lastSeenString.value = "online"; // Default value
          } else {
            debugPrint(
                "❌ Error: 'lastSeen' is not a Timestamp. Value: $lastSeenRaw");
          }
        } else {
          debugPrint("⚠️ Field 'lastSeen' not found in document.");
        }
      } else {
        debugPrint("❌ Document does not exist for user ID: $otherUserId");
      }
    }, onError: (error) {
      debugPrint("❌ Error listening to Firestore document: $error");
    });
  }

  @override
  void onInit() {
    super.onInit();

    listenToAppTerminationStatus(otherUserId);
  }
}
