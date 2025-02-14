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
      final box = HiveBoxManager.chatBox;

      // Retrieve messages from local storage
      final messages = box!.get(chatRoomId, defaultValue: <dynamic>[]) ?? [];

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
      final box = HiveBoxManager.chatBox;

      // Retrieve the existing messages for the chat
      final existingMessages = box!.get(chatRoomId, defaultValue: <dynamic>[]);

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

  static Future<void> addMessages(
      String chatRoomId, List<ChatModel> messages) async {
    try {
      final box = HiveBoxManager.chatBox;

      // Retrieve existing messages for the chat room in a single call
      final existingMessages = box!.get(chatRoomId, defaultValue: <dynamic>[]);

      // Convert existing messages to a map for quick lookup
      final Map<String, ChatModel> messageMap = {
        for (var message in existingMessages!.whereType<ChatModel>())
          message.id!: message
      };

      // Filter out messages that already exist in storage
      List<ChatModel> newMessages = messages
          .where((message) => !messageMap.containsKey(message.id))
          .toList();

      if (newMessages.isNotEmpty) {
        // Add new messages at the beginning
        final updatedMessages = [...newMessages, ...messageMap.values];

        // Perform a batch write
        await box.put(chatRoomId, updatedMessages);

        log("✅ Added ${newMessages.length} new messages for chatRoomId '$chatRoomId'.");
      } else {
        log("⚠️ No new messages to add for chatRoomId '$chatRoomId'.");
      }
    } catch (e, stacktrace) {
      log("❌ Error in addMessages: $e");
      log("Stacktrace: $stacktrace");
    }
  }

  static Future<void> addMultipleMessages(
      String chatRoomId, List<ChatModel> messages) async {
    try {
      final box = HiveBoxManager.chatBox;

      // Retrieve existing messages for the chat room
      final existingMessages = box!.get(chatRoomId, defaultValue: <dynamic>[]);

      // Convert existing messages to a list of ChatModel objects
      final updatedMessages = List<ChatModel>.from(
        existingMessages?.map((e) => e) ?? [],
      );

      // Filter out messages that are already present
      List<ChatModel> newMessages = messages.where((message) {
        return !updatedMessages
            .any((existingMessage) => existingMessage.id == message.id);
      }).toList();

      if (newMessages.isNotEmpty) {
        // Add new messages at the beginning to maintain order
        updatedMessages.insertAll(0, newMessages);

        // Save the updated list to Hive storage
        await box.put(chatRoomId, updatedMessages);

        log("${newMessages.length} new messages added for chatRoomId '$chatRoomId'.");
      } else {
        log("No new messages to add for chatRoomId '$chatRoomId'.");
      }
    } catch (e, stacktrace) {
      log("Error in addMultipleMessages: $e");
      log("Stacktrace: $stacktrace");
    }
  }

  static Future<void> editMessage(
      String chatRoomId, String messageId, ChatModel updatedMessage) async {
    try {
      final box = HiveBoxManager.chatBox;

      // Retrieve the existing messages for the chat
      final existingMessages = box!.get(chatRoomId, defaultValue: <dynamic>[]);

      if (existingMessages != null && existingMessages.isNotEmpty) {
        // Convert to a list of ChatModel objects
        final updatedMessages = List<ChatModel>.from(
          existingMessages.map((e) => e as ChatModel),
        );

        // Find the index of the message to edit
        final messageIndex =
            updatedMessages.indexWhere((message) => message.id == messageId);

        if (messageIndex != -1) {
          // Update the message using copyWith
          updatedMessages[messageIndex] =
              updatedMessages[messageIndex].copyWith(
            message: updatedMessage.message,
            createdAt: updatedMessage.createdAt,
            senderId: updatedMessage.senderId,
            // Add other fields as needed
          );

          // Save the updated list back to Hive storage
          await box.put(chatRoomId, updatedMessages);

          log("Message with ID '$messageId' updated successfully.");
        } else {
          log("Message with ID '$messageId' not found in chatRoomId '$chatRoomId'.");
        }
      } else {
        log("No messages found for chatRoomId '$chatRoomId'.");
      }
    } catch (e, stacktrace) {
      log("Error in editMessage: $e");
      log("Stacktrace: $stacktrace");
    }
  }

  /// Loads chat messages for a specific chat user.
  static Future<List<ChatModel>> getMessages(String chatRoomId) async {
    try {
      // Open the Hive box for storing chat messages
      final box = HiveBoxManager.chatBox;

      // Retrieve messages for the given chatRoomId
      final messages = box!.get(chatRoomId, defaultValue: <dynamic>[]) ?? [];

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
      final box = HiveBoxManager.chatBox;

      // Retrieve the existing messages for the chat
      final existingMessages = box!.get(chatRoomId, defaultValue: <dynamic>[]);

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
/// Stores unsent messages locally to retry sending later.
static Future<void> storeUnsentMessage(String chatRoomId, ChatModel message) async {
  try {
    final box = HiveBoxManager.chatBox;
    final unsentMessages = box!.get('unsent_$chatRoomId', defaultValue: <dynamic>[]) ?? [];
    final updatedUnsentMessages = List<ChatModel>.from(unsentMessages)..add(message);

    await box.put('unsent_$chatRoomId', updatedUnsentMessages);
    log("📌 Unsent message stored for chatRoomId '$chatRoomId'.");
  } catch (e, stacktrace) {
    log("❌ Error in storeUnsentMessage: $e");
    log("Stacktrace: $stacktrace");
  }
}

/// Retrieves unsent messages for a specific chat room.
static Future<List<ChatModel>> getUnsentMessages(String chatRoomId) async {
  try {
    final box = HiveBoxManager.chatBox;
    final unsentMessages = box!.get('unsent_$chatRoomId', defaultValue: <dynamic>[]) ?? [];
    return unsentMessages.whereType<ChatModel>().toList();
  } catch (e, stacktrace) {
    log("❌ Error in getUnsentMessages: $e");
    log("Stacktrace: $stacktrace");
    return [];
  }
}

/// Removes an unsent message after it's successfully sent.
static Future<void> removeUnsentMessage(String chatRoomId, String messageId) async {
  try {
    final box = HiveBoxManager.chatBox;
    final unsentMessages = box!.get('unsent_$chatRoomId', defaultValue: <dynamic>[]) ?? [];
    final updatedMessages = unsentMessages.whereType<ChatModel>().where((msg) => msg.id != messageId).toList();

    await box.put('unsent_$chatRoomId', updatedMessages);
    log("✅ Unsent message removed for chatRoomId '$chatRoomId'.");
  } catch (e, stacktrace) {
    log("❌ Error in removeUnsentMessage: $e");
    log("Stacktrace: $stacktrace");
  }
}
  static Future<void> updateMessage(
      String chatRoomId, ChatModel updatedMessage) async {
    try {
      final box = HiveBoxManager.chatBox;

      // Retrieve the existing messages for the chat
      final existingMessages = box!.get(chatRoomId, defaultValue: <dynamic>[]);

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
      final box = HiveBoxManager.chatBox;
      await box!.delete(chatRoomId);
      log("All messages cleared for chatRoomId '$chatRoomId'.");
    } catch (e, stacktrace) {
      log("Error in clearMessages for chatRoomId '$chatRoomId': $e");
      log("Stacktrace: $stacktrace");
    }
  }
}
