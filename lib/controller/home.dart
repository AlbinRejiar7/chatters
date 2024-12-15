import 'dart:developer';

import 'package:chatter/model/chat_room_detail.dart';
import 'package:chatter/services/firebase_auth.dart';
import 'package:chatter/services/local_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxList<ChatRoomDetailModel> chatRooms = <ChatRoomDetailModel>[].obs;
  @override
  void onInit() async {
    super.onInit();
    if (LocalService.isLoggedIn ?? false) {
      await fetchContacts();
      listenToChatRooms();
    }
  }

  List<Contact> contacts = []; // All contacts fetched from the device
  Future fetchContacts() async {
    final hasPermission = await FlutterContacts.requestPermission();

    if (hasPermission) {
      contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);

      log("my all contacts ${contacts}");
    } else {
      Get.snackbar("PERMISSION", "Permission Denied");
    }
  }

  void listenToChatRooms() async {
    FirebaseFirestore.instance
        .collection('chatRooms')
        .where('participants', arrayContains: LocalService.userId ?? "")
        .where('pinChat', isEqualTo: false)
        .where('archive', isEqualTo: false)
        .orderBy('lastMessageTime',
            descending: true) // Latest messages at the top
        .snapshots()
        .listen((chatRoomSnapshot) async {
      List<ChatRoomDetailModel> fetchedChatRooms = [];

      for (var doc in chatRoomSnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        var chatRoomModel = ChatRoomDetailModel.fromMap(data);
        var otherUserId = chatRoomModel.participants
                ?.firstWhere(
                  (element) => element != LocalService.userId,
                )
                .toString() ??
            "";
        log("this is other userId ${otherUserId}");
        var userDetails =
            await FirebaseAuthServices.getUserDetailsBydocId(otherUserId);

        // if (chatRoomModel.lastMessage?.isNotEmpty ?? false) {
        //   UserModel? user;
        //   for (var index = 0;
        //       index < contactCtr.listOfMyContacts.length;
        //       index++) {
        //     var item = contactCtr.listOfMyContacts[index];
        //     log("list of my contacts${item.phoneNumber} ${item.id} ${item.username}");
        //     if (item.phoneNumber?.toLowerCase().trim() ==
        //         otherUserId.toLowerCase().trim()) {
        //       user = item;
        //       break;
        //     }
        //   }
        //   log("Resulting user: ${user?.phoneNumber}");

        //   chatRoomModel.chatRoomImage = userDetails?.profileImageUrl;
        //   chatRoomModel.chatRoomName = user?.username ?? "";
        //   fetchedChatRooms.add(chatRoomModel);
        // }
        log("Contact list length: ${contacts.length}");

        // Check if lastMessage is not empty
        if (chatRoomModel.lastMessage?.isNotEmpty ?? false) {
          var user = contacts.firstWhere(
            (contact) {
              String normalizedContactNumber =
                  contact.phones.first.normalizedNumber;

              // Log the normalized numbers
              log("Normalized contact number: $normalizedContactNumber");
              log("Normalized otherUserId: $otherUserId");

              bool isMatch = (normalizedContactNumber == otherUserId) &&
                  (otherUserId != LocalService.userId);

              // Log match status
              log("Match: $isMatch");
              return isMatch;
            },
            orElse: () {
              // Log when no match is found
              log("No match found, creating default UserModel for $otherUserId");
              return Contact();
            },
          );

// Log the resulting user
          log("Resulting user: ${user.phones.first.normalizedNumber}");

          chatRoomModel.chatRoomImage = userDetails?.profileImageUrl;
          chatRoomModel.chatRoomName = user.displayName;
          fetchedChatRooms.add(chatRoomModel);
        }
      }

      // Update observable list and notify listeners
      chatRooms.assignAll(fetchedChatRooms);
      log("ChatRooms Updated: ${chatRooms.length}");
    });
  }
}
