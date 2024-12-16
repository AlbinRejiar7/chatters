import 'dart:developer';

import 'package:chatter/model/chat_room_detail.dart';
import 'package:chatter/services/firebase_auth.dart';
import 'package:chatter/services/local_service.dart';
import 'package:chatter/utils/get_plain_number.dart';
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
        try {
          Map<String, dynamic> data = doc.data();
          var chatRoomModel = ChatRoomDetailModel.fromMap(data);

          // Find the other user's ID
          var otherUserId = chatRoomModel.participants?.firstWhere(
                (element) => element != LocalService.userId,
                orElse: () => "",
              ) ??
              "";
          if (otherUserId.isEmpty) {
            log("No other user found for chatRoomId: ${doc.id}");
            continue;
          }

          log("This is other userIdddddddddd: $otherUserId");

          // Fetch user details
          var userDetails =
              await FirebaseAuthServices.getUserDetailsBydocId(otherUserId);

          // Skip if no last message
          if (!(chatRoomModel.lastMessage?.message?.isNotEmpty ?? false)) {
            continue;
          }

          // Match with contacts
          var user = findUserContact(contacts, otherUserId);

          // Set chat room properties
          chatRoomModel.chatRoomImage = userDetails?.profileImageUrl ?? "";
          chatRoomModel.chatRoomName = user.displayName ?? "Unknown";
          fetchedChatRooms.add(chatRoomModel);
        } catch (e) {
          log("Error processing chat room: $e");
        }
      }

      // Update observable list and notify listeners
      chatRooms.assignAll(fetchedChatRooms);
      log("ChatRooms Updated: ${chatRooms.length}");
    });
  }
}

Contact findUserContact(List<Contact> contacts, String otherUserId) {
  try {
    // Check if `contacts` or `otherUserId` is null or empty
    if (contacts == null || contacts.isEmpty) {
      log("Contacts list is empty or null.");
      return Contact(); // Default contact
    }

    if (otherUserId == null || otherUserId.isEmpty) {
      log("Other user ID is null or empty.");
      return Contact(); // Default contact
    }

    // Normalize `otherUserId`
    String normalizedOtherUserId = getPlainPhoneNumber(otherUserId);
    if (normalizedOtherUserId.isEmpty) {
      return Contact(); // Default contact
    }

    // Find matching contact
    var user = contacts.firstWhere(
      (contact) {
        if (contact?.phones == null || contact.phones.isEmpty) {
          return false; // Skip contacts without phone numbers
        }

        // Normalize the contact's first phone number
        String normalizedContactNumber =
            getPlainPhoneNumber(contact.phones.first.normalizedNumber ?? '');

        // Compare normalized phone numbers
        return normalizedContactNumber == normalizedOtherUserId &&
            normalizedOtherUserId != LocalService.userId;
      },
      orElse: () {
        return Contact(); // Default contact
      },
    );

    return user;
  } catch (e, stacktrace) {
    // Log any unexpected errors
    log("Error in findUserContact: $e");
    log("Stacktrace: $stacktrace");
    return Contact(); // Default contact in case of errors
  }
}
