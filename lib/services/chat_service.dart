import 'dart:developer';

import 'package:chatter/model/chat.dart';
import 'package:chatter/services/firebase_analytics.dart';
import 'package:chatter/services/local_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class ChatRoomService {
  static Future<String> createChatRoom({
    required String receiverId,
    required List<String> participants,
    required bool isGroup,
    String? chatRoomName,
    String? chatRoomImage,
    String? description,
  }) async {
    try {
      // Step 1: Generate Chat Room ID
      var chatRoomId = isGroup
          ? Timestamp.now().millisecondsSinceEpoch.toString()
          : getConversationID(receiverId);

      debugPrint('Step 1: Chat Room ID generated: $chatRoomId');

      // Step 2: Check if chat room already exists
      debugPrint('Step 2: Checking if chat room exists...');
      var exists = await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .get()
          .then((doc) => doc.exists);
      debugPrint('Step 2: Chat room exists: $exists');

      if (exists) {
        debugPrint('Step 2: Returning existing chat room ID: $chatRoomId');
        return chatRoomId;
      }

      // Step 3: Prepare Chat Room Data
      debugPrint('Step 3: Preparing chat room data...');
      var chatRoomData = {
        'chatRoomId': chatRoomId,
        'isGroup': isGroup,
        'receiverId': receiverId,
        'chatRoomName': chatRoomName ?? 'Chat with $receiverId',
        'chatRoomImage': chatRoomImage,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'participants': participants,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': '',
        'archive': false,
        'pinChat': false,
        'description': description,
        'lastMessageType': '',
        'unReadMessagesCount': {},
      };

      debugPrint('Step 3: Chat room data prepared: $chatRoomData');

      // Step 4: Write Chat Room to Firestore
      debugPrint('Step 4: Writing chat room to Firestore...');
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .set(chatRoomData);
      debugPrint('Step 4: Chat room created successfully with ID: $chatRoomId');

      // Step 5: Return Chat Room ID
      debugPrint('Step 5: Returning Chat Room ID...');
      return chatRoomId;
    } catch (e) {
      // Log error
      debugPrint('Error creating chat room: $e');
      return '';
    }
  }

  static Future<void> createChatRoomWithFirstMessage({
    required String receiverId,
    required List<String> participants,
    required bool isGroup,
    String? chatRoomName,
    String? chatRoomImage,
    String? description,
    required ChatModel message,
  }) async {
    try {
      // Step 1: Log the start of the process
      debugPrint('Step 1: Initiating chat room creation with first message...');

      // Step 2: Call createChatRoom to get or create the chat room ID
      debugPrint('Step 2: Creating or retrieving chat room...');
      var chatRoomId = await createChatRoom(
        receiverId: receiverId,
        participants: participants,
        isGroup: isGroup,
      );
      debugPrint('Step 2: Chat room ID obtained: $chatRoomId');

      // Step 3: Send the first message
      debugPrint('Step 3: Sending the first message...');
      await sendMessage(chatRoomId: chatRoomId, message: message);
      debugPrint('Step 3: First message sent successfully.');

      // Step 4: Log Firestore write operation
      debugPrint('Step 4: Logging Firestore write operation...');
      await FirestoreLogger.logFieldWrite(
        name: "createfirstmessage",
        mainCollection: 'chatRooms',
        mainDocument: chatRoomId,
        subCollection: 'messages',
        subDocument: message.id,
      );
      debugPrint('Step 4: Firestore write operation logged successfully.');

      // Step 5: Log successful completion
      debugPrint('Step 5: Chat room with first message created successfully.');
    } catch (e) {
      // Log any errors that occur
      debugPrint('Error in createChatRoomWithFirstMessage: $e');
    }
  }

  // static Future<String> createChatRoomWithFirstMessage({
  //   required ChatModel message,
  //   required String receiverId,
  //   required List<String> participants,
  //   required bool isGroup,
  //   required String firstMessage,
  //   required String senderId,
  //   String? chatRoomName,
  //   String? chatRoomImage,
  //   String? description,
  // }) async {
  //   try {
  //     // Generate chat room ID
  //     var chatRoomId = isGroup
  //         ? Timestamp.now().millisecondsSinceEpoch.toString()
  //         : getConversationID(receiverId);

  //     debugPrint('Creating chat room with ID: $chatRoomId');

  //     var chatRoomData = ChatRoomDetailModel(
  //       chatRoomId: chatRoomId,
  //       isGroup: isGroup,
  //       receiverId: receiverId,
  //       chatRoomName: chatRoomName ?? 'Chat with $receiverId',
  //       chatRoomImage: chatRoomImage,
  //       createdAt: DateTime.now(),
  //       updatedAt: DateTime.now(),
  //       participants: participants,
  //       lastMessage: firstMessage,
  //       lastMessageTime: DateTime.now(),
  //       lastMessageSenderId: senderId,
  //       archive: false,
  //       pinChat: false,
  //       description: description,
  //       lastMessageType: 'text',
  //       unReadMessagesCountMap: {},
  //     );
  //     await FirebaseFirestore.instance
  //         .collection('chatRooms')
  //         .doc(chatRoomData.chatRoomId)
  //         .set(chatRoomData.toMap());

  //     debugPrint('Chat room created successfully.');

  //     // Add the first message
  //     await FirebaseFirestore.instance
  //         .collection('chatRooms')
  //         .doc(chatRoomData.chatRoomId)
  //         .collection("messages")
  //         .doc(message.id)
  //         .set(message.toJson());
  //     debugPrint('First message sent successfully.');

  //     // Log the write operation
  //     await FirestoreLogger.logFieldWrite(
  //       name: "createfirstmessage",
  //       mainCollection: 'chatRooms',
  //       mainDocument: chatRoomId,
  //       subCollection: 'messages',
  //       subDocument: message.id,
  //     );

  //     return chatRoomId;
  //   } catch (e) {
  //     debugPrint('Error creating chat room or sending first message: $e');
  //     return '';
  //   }
  // }

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

  static Future<void> incrementUnreadMessageCount(String receiverId) async {
    log("${receiverId}");
    try {
      // Reference the chat room document in Firestore
      final chatRoomDoc = FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(getConversationID(receiverId));

      // Perform the increment operation
      await chatRoomDoc.update({
        'unReadMessagesCount.$receiverId': FieldValue.increment(1),
      }).then(
        (value) async {
          await FirestoreLogger.logFieldWrite(
              name: "incrementUnreadMessageCount",
              mainCollection: 'chatRooms',
              mainDocument: getConversationID(receiverId),
              fields: ['unReadMessagesCount.$receiverId']);
        },
      );

      print(
          'Unread message count incremented for $receiverId in ${getConversationID(receiverId)}.');
    } catch (e) {
      print('Failed to increment unread message count: $e');
    }
  }

  static Future<void> resetUnreadMessageCount(
      String receiverId, int unreadCount) async {
    log("Resetting unread message count for $receiverId with current unread count: $unreadCount");
    try {
      // Only perform the reset operation if the unread count is not zero
      if (unreadCount != 0) {
        // Reference the chat room document in Firestore
        final chatRoomDoc = FirebaseFirestore.instance
            .collection('chatRooms')
            .doc(getConversationID(receiverId));

        // Perform the reset operation
        await chatRoomDoc.update({
          'unReadMessagesCount.${LocalService.userId}': 0, // Set count to 0
        }).then(
          (value) async {
            await FirestoreLogger.logFieldWrite(
                name: "resetUnreadMessageCount",
                mainCollection: 'chatRooms',
                mainDocument: getConversationID(receiverId),
                fields: ['unReadMessagesCount.${LocalService.userId}']);
          },
        );

        print(
            'Unread message count reset for $receiverId in ${getConversationID(receiverId)}.');
      } else {
        print(
            'Unread message count is already zero for $receiverId. No write performed.');
      }
    } catch (e) {
      print('Failed to reset unread message count: $e');
    }
  }

  static Future<void> setReadToTrue(
      {required String senderId, required String messageId}) async {
    log(senderId + "Receiver ID");
    try {
      // Reference the specific message document in Firestore
      final messageDoc = FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(getConversationID(senderId))
          .collection("messages")
          .doc(messageId);

      // Update the `isRead` field to true
      await messageDoc.update({"isRead": true}).then(
        (value) async {
          await FirestoreLogger.logFieldWrite(
              name: "setReadToTrue",
              mainCollection: 'chatRooms',
              mainDocument: getConversationID(senderId),
              subCollection: "messages",
              subDocument: messageId,
              fields: ['isRead']);
        },
      );
    } catch (e) {
      log('Failed to mark message as read: $e');
    }
  }

  static Future<bool> sendMessage({
    required String chatRoomId,
    required ChatModel message,
  }) async {
    try {
      message.id ??= const Uuid().v4();

      // Convert the message to JSON
      Map<String, dynamic> messageData = message.toJson();

      // Add the message to Firestore
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(message.id)
          .set(messageData)
          .then(
        (value) async {
          await FirestoreLogger.logFieldWrite(
            name: "sendingmessages",
            mainCollection: 'chatRooms',
            subCollection: 'messages',
            subDocument: message.id,
            mainDocument: chatRoomId,
          );
        },
      );

      // Optionally, update the last message in the chat room for quick access
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .set({"lastMessage": message.toJson()}, SetOptions(merge: true));
      await incrementUnreadMessageCount(message.receiverId ?? "");
      print('Message sent successfully!');
      return true;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  static Future<ChatModel?> getLatestMessage(String chatRoomId) async {
    try {
      // Reference to the messages collection
      CollectionReference messagesRef = FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages');

      // Fetch the latest message (limit 1)
      QuerySnapshot snapshot = await messagesRef
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      // Check if there is at least one document
      if (snapshot.docs.isNotEmpty) {
        // Convert the document to a ChatModel
        var doc = snapshot.docs.first;
        ChatModel latestMessage =
            ChatModel.fromJson(doc.data() as Map<String, dynamic>);

        // Return the latest message
        return latestMessage;
      } else {
        // No messages found
        return null;
      }
    } catch (e) {
      // Handle errors
      log("Error fetching latest message: $e");
      return null;
    }
  }
}
