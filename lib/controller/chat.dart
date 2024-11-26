import 'dart:developer';

import 'package:chatter/model/chat.dart';
import 'package:chatter/services/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatPageController extends GetxController {
  final String chatRoomId;
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  var messageController = TextEditingController();
  var currentIndex = 0.obs;
  final ScrollController scrollController = ScrollController();
  void listenToMessages(String chatRoomId) {
    sampleChats.clear();
    log("Listening to messages...");

    FirebaseFireStoreServices.firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      final newChats = snapshot.docs.map((doc) {
        return ChatModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      // Compare the newChats with sampleChats to find truly new messages
      for (var newChat in newChats.reversed) {
        if (!sampleChats.any((existingChat) => existingChat.id == newChat.id)) {
          sampleChats.add(newChat);
          final index = sampleChats.indexOf(newChat);

          // Insert new chat into the AnimatedList
          listKey.currentState
              ?.insertItem(index, duration: const Duration(milliseconds: 200));
        }
      }

      scrollToBottom();

      log("${sampleChats.length} sampleChats length...");
    });
  }

  // var sampleChats = [
  //   // Day 1
  //   ChatModel(
  //     id: "1",
  //     senderId: "user123",
  //     senderName: "Alice",
  //     message: "Hi there!",
  //     timestamp: DateTime.now()
  //         .subtract(const Duration(days: 2, hours: 5, minutes: 30)),
  //     isSentByMe: false,
  //     isRead: true,
  //     messageType: MessageType.text,
  //   ),
  //   ChatModel(
  //     id: "2",
  //     senderId: "user456",
  //     senderName: "Bob",
  //     message: "Hello! How are you?",
  //     timestamp: DateTime.now()
  //         .subtract(const Duration(days: 2, hours: 5, minutes: 28)),
  //     isSentByMe: true,
  //     isRead: true,
  //     messageType: MessageType.text,
  //   ),
  //   ChatModel(
  //     id: "3",
  //     senderId: "user123",
  //     senderName: "Alice",
  //     message: "I'm good, thanks! How about you?",
  //     timestamp: DateTime.now()
  //         .subtract(const Duration(days: 2, hours: 5, minutes: 25)),
  //     isSentByMe: false,
  //     isRead: true,
  //     messageType: MessageType.text,
  //   ),
  //   ChatModel(
  //     id: "4",
  //     senderId: "user456",
  //     senderName: "Bob",
  //     message: "Doing great! Here's a video I found interesting.",
  //     timestamp: DateTime.now()
  //         .subtract(const Duration(days: 2, hours: 5, minutes: 20)),
  //     isSentByMe: true,
  //     isRead: true,
  //     messageType: MessageType.video,
  //   ),

  //   // Day 2
  //   ChatModel(
  //     id: "5",
  //     senderId: "user123",
  //     senderName: "Alice",
  //     message: "Wow, that’s really cool! Here's a link to a similar one.",
  //     timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
  //     isSentByMe: false,
  //     isRead: true,
  //     messageType: MessageType.text,
  //   ),
  //   ChatModel(
  //     id: "234234",
  //     senderId: "user123",
  //     senderName: "Alice",
  //     message: "Wow, that’s really cool! Here's a link to a similar one.",
  //     timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
  //     isSentByMe: false,
  //     isRead: true,
  //     messageType: MessageType.text,
  //   ),
  //   ChatModel(
  //     id: "55646456",
  //     senderId: "user123",
  //     senderName: "Alice",
  //     message: "Wow, that’s really cool! Here's a link to a similar one.",
  //     timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
  //     isSentByMe: false,
  //     isRead: true,
  //     messageType: MessageType.text,
  //   ),
  //   ChatModel(
  //     id: "34523",
  //     senderId: "user123",
  //     senderName: "Alice",
  //     message: "Wow, that’s really cool! Here's a link to a similar one.",
  //     timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
  //     isSentByMe: false,
  //     isRead: true,
  //     messageType: MessageType.text,
  //   ),
  //   ChatModel(
  //     id: "6",
  //     senderId: "user456",
  //     senderName: "Bob",
  //     message: "Thanks for sharing!",
  //     timestamp: DateTime.now()
  //         .subtract(const Duration(days: 1, hours: 2, minutes: 50)),
  //     isSentByMe: true,
  //     isRead: true,
  //     messageType: MessageType.text,
  //   ),
  //   ChatModel(
  //     id: "7",
  //     senderId: "user123",
  //     senderName: "Alice",
  //     message: "Any plans for the weekend?",
  //     timestamp: DateTime.now()
  //         .subtract(const Duration(days: 1, hours: 2, minutes: 30)),
  //     isSentByMe: false,
  //     isRead: true,
  //     messageType: MessageType.text,
  //   ),
  //   ChatModel(
  //     id: "8",
  //     senderId: "user456",
  //     senderName: "Bob",
  //     message: "Not yet. Maybe hiking. You?",
  //     timestamp: DateTime.now()
  //         .subtract(const Duration(days: 1, hours: 2, minutes: 25)),
  //     isSentByMe: true,
  //     isRead: true,
  //     messageType: MessageType.text,
  //   ),

  //   // Today
  //   ChatModel(
  //     id: "9",
  //     senderId: "user123",
  //     senderName: "Alice",
  //     message: "Hiking sounds fun! Let me know if you need company.",
  //     timestamp: DateTime.now().subtract(const Duration(hours: 5)),
  //     isSentByMe: false,
  //     isRead: true,
  //     messageType: MessageType.text,
  //   ),
  //   ChatModel(
  //     id: "10",
  //     senderId: "user456",
  //     senderName: "Bob",
  //     message: "Will do! Also, here’s a funny meme I found.",
  //     timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 50)),
  //     isSentByMe: true,
  //     isRead: true,
  //     messageType: MessageType.image,
  //   ),
  //   ChatModel(
  //     id: "11",
  //     senderId: "user123",
  //     senderName: "Alice",
  //     message: "Haha, that’s hilarious! Thanks for sharing.",
  //     timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 45)),
  //     isSentByMe: false,
  //     isRead: true,
  //     messageType: MessageType.text,
  //   ),
  //   ChatModel(
  //     id: "12",
  //     senderId: "user456",
  //     senderName: "Bob",
  //     message: "Anytime! Catch up soon.",
  //     timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 40)),
  //     isSentByMe: true,
  //     isRead: false,
  //     messageType: MessageType.text,
  //   ),
  // ].obs;
  var sampleChats = <ChatModel>[].obs;

  ChatPageController({required this.chatRoomId});
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void addChat({
    String? id,
    String? senderId,
    String? senderName,
    String? message,
    DateTime? timestamp,
    bool? isSentByMe,
    bool? isRead,
    MessageType? messageType,
    required int index,
  }) {
    sampleChats.add(
      ChatModel(
        id: id ??
            DateTime.now()
                .millisecondsSinceEpoch
                .toString(), // Generate a unique ID if not provided
        senderId: senderId,
        senderName: senderName,
        message: message,
        timestamp: timestamp ?? DateTime.now(), // Default to the current time
        isSentByMe: isSentByMe,
        isRead: isRead ?? false, // Default to false
        messageType: messageType ?? MessageType.text, // Default to text
      ),
    );
    listKey.currentState
        ?.insertItem(index, duration: const Duration(milliseconds: 200));
    scrollToBottom();
  }

  @override
  void onInit() {
    super.onInit();
    listenToMessages(chatRoomId);
  }
}
