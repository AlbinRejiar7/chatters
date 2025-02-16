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
    print("HomeController initialized");
    listenToChatRooms();
  }

  void listenToChatRooms() async {
    print("Listening to chat rooms...");
    FirebaseFirestore.instance
        .collection('chatRooms')
        .where('participants', arrayContains: LocalService.userId ?? "")
        .where('pinChat', isEqualTo: false)
        .where('archive', isEqualTo: false)
        .orderBy('lastMessage.createdAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .listen((chatRoomSnapshot) async {
      print("Chat room snapshot received, processing...");
      List<ChatRoomDetailModel> fetchedChatRooms = [];

      for (var doc in chatRoomSnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data();
          print("Processing chat room: ${doc.id}");

          if (!data.containsKey('lastMessage') || data['lastMessage'] == null) {
            print("Skipping chat room ${doc.id}: No last message");
            continue;
          }

          ChatRoomDetailModel? chatRoomModel;
          try {
            chatRoomModel = ChatRoomDetailModel.fromMap(data);
          } catch (e) {
            print("Error parsing chat room ${doc.id}: $e");
            continue;
          }

          var participants = chatRoomModel.participants ?? [];

          // Get the other participant (not the current user)
          var otherUserId = participants.firstWhere(
            (element) => element != LocalService.userId,
            orElse: () => "",
          );

          if (otherUserId.isEmpty) {
            print("Skipping chat room ${doc.id}: No valid participant");
            continue;
          }

          // Fetch other user details
          var userDetails =
              await FirebaseAuthServices.getUserDetailsBydocId(otherUserId);
          if (userDetails == null) {
            print("Skipping chat room ${doc.id}: User details not found");
            continue;
          }

          // Skip if the last message is empty
          if (!(chatRoomModel.lastMessage?.message?.isNotEmpty ?? false)) {
            print("Skipping chat room ${doc.id}: Last message is empty");
            continue;
          }

          chatRoomModel.chatRoomImage = userDetails.profileImageUrl ?? "";
          chatRoomModel.chatRoomName = userDetails.username ?? "Unknown User";

          print("Chat room ${doc.id} added: ${chatRoomModel.chatRoomName}");
          fetchedChatRooms.add(chatRoomModel);
        } catch (e) {
          print("Unexpected error processing chat room ${doc.id}: $e");
        }
      }

      // Update the observable list
      chatRooms.assignAll(fetchedChatRooms);
      print("Chat rooms list updated: ${chatRooms.length} rooms");
    });
  }
}
