import 'dart:developer';

import 'package:chatter/model/chat_room_detail.dart';
import 'package:chatter/services/firebase_auth.dart';
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

  void listenToChatRooms() async {
    log("🔍 Listening to chatRooms collection...");

    FirebaseFirestore.instance
        .collection('chatRooms')
        .where('participants', arrayContains: LocalService.userId ?? "")
        .where('pinChat', isEqualTo: false)
        .where('archive', isEqualTo: false)
        .orderBy('lastMessage.createdAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .listen((chatRoomSnapshot) async {
      log("📌 Received ${chatRoomSnapshot.docs.length} chat rooms from Firestore");

      List<ChatRoomDetailModel> fetchedChatRooms = [];

      for (var doc in chatRoomSnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data();
          log("📝 Processing chat room: ${doc.id}");

          if (!data.containsKey('lastMessage') || data['lastMessage'] == null) {
            log("⚠️ Skipping chat room ${doc.id} - No last message found.");
            continue;
          }

          ChatRoomDetailModel? chatRoomModel;
          try {
            chatRoomModel = ChatRoomDetailModel.fromMap(data);
          } catch (e) {
            log("❌ Error parsing ChatRoomDetailModel: $e");
            log("🚨 Data: $data");
            continue;
          }

          var participants = chatRoomModel.participants ?? [];
          log("👥 Participants: $participants");

          // Get the other participant (not the current user)
          var otherUserId = participants.firstWhere(
            (element) => element != LocalService.userId,
            orElse: () => "",
          );

          if (otherUserId.isEmpty) {
            log("⚠️ No other user found for chatRoomId: ${doc.id}");
            continue;
          }

          log("✅ Other userId found: $otherUserId");

          // Fetch other user details
          var userDetails =
              await FirebaseAuthServices.getUserDetailsBydocId(otherUserId);
          if (userDetails == null) {
            log("⚠️ No user details found for userId: $otherUserId");
            continue;
          }

          // Skip if the last message is empty
          if (!(chatRoomModel.lastMessage?.message?.isNotEmpty ?? false)) {
            log("⚠️ Skipping chat room ${doc.id} - Last message is empty.");
            continue;
          }

          chatRoomModel.chatRoomImage = userDetails.profileImageUrl ?? "";
          chatRoomModel.chatRoomName = userDetails.username ?? "Unknown User";

          fetchedChatRooms.add(chatRoomModel);
        } catch (e) {
          log("❌ Error processing chat room: $e");
        }
      }

      // Update the observable list
      chatRooms.assignAll(fetchedChatRooms);
      log("✅ Chat rooms updated: ${chatRooms.length}");
    });
  }
}
