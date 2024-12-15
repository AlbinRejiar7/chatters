// import 'dart:developer';

// import 'package:chatter/model/chat.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// class ChatStorageService {
//   static const String chatBoxName = "chatBox";

//   static Future<void> addMessage(String chatUsersId, ChatModel message) async {
//     final box = await Hive.openBox<List>(chatBoxName);

//     // Retrieve the existing messages for the chat
//     final existingMessages = box.get(chatUsersId, defaultValue: []);

//     // Convert the existing messages to a list of ChatModel objects
//     final updatedMessages = List<ChatModel>.from(existingMessages ?? []);

//     // Check if the message with the same ID already exists
//     final isMessageAlreadyAdded = updatedMessages
//         .any((existingMessage) => existingMessage.id == message.id);

//     if (!isMessageAlreadyAdded) {
//       updatedMessages.add(message); // Add the new message
//       await box.put(
//           chatUsersId, updatedMessages); // Save the updated list to the box
//     } else {
//       log("Message with ID '${message.id}' already exists, skipping addition.");
//     }
//   }

//   // Load chat messages for a specific chat user
//   static Future<List<ChatModel>> loadMessages(String chatUsersId) async {
//     final box = await Hive.openBox<List>('chatBox');
//     final messages = box.get(chatUsersId, defaultValue: []);
//     return messages?.map((e) => e as ChatModel).toList() ?? [];
//   }

//   static Future<void> deleteMessage(
//       String chatUsersId, String messageId) async {
//     final box = await Hive.openBox<List>(chatBoxName);

//     // Retrieve the existing messages for the chat
//     final existingMessages = box.get(chatUsersId, defaultValue: []);

//     if (existingMessages != null && existingMessages.isNotEmpty) {
//       // Convert to a list of ChatModel objects and filter out the message to delete
//       final updatedMessages = List<ChatModel>.from(existingMessages)
//           .where((message) => message.id != messageId)
//           .toList();

//       // Save the updated list back to the box
//       await box.put(chatUsersId, updatedMessages);
//       log("Message with ID '$messageId' deleted successfully.");
//     } else {
//       log("No messages found for chat room ID '$chatUsersId'.");
//     }
//   }
// }
