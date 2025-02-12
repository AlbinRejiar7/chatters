import 'dart:async';
import 'dart:developer';

import 'package:chatter/model/chat.dart';
import 'package:chatter/services/chat_service.dart';
import 'package:chatter/services/firebase_services.dart';
import 'package:chatter/services/local_chat.dart';
import 'package:chatter/services/local_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class ChatPageController extends GetxController {
  Timer? _debounce;
  // late Box<ChatModel> chatBox;
  final String chatRoomId;
  final String receiverId;
  final int unReadCount;
  final List<ChatModel> lastMesages;
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  var messageController = TextEditingController();
  var currentIndex = 0.obs;
  final ScrollController scrollController = ScrollController();
  var unseenMessages = <ChatModel>[].obs;
  var activeChatId = "".obs;

  // Future<void> loadUnseenMessages(
  //     String chatRoomId, String currentUserId) async {
  //   // Get the last seen timestamp for the user
  //   DocumentSnapshot chatRoomDoc = await FirebaseFireStoreServices.firestore
  //       .collection('users')
  //       .doc(LocalService.userId)
  //       .get();

  //   Map<String, dynamic>? data = chatRoomDoc.data() as Map<String, dynamic>?;

  //   Timestamp? lastSeenTimestamp =
  //       data?['lastSeen']?[currentUserId] ?? Timestamp(0, 0);

  //   QuerySnapshot snapshot = await FirebaseFireStoreServices.firestore
  //       .collection('chatRooms')
  //       .doc(chatRoomId)
  //       .collection('messages')
  //       .where('createdAt',
  //           isGreaterThan: lastSeenTimestamp) // Fetch only new messages
  //       .orderBy('createdAt', descending: false) // Keep the correct order
  //       .get();

  //   if (snapshot.docs.isNotEmpty) {
  //     for (var doc in snapshot.docs) {
  //       final messageData = doc.data() as Map<String, dynamic>?;
  //       if (messageData != null) {
  //         final newMessage = ChatModel.fromJson(messageData);
  //         unseenMessages.add(newMessage);
  //       }
  //     }
  //     log("Loaded unseen messages: ${unseenMessages.length} ${unseenMessages.value}");
  //   } else {
  //     log("No unseen messages to load.");
  //   }
  // }

  // void listenToLastMessageFromBothUsers(String chatRoomId) {
  //   FirebaseFireStoreServices.firestore
  //       .collection('chatRooms')
  //       .doc(chatRoomId)
  //       .collection('messages')
  //       .orderBy('createdAt', descending: true) // Order messages by timestamp
  //       .limit(1) // Fetch only the latest message
  //       .snapshots()
  //       .listen((QuerySnapshot snapshot) async {
  //     if (snapshot.docs.isNotEmpty) {
  //       final doc = snapshot.docs.first;
  //       final data = doc.data() as Map<String, dynamic>?;

  //       if (data == null || !data.containsKey('createdAt')) {
  //         log("Invalid message data received: $data");
  //         return;
  //       }

  //       final newMessage = ChatModel.fromJson(data);
  //       log("${newMessage.message} last message");
  //       // Check if message ID already exists in the list
  //       final isMessageAlreadyAdded = sampleChats.any(
  //         (chat) => chat.id == newMessage.id,
  //       );

  //       if (!isMessageAlreadyAdded) {
  //         // Add to the list and maintain order by createdAt
  //         sampleChats.insert(0, newMessage);
  //         await ChatStorageService.addMessage(chatRoomId, newMessage);
  //         // Notify listeners of the updated list (uncomment if using GetX or similar)
  //         // sampleChats.refresh();
  //         log("Latest message added: ${newMessage.message}");
  //       } else {
  //         log("Message already exists in the list, skipping addition.");
  //       }
  //     } else {
  //       log("No messages found in this chat room.");
  //     }
  //   });
  // }

  void listenToLastMessageFromOtherUser(
      String chatRoomId, String currentUserId) {
    FirebaseFireStoreServices.firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('senderId',
            isNotEqualTo: currentUserId) // Filter messages from other users
        .orderBy('senderId') // Required when using 'where' with inequality
        .orderBy('createdAt', descending: true) // Order by timestamp
        .limit(1) // Fetch only the latest message
        .snapshots()
        .listen((QuerySnapshot snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        if (snapshot.docs.isEmpty) {
          log("No messages from other users in this chat room.");
          return;
        }

        final doc = snapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>?;

        if (data == null || !data.containsKey('createdAt')) {
          log("Invalid message data received: $data");
          return;
        }

        final newMessage = ChatModel.fromJson(data);

        // Check if message ID already exists in the list
        final isMessageAlreadyAdded = sampleChats.any(
          (chat) => chat.id == newMessage.id,
        );

        if (!isMessageAlreadyAdded) {
          // Add to the list and maintain order by createdAt
          sampleChats.insert(0, newMessage);
          await ChatStorageService.addMessage(chatRoomId, newMessage);
          // sampleChats.refresh(); // Notify listeners of the updated list
          log("Latest message from other user added");
        } else {
          log("Message already exists in the list, skipping addition");
        }
      }
    });
  }

  // void listenToMessages(String chatRoomId) {
  //   FirebaseFireStoreServices.firestore
  //       .collection('chatRooms')
  //       .doc(chatRoomId)
  //       .collection('messages')
  //       .orderBy('timestamp', descending: true)
  //       .snapshots()
  //       .listen((QuerySnapshot snapshot) async {
  //     log("new message arrived");
  //     final newChats = snapshot.docs
  //         .map((doc) {
  //           return ChatModel.fromJson(doc.data() as Map<String, dynamic>);
  //         })
  //         .toList()
  //         .reversed
  //         .toList();
  //     sampleChats.value = newChats;
  //   });
  // }

  var sampleChats = <ChatModel>[].obs;

  ChatPageController(this.receiverId, this.unReadCount, this.lastMesages,
      {required this.chatRoomId});
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

  void clearChat(String chatRoomId) async {
    // Create a copy of the list to avoid concurrent modification
    List<ChatModel> chatsCopy = List.from(sampleChats);

    for (var chat in chatsCopy) {
      await ChatStorageService.deleteMessage(chatRoomId, chat.id ?? "");
      deleteMessageFromSampleChats(chat.id ?? "");
    }

    ScaffoldMessenger.of(Get.overlayContext!).showSnackBar(
      const SnackBar(content: Text('Chat cleared!!')),
    );

    Get.back();
  }

  void deleteMessageFromSampleChats(String id) {
    sampleChats.removeWhere(
      (element) => element.id == id,
    );
    sampleChats.refresh();
  }

  void sendMessage() async {
    var isEmpty = sampleChats.isEmpty;
    log("sendMessage tapped");
    if (messageController.text.trim().isEmpty) return;
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    var message = ChatModel(
      id: const Uuid().v4(),
      senderId: LocalService.userId,
      senderName: LocalService.userName,
      message: messageController.text.trim(),
      timestamp: DateTime.now(),
      isSentByMe: true,
      isRead: activeChatId.value == LocalService.userId ? true : null,
      isSend: false,
      mediaUrl: "",
      messageType: MessageType.text,
      receiverId: receiverId,
    );
    sampleChats.insert(0, message);
    messageController.clear();
    _debounce = Timer(const Duration(milliseconds: 100), () async {
      message?.isSend = true;
      // var mediaUrl =
      //     await FirebaseStorageSerivce.uploadUserImage(
      //   phoneNumber: message.receiverId ?? "",
      //   imageFile: File(controller.profileImage.value!.path),
      // );

      // message.mediaUrl = mediaUrl;
      if (true) {
        log("Empty");
        await ChatRoomService.createChatRoomWithFirstMessage(
          message: message,
          receiverId: receiverId,
          participants: [LocalService.userId ?? "", receiverId],
          isGroup: false,
        ).then(
          (value) async {
            await ChatStorageService.addMessage(chatRoomId, message);

            log(" new message after sending");
            update();
          },
        );
      } else {
        log("Not Empty");
        await ChatRoomService.sendMessage(
                chatRoomId: chatRoomId, message: message)
            .then(
          (value) async {
            if (value) {
              if (activeChatId.value != LocalService.userId) {
                // await PushNotificationService.sendNotification(
                //   topicId: receiverId?.replaceAll("+", "_") ?? "",
                //   body: message.message ?? "",
                //   title: message.senderName ?? "",
                // );
              }
              // if ((activeChatId.value != LocalService.userId)) {
              //   log("Value added to the list!");
              //   addToLastMsgList(chatRoomId, message);
              //   await ChatRoomService.incrementUnreadMessageCount(
              //       message.receiverId ?? "");
              // }
              await ChatStorageService.addMessage(chatRoomId, message);

              log("${value} new message after sending");
              update();
            }
          },
        );
      }
    });
  }

  Future<void> getLastMsgListAndAddtoOriginalList(String chatRoomId) async {
    try {
      DocumentSnapshot chatRoomDoc = await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .get();

      if (chatRoomDoc.exists) {
        List<dynamic> messagesJson = chatRoomDoc.get('lastMessages') ?? [];
        var lastMessages =
            messagesJson.map((json) => ChatModel.fromJson(json)).toList();

        for (ChatModel message in lastMessages) {
          bool alreadyExists = sampleChats
              .any((existingMessage) => existingMessage.id == message.id);

          if (!alreadyExists) {
            if (message.senderId != LocalService.userId) {
              sampleChats.insert(0, message);
              ChatStorageService.addMessage(chatRoomId, message);
              log("Added new Last Message with ID: ${message.id}");
            } else {
              message.isRead = true;
              int index = sampleChats.indexWhere((m) => m.id == message.id);
              if (index != -1) {
                sampleChats[index] = message;
              }
            }
            sampleChats.refresh();
          }
        }

        if (activeChatId.value == LocalService.userId) {
          clearAllLastMessages();
        }
      }
    } catch (e) {
      debugPrint("Error fetching lastMessages: $e");
    }
  }

  void addToLastMsgList(String chatRoomId, ChatModel message) {
    FirebaseFirestore.instance.collection('chatRooms').doc(chatRoomId).set(
      {
        'lastMessages': FieldValue.arrayUnion([message.toJson()]),
      },
      SetOptions(merge: true), // Ensure other fields are not overwritten
    ).then((_) {
      log("Value added to the list!");
    }).catchError((error) {
      log("Failed to add value: $error");
    });
  }

  // void addChat({
  //   String? id,
  //   String? senderId,
  //   String? senderName,
  //   String? message,
  //   DateTime? timestamp,
  //   bool? isSentByMe,
  //   bool? isRead,
  //   MessageType? messageType,
  //   required int index,
  // }) {
  //   sampleChats.add(
  //     ChatModel(
  //       id: id ??
  //           DateTime.now()
  //               .millisecondsSinceEpoch
  //               .toString(), // Generate a unique ID if not provided
  //       senderId: senderId,
  //       senderName: senderName,
  //       message: message,
  //       timestamp: timestamp ?? DateTime.now(), // Default to the current time
  //       isSentByMe: isSentByMe,
  //       isRead: null, // Default to false
  //       messageType: messageType ?? MessageType.text, // Default to text
  //     ),
  //   );
  //   listKey.currentState
  //       ?.insertItem(index, duration: const Duration(milliseconds: 200));
  //   scrollToBottom();
  // }

  // Future<List<ChatModel>> loadMessagesFromHive() async {
  //   return chatBox.values.toList();
  // }

  // Future<void> saveMessagesToHive(List<ChatModel> messages) async {
  //   await chatBox.clear(); // Clear old messages
  //   for (var message in messages) {
  //     await chatBox.add(message);
  //   }
  // }

  // void addNewMessage(ChatModel newMessage) async {
  //   if (!chatBox.values.any((msg) => msg.id == newMessage.id)) {
  //     await chatBox.add(newMessage);
  //   }
  // }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    messageController.dispose();
    _debounce?.cancel();
  }

