import 'dart:developer';

import 'package:chatter/model/chat.dart';
import 'package:chatter/utils/get_box.dart';

class ChatStorageService {
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

  /// Updates a specific message in the chat storage for a specific user.
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
