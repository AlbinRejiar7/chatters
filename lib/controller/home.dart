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
    FirebaseFirestore.instance
        .collection('chatRooms')
        .where('participants', arrayContains: LocalService.userId ?? "")
        .where('pinChat', isEqualTo: false)
        .where('archive', isEqualTo: false)
        .orderBy('lastMessage.createdAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .listen((chatRoomSnapshot) async {
      List<ChatRoomDetailModel> fetchedChatRooms = [];

      for (var doc in chatRoomSnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data();

          if (!data.containsKey('lastMessage') || data['lastMessage'] == null) {
            continue;
          }

          ChatRoomDetailModel? chatRoomModel;
          try {
            chatRoomModel = ChatRoomDetailModel.fromMap(data);
          } catch (e) {
            continue;
          }

          var participants = chatRoomModel.participants ?? [];

          // Get the other participant (not the current user)
          var otherUserId = participants.firstWhere(
            (element) => element != LocalService.userId,
            orElse: () => "",
          );

          if (otherUserId.isEmpty) {
            continue;
          }

          // Fetch other user details
          var userDetails =
              await FirebaseAuthServices.getUserDetailsBydocId(otherUserId);
          if (userDetails == null) {
            continue;
          }

          // Skip if the last message is empty
          if (!(chatRoomModel.lastMessage?.message?.isNotEmpty ?? false)) {
            continue;
          }

          chatRoomModel.chatRoomImage = userDetails.profileImageUrl ?? "";
          chatRoomModel.chatRoomName = userDetails.username ?? "Unknown User";

          fetchedChatRooms.add(chatRoomModel);
        } catch (e) {}
      }

      // Update the observable list
      chatRooms.assignAll(fetchedChatRooms);
    });
  }
}
