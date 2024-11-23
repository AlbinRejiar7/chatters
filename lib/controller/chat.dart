import 'package:chatter/model/chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatPageController extends GetxController {
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  var messageController = TextEditingController();
  var currentIndex = 0.obs;
  var sampleChats = [
    // Day 1
    ChatModel(
      id: "1",
      senderId: "user123",
      senderName: "Alice",
      message: "Hi there!",
      timestamp: DateTime.now()
          .subtract(const Duration(days: 2, hours: 5, minutes: 30)),
      isSentByMe: false,
      isRead: true,
      messageType: MessageType.text,
    ),
    ChatModel(
      id: "2",
      senderId: "user456",
      senderName: "Bob",
      message: "Hello! How are you?",
      timestamp: DateTime.now()
          .subtract(const Duration(days: 2, hours: 5, minutes: 28)),
      isSentByMe: true,
      isRead: true,
      messageType: MessageType.text,
    ),
    ChatModel(
      id: "3",
      senderId: "user123",
      senderName: "Alice",
      message: "I'm good, thanks! How about you?",
      timestamp: DateTime.now()
          .subtract(const Duration(days: 2, hours: 5, minutes: 25)),
      isSentByMe: false,
      isRead: true,
      messageType: MessageType.text,
    ),
    ChatModel(
      id: "4",
      senderId: "user456",
      senderName: "Bob",
      message: "Doing great! Here's a video I found interesting.",
      timestamp: DateTime.now()
          .subtract(const Duration(days: 2, hours: 5, minutes: 20)),
      isSentByMe: true,
      isRead: true,
      messageType: MessageType.video,
    ),

    // Day 2
    ChatModel(
      id: "5",
      senderId: "user123",
      senderName: "Alice",
      message: "Wow, that’s really cool! Here's a link to a similar one.",
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      isSentByMe: false,
      isRead: true,
      messageType: MessageType.text,
    ),
    ChatModel(
      id: "6",
      senderId: "user456",
      senderName: "Bob",
      message: "Thanks for sharing!",
      timestamp: DateTime.now()
          .subtract(const Duration(days: 1, hours: 2, minutes: 50)),
      isSentByMe: true,
      isRead: true,
      messageType: MessageType.text,
    ),
    ChatModel(
      id: "7",
      senderId: "user123",
      senderName: "Alice",
      message: "Any plans for the weekend?",
      timestamp: DateTime.now()
          .subtract(const Duration(days: 1, hours: 2, minutes: 30)),
      isSentByMe: false,
      isRead: true,
      messageType: MessageType.text,
    ),
    ChatModel(
      id: "8",
      senderId: "user456",
      senderName: "Bob",
      message: "Not yet. Maybe hiking. You?",
      timestamp: DateTime.now()
          .subtract(const Duration(days: 1, hours: 2, minutes: 25)),
      isSentByMe: true,
      isRead: true,
      messageType: MessageType.text,
    ),

    // Today
    ChatModel(
      id: "9",
      senderId: "user123",
      senderName: "Alice",
      message: "Hiking sounds fun! Let me know if you need company.",
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isSentByMe: false,
      isRead: true,
      messageType: MessageType.text,
    ),
    ChatModel(
      id: "10",
      senderId: "user456",
      senderName: "Bob",
      message: "Will do! Also, here’s a funny meme I found.",
      timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 50)),
      isSentByMe: true,
      isRead: true,
      messageType: MessageType.image,
    ),
    ChatModel(
      id: "11",
      senderId: "user123",
      senderName: "Alice",
      message: "Haha, that’s hilarious! Thanks for sharing.",
      timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 45)),
      isSentByMe: false,
      isRead: true,
      messageType: MessageType.text,
    ),
    ChatModel(
      id: "12",
      senderId: "user456",
      senderName: "Bob",
      message: "Anytime! Catch up soon.",
      timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 40)),
      isSentByMe: true,
      isRead: false,
      messageType: MessageType.text,
    ),
  ].obs;

  void scrollToBottom(scrollController) {
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

  void addChat(
      {String? id,
      String? senderId,
      String? senderName,
      String? message,
      DateTime? timestamp,
      bool? isSentByMe,
      bool? isRead,
      MessageType? messageType,
      required int index,
      scrollController}) {
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
    scrollToBottom(scrollController);
  }
}