// Timestamp to track the latest message's createdAt field
  // Timestamp? lastFetchedTimeStamp;

  // void listenToNewMessages(String chatRoomId) {
  //   // Reference to the messages collection
  //   CollectionReference messagesRef = FirebaseFirestore.instance
  //       .collection('chatRooms')
  //       .doc(chatRoomId)
  //       .collection('messages');

  //   // Real-time listener to fetch all changes (added, removed, modified)
  //   messagesRef
  //       .orderBy('createdAt', descending: true) // Ensure consistent ordering
  //       .snapshots(
  //           includeMetadataChanges: false) // Ignore metadata-only changes
  //       .listen((QuerySnapshot snapshot) {
  //     for (var change in snapshot.docChanges) {
  //       if (change.type == DocumentChangeType.added) {
  //         // New message added
  //         var doc = change.doc;
  //         ChatModel newMessage =
  //             ChatModel.fromJson(doc.data() as Map<String, dynamic>);

  //         // Ensure it's not already added based on timestamp or ID
  //         if (lastFetchedTimeStamp == null ||
  //             (newMessage.timestamp?.isAfter(lastFetchedTimeStamp!.toDate()) ??
  //                 false)) {
  //           // Add the new message
  //           sampleChats.add(newMessage);

  //           // Update the last fetched timestamp
  //           lastFetchedTimeStamp =
  //               Timestamp.fromDate(newMessage.timestamp ?? DateTime.now())
  //                   as Timestamp?;

  //           log("New message added: ${newMessage.message}");
  //         } else {
  //           log("Duplicate message ignored: ${newMessage.message}");
  //         }
  //       } else if (change.type == DocumentChangeType.removed) {
  //         // Message deleted
  //         String deletedMessageId = change.doc.id;

  //         // Remove the message from the local list
  //         sampleChats.removeWhere((message) => message.id == deletedMessageId);

  //         log("Message deleted locally: $deletedMessageId");
  //       } else if (change.type == DocumentChangeType.modified) {
  //         // Message modified (optional handling, based on your requirements)
  //         var doc = change.doc;
  //         ChatModel updatedMessage =
  //             ChatModel.fromJson(doc.data() as Map<String, dynamic>);

  //         // Update the message in the local list
  //         int index = sampleChats
  //             .indexWhere((message) => message.id == updatedMessage.id);
  //         if (index != -1) {
  //           sampleChats[index] = updatedMessage;
  //           log("Message updated: ${updatedMessage.message}");
  //         }
  //       }
  //     }

  //     // Refresh the UI after processing changes
  //     sampleChats.refresh();
  //   }, onError: (error) {
  //     log("Error fetching new messages: $error");
  //   });
  // }

  void listenToActiveChatId(String userID) {
    try {
      // Reference to the user's document
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(userID);

      // Listen to real-time updates
      userDoc.snapshots().listen((snapshot) {
        if (snapshot.exists) {
          Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
          activeChatId.value = data?['activeChatId'] ?? "";
          log("Active chat ID updated: ${activeChatId.value}");
        }
      });
    } catch (e) {
      // Log any errors
      log("Error listening to activeChatId: $e");
    }
  }

  Future<void> markMessageAsRead(String chatRoomId, String messageId) async {
    try {
      log("🔄 Starting to mark message ID: $messageId as read...");

      // Step 1: Update Firestore
      log("📝 Updating Firestore for message ID: $messageId...");
      await FirebaseFireStoreServices.firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});
      log("✅ Firestore update successful for message ID: $messageId.");

      // Step 2: Update Local Storage (If applicable)
      log("📥 Fetching message from local storage for ID: $messageId...");
      final ChatModel? localMessage =
          await ChatStorageService.getSingleMessage(chatRoomId, messageId);

      if (localMessage != null) {
        log("🔄 Updating local storage for message ID: $messageId...");
        final updatedMessage = localMessage.copyWith(isRead: true);
        await ChatStorageService.updateMessage(chatRoomId, updatedMessage);
        log("✅ Local storage updated for message ID: $messageId.");
      } else {
        log("⚠️ Message ID: $messageId not found in local storage. Skipping local update.");
      }

      log("🎉 Successfully marked message ID: $messageId as read.");
    } catch (e, stackTrace) {
      log("❌ Error updating message ID: $messageId - $e");
      log("🔍 StackTrace: $stackTrace");
    }
  }

  void listenToUnreadMessages(String chatRoomId, String currentUserId) {
    log("🔄 Listening for unread messages in chatRoom: $chatRoomId");

    FirebaseFireStoreServices.firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('isRead', isEqualTo: false) // Get only unread messages
        .where('senderId', isNotEqualTo: currentUserId) // Messages from others
        .orderBy('senderId') // Required when using 'where' with inequality
        .orderBy('createdAt', descending: true) // Latest first
        .snapshots()
        .listen((QuerySnapshot snapshot) async {
      log("📥 Received new snapshot with ${snapshot.docs.length} unread messages");

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          log("🔎 Processing message ID: ${doc.id}");

          final data = doc.data() as Map<String, dynamic>?;

          if (data == null || !data.containsKey('id')) {
            log("⚠️ Invalid message data received: $data");
            continue;
          }

          final message = ChatModel.fromJson(data);
          log("📨 Parsed message: ${message.toJson()}");

          // Check if the message is already read
          if (message.isRead == true) {
            log("✅ Message ID: ${message.id} is already read. Skipping...");
            continue;
          }

          log("📝 Marking message ID: ${message.id} as read in Firestore...");
          await FirebaseFireStoreServices.firestore
              .collection('chatRooms')
              .doc(chatRoomId)
              .collection('messages')
              .doc(message.id)
              .update({'isRead': true});
          log("✅ Message ID: ${message.id} marked as read in Firestore.");

          // Mark message as read in Local Storage
          final updatedMessage = message.copyWith(isRead: true);
          log("🖥 Updating local storage for message ID: ${message.id}");
          await ChatStorageService.updateMessage(chatRoomId, updatedMessage);
          log("✅ Message ID: ${message.id} updated in local storage.");

          log("🔔 Notifying UI about message read status.");
        }

        log("🔄 UI refresh triggered after processing unread messages.");
        // sampleChats.refresh();
      } else {
        log("ℹ️ No unread messages found.");
      }
    });
  }

  Future<void> setReadToTrue() async {
    try {
      // Fetch all messages that are not read and not sent by the current user
      final querySnapshot = await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection("messages")
          .where("isRead", isEqualTo: null)
          .where("senderId", isNotEqualTo: LocalService.userId ?? "")
          .get();

      // Batch to update Firestore
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Loop through messages and update the `isRead` field
      for (var doc in querySnapshot.docs) {
        // Update Firestore document
        batch.update(doc.reference, {"isRead": true});

        // Construct the updated message object
        final updatedMessage = doc.data();
        updatedMessage['isRead'] = true;

        // Update the message in the `sampleChats` list
        int index = sampleChats.indexWhere((chat) => chat.id == doc.id);
        if (index != -1) {
          sampleChats[index] = ChatModel.fromJson(updatedMessage);
          log("Message updated in the list: ${updatedMessage['message']}");

          // Update the message in local storage
          await ChatStorageService.updateMessage(
            chatRoomId,
            ChatModel.fromJson(updatedMessage),
          );
          log("Message updated in local storage: ${updatedMessage['message']}");
        }
      }

      // Commit the batch updates
      await batch.commit();

      // Optional: Notify listeners if using a state management solution like GetX
      // sampleChats.refresh();

      log("All unread messages marked as read and updated in the list and local storage!");
    } catch (e) {
      log('Failed to mark messages as read, update the list, or update local storage: $e');
    }
  }

  void syncLastMessagesWithAllChats() {
    // Log the initial sizes for debugging
    log("Initial size of allChats: ${sampleChats.length}");
    log("Size of listOfLastMessages: ${lastMesages.length}");

    // Convert allChats to a Set of message IDs for efficient lookups
    final allChatIds = sampleChats.map((message) => message.id).toSet();

    // Loop through listOfLastMessages
    for (ChatModel message in lastMesages) {
      if (!allChatIds.contains(message.id)) {
        // Add the new message to allChats
        sampleChats.insert(0, message);
        ChatStorageService.addMessage(chatRoomId, message);
        log("Added new message with ID: ${message.id}");
      }
    }

    log("Final size of allChats: ${sampleChats.length}");
  }

  Future<void> deleteLastMessage(String messageId, String chatRoomId) async {
    try {
      DocumentReference chatRoomRef =
          FirebaseFirestore.instance.collection('chatRooms').doc(chatRoomId);

      await chatRoomRef.update({
        'lastMessages': FieldValue.arrayRemove([
          {'id': messageId} // Assuming each message has an 'id' field
        ])
      });
      print('Message deleted successfully');
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

  Future<void> clearAllLastMessages() async {
    try {
      ChatRoomService.firestore.collection('chatRooms').doc(chatRoomId).update({
        'lastMessages': [],
      });

      log("Successfully cleared lastMessages for all chat rooms.");
    } catch (e) {
      log("Failed to clear lastMessages: $e");
    }
  }

  @override
  void onInit() async {
    super.onInit();
    // chatBox = await Hive.openBox<ChatModel>('chatMessages');

    // sampleChats.value = await loadMessagesFromHive();

    // listenToMessages(chatRoomId);
    // listenToNewMessages(chatRoomId);
    // listenToLastMessageFromOtherUser(chatRoomId, LocalService.userId ?? "");

    // ChatRoomService.resetUnreadMessageCount(receiverId, unReadCount);
    listenToLastMessageFromOtherUser(chatRoomId, LocalService.userId ?? "");
    listenToUnreadMessages(chatRoomId, LocalService.userId ?? "");
    // ChatRoomService.setActiveChatId(receiverId);
    // listenToActiveChatId(receiverId);

    var messages = await ChatStorageService.getMessages(chatRoomId);
    sampleChats(messages);
    // await loadUnseenMessages(chatRoomId, LocalService.userId ?? "");
    sampleChats.addAll(unseenMessages);
// Call the function only if the receiver is not the current user
    // ever(activeChatId, (value) async {
    //   log("${activeChatId} ------------------------------- activeChatId changed id");

    //   await getLastMsgListAndAddtoOriginalList(chatRoomId);
    // });
    // syncLastMessagesWithAllChats();
  }
}
