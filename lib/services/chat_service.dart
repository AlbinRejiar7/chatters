import 'package:chatter/model/chat.dart';
import 'package:chatter/services/local_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class ChatRoomService {
  // Function to create a chat room, ensuring it does not exist already

  static Future<String> createChatRoom({
    required String receiverId, // ID of the current user (sender)
    required List<String>
        participants, // List of user IDs to be added to the chat
    required bool isGroup, // If true, create a group chat
    String? chatRoomName, // Optional group name
    String? chatRoomImage, // Optional group image
    String? description, // Optional group description
  }) async {
    try {
      // Get the chat room ID (for individual chat, generate based on receiverId)
      var chatRoomId = isGroup
          ? Timestamp.now()
              .millisecondsSinceEpoch
              .toString() // Unique ID for group chat
          : getConversationID(receiverId); // Unique ID for individual chat

      debugPrint('Creating chat room...');

      // Log participants and whether it's a group chat or not
      debugPrint('Participants: $participants');
      debugPrint('Is Group Chat: $isGroup');
      debugPrint('Chat Room ID: $chatRoomId');

      // Check if the chat room already exists
      bool chatRoomExists = await doesChatRoomExist(chatRoomId);
      debugPrint('Chat room exists: $chatRoomExists');

      if (chatRoomExists) {
        // If the chat room already exists, return the existing chat room ID
        debugPrint('Returning existing chat room ID: $chatRoomId');
        return chatRoomId;
      }

      // Prepare the chat room data
      Map<String, dynamic> chatRoomData = {
        'chatRoomId': chatRoomId,
        'isGroup': isGroup,
        'receiverId': receiverId,
        'chatRoomName':
            chatRoomName ?? 'Chat with $receiverId', // Default to a simple name
        'chatRoomImage': chatRoomImage,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'participants': participants,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': '',
        'archive': false, // Initially not archived
        'pinChat': false, // Initially not pinned
        'description': description,
        'lastMessageType': '',
        'unReadMessagesCount': 0
      };

      // Log chat room data before adding to Firestore
      debugPrint('Chat room data to be added: $chatRoomData');

      // Add the new chat room to Firestore
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .set(chatRoomData);

      debugPrint('Chat room created successfully with ID: $chatRoomId');

      // Return the chat room ID for further use (e.g., to navigate to the chat screen)
      return chatRoomId;
    } catch (e) {
      // Log the error
      if (kDebugMode) {
        debugPrint('Error creating chat room: $e');
      }
      return '';
    }
  }

  // Helper function to check if the chat room already exists for the given participants
  static Future<bool> doesChatRoomExist(String documentId) async {
    try {
      // Reference the document by its ID
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(documentId)
          .get();

      // Check if the document exists
      return doc.exists;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking chat room existence: $e');
      }
      return false;
    }
  }

  // Function to get the conversation ID for an individual chat
  static String getConversationID(String receiverId) {
    // Assuming the conversation ID is created by sorting the user IDs alphabetically
    // This ensures that the chat ID is unique and consistent for any pair of users
    List<String> users = [LocalService.userId ?? "", receiverId]..sort();
    return users.join('_');
  }

  static Future<void> sendMessage({
    required String chatRoomId,
    required ChatModel message,
  }) async {
    try {
      // Generate a unique ID for the message
      message.id ??= const Uuid().v4();

      // Set the timestamp for the message
      message.timestamp ??= DateTime.now();

      // Convert the message to JSON
      Map<String, dynamic> messageData = message.toJson();

      // Add the message to Firestore
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(message.id)
          .set(messageData);

      // Optionally, update the last message in the chat room for quick access
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .update({
        'lastMessage': message.message,
        'lastMessageTime': message.timestamp,
        'lastMessageSenderId': message.senderId,
        'lastMessageType': message.messageType?.toString().split('.').last,
      });

      print('Message sent successfully!');
    } catch (e) {
      print('Error sending message: $e');
    }
  }


  
}
