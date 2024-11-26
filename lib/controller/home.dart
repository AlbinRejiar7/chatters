import 'dart:developer';

import 'package:chatter/model/chat_room_detail.dart';
import 'package:chatter/services/local_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxList<ChatRoomDetailModel> chatRooms = <ChatRoomDetailModel>[].obs;
  @override
  void onInit() {
    super.onInit();
    listenToChatRooms();
  }

  void listenToChatRooms() {
    log("listenToChatRooms........");
    log("userId........${LocalService.userId ?? ""}");
    FirebaseFirestore.instance
        .collection('chatRooms')
        .where('participants', arrayContains: LocalService.userId ?? "")
        .where('pinChat', isEqualTo: false)
        .where('archive', isEqualTo: false)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((chatRoomSnapshot) async {
      List<ChatRoomDetailModel> fetchedUsers = [];

      for (var doc in chatRoomSnapshot.docs) {
        // Check if the `messages` subcollection exists
        final messagesRef = FirebaseFirestore.instance
            .collection('chatRooms')
            .doc(doc.id)
            .collection('messages');

        final messagesSnapshot = await messagesRef.limit(1).get();

        if (messagesSnapshot.docs.isNotEmpty) {
          // Convert chat room document to UserModel or fetch users if necessary
          Map<String, dynamic> data = doc.data();
          fetchedUsers
              .add(ChatRoomDetailModel.fromMap(data)); // Adjust as needed
        }
      }

      // Update the observable list
      chatRooms.assignAll(fetchedUsers);

      log(" length of array ${chatRooms.length}........");
    });
  }
}
