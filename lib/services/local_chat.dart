import 'dart:developer';

import 'package:chatter/model/chat.dart';
import 'package:chatter/utils/get_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';

class ChatStorageService {
  static GetStorage get boxStorage => GetStorage();

  /// Save last seen message timestamp for a chat room
  static Future<void> setLastSeenTimestamp(
      String chatRoomId, Timestamp timestamp) async {
    boxStorage.write('lastSeen_$chatRoomId', timestamp.seconds);
  }

  /// Retrieve the last seen timestamp; default to 0 if not found
  static Future<Timestamp> getLastSeenTimestamp(String chatRoomId) async {
    final seconds = boxStorage.read('lastSeen_$chatRoomId') ?? 0;
    return Timestamp(seconds, 0);
  }

  /// Retrieves a single message by `messageId` from local storage.
  static Future<ChatModel?> getSingleMessage(
      String chatRoomId, String messageId) async {
    try {
      log("🔍 Fetching message ID: $messageId for chatRoomId: $chatRoomId");

      // Open the Hive box for chat messages
      final box = await HiveBoxManager.getChatBox();

      // Retrieve messages from local storage
      final messages = box.get(chatRoomId, defaultValue: <dynamic>[]) ?? [];

      // Convert stored data to a list of ChatModel objects
      final chatList = messages.whereType<ChatModel>().toList();

      // Find the message with the given ID
      final message = chatList.firstWhere(
        (msg) => msg.id == messageId,
      );

      if (message != null) {
        log("✅ Message found: ${message.id}");
      } else {
        log("⚠️ Message with ID '$messageId' not found in chatRoomId: $chatRoomId");
      }

      return message;
    } catch (e, stacktrace) {
      log("❌ Error retrieving message ID '$messageId' for chatRoomId '$chatRoomId': $e");
      log("Stacktrace: $stacktrace");
      return null;
    }
  }

  /// Adds a message to the chat storage for a specific user.
  static Future<void> addMessage(String chatRoomId, ChatModel message) async {
    try {
      final box = await HiveBoxManager.getChatBox();

      // Retrieve the existing messages for the chat
      final existingMessages = box.get(chatRoomId, defaultValue: <dynamic>[]);

      // Convert the existing messages to a list of ChatModel objects
      final updatedMessages = List<ChatModel>.from(
        existingMessages?.map((e) => e) ?? [],
      );

      // Check if the message with the same ID already exists
      final isMessageAlreadyAdded = updatedMessages
          .any((existingMessage) => existingMessage.id == message.id);

      if (!isMessageAlreadyAdded) {
        updatedMessages.insert(
            0, message); // Add the new message at the 0th index
        await box.put(
            chatRoomId, updatedMessages); // Save the updated list to the box
        log("Message added for chatRoomId '$chatRoomId'.");
      } else {
        log("Message with ID '${message.id}' already exists, skipping addition.");
      }
    } catch (e, stacktrace) {
      log("Error in addMessage: $e");
      log("Stacktrace: $stacktrace");
    }
  }

  /// Loads chat messages for a specific chat user.
  static Future<List<ChatModel>> getMessages(String chatRoomId) async {
    try {
      // Open the Hive box for storing chat messages
      final box = await HiveBoxManager.getChatBox();

      // Retrieve messages for the given chatRoomId
      final messages = box.get(chatRoomId, defaultValue: <dynamic>[]) ?? [];

      // Filter to ensure all items are valid ChatModel objects
      return messages.whereType<ChatModel>().toList();
    } catch (e, stacktrace) {
      // Log the error and stacktrace
      log("Error retrieving messages for chatRoomId '$chatRoomId': $e");
      log("Stacktrace: $stacktrace");

      // Return an empty list if an error occurs
      return [];
    }
  }

  /// Deletes a specific message by ID for a given chat user.
  static Future<void> deleteMessage(String chatRoomId, String messageId) async {
    try {
      final box = await HiveBoxManager.getChatBox();

      // Retrieve the existing messages for the chat
      final existingMessages = box.get(chatRoomId, defaultValue: <dynamic>[]);

      if (existingMessages != null && existingMessages.isNotEmpty) {
        // Convert to a list of ChatModel objects and filter out the message to delete
        final updatedMessages = List<ChatModel>.from(
          existingMessages.map((e) => e as ChatModel),
        ).where((message) => message.id != messageId).toList();

        // Save the updated list back to the box
        await box.put(chatRoomId, updatedMessages);
        log("Message with ID '$messageId' deleted successfully.");
      } else {
        log("No messages found for chatRoomId '$chatRoomId'.");
      }
    } catch (e, stacktrace) {
      log("Error in deleteMessage: $e");
      log("Stacktrace: $stacktrace");
    }
  }

  static Future<void> updateMessage(
      String chatRoomId, ChatModel updatedMessage) async {
    try {
      final box = await HiveBoxManager.getChatBox();

      // Retrieve the existing messages for the chat
      final existingMessages = box.get(chatRoomId, defaultValue: <dynamic>[]);

      if (existingMessages != null && existingMessages.isNotEmpty) {
        // Convert to a list of ChatModel objects
        final updatedMessages = List<ChatModel>.from(
          existingMessages.map((e) => e as ChatModel),
        );

        // Find the index of the message to update
        final messageIndex = updatedMessages
            .indexWhere((message) => message.id == updatedMessage.id);

        if (messageIndex != -1) {
          // Update the message at the found index
          updatedMessages[messageIndex] = updatedMessage;
          await box.put(chatRoomId, updatedMessages); // Save the updated list
          log("Message with ID '${updatedMessage.id}' updated successfully.");

          // Refresh UI by notifying the list
          // sampleChats.refresh();
        } else {
          log("Message with ID '${updatedMessage.id}' not found for chatRoomId '$chatRoomId'.");
        }
      } else {
        log("No messages found for chatRoomId '$chatRoomId'.");
      }
    } catch (e, stacktrace) {
      log("Error in updateMessage: $e");
      log("Stacktrace: $stacktrace");
    }
  }

  /// Clears all messages for a specific chat user.
  static Future<void> clearMessages(String chatRoomId) async {
    try {
      final box = await HiveBoxManager.getChatBox();
      await box.delete(chatRoomId);
      log("All messages cleared for chatRoomId '$chatRoomId'.");
    } catch (e, stacktrace) {
      log("Error in clearMessages for chatRoomId '$chatRoomId': $e");
      log("Stacktrace: $stacktrace");
    }
  }
}
