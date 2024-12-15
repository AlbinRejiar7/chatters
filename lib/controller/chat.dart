import 'dart:async';
import 'dart:developer';

import 'package:chatter/model/chat.dart';
import 'package:chatter/services/chat_service.dart';
import 'package:chatter/services/firebase_services.dart';
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
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  var messageController = TextEditingController();
  var currentIndex = 0.obs;
  final ScrollController scrollController = ScrollController();
  // void listenToLastMessageFromOtherUser(
  //     String chatRoomId, String currentUserId) {
  //   FirebaseFireStoreServices.firestore
  //       .collection('chatRooms')
  //       .doc(chatRoomId)
  //       .collection('messages')
  //       .where('senderId',
  //           isNotEqualTo: currentUserId) // Filter messages from other users
  //       .orderBy('senderId') // Required when using 'where' with inequality
  //       .orderBy('createdAt', descending: true) // Order by timestamp
  //       .limit(1) // Fetch only the latest message
  //       .snapshots()
  //       .listen((QuerySnapshot snapshot) async {
  //     if (snapshot.docs.isNotEmpty) {
  //       final doc = snapshot.docs.first;
  //       final data = doc.data() as Map<String, dynamic>;

  //       if (data.isEmpty || !data.containsKey('createdAt')) {
  //         log("Invalid message data received: $data");
  //         return;
  //       }

  //       final newMessage = ChatModel.fromJson(data);

  //       // Check if `createdAt` is null
  //       if (newMessage.createdAt == null) {
  //         log("Message with null `createdAt` skipped: ${newMessage.id}");
  //         return;
  //       }

  //       // Check if message ID already exists in the list
  //       final isMessageAlreadyAdded =
  //           sampleChats.any((chat) => chat.id == newMessage.id);

  //       if (!isMessageAlreadyAdded) {
  //         // Add to the list and maintain order by createdAt
  //         sampleChats.add(newMessage);

  //         sampleChats.sort((a, b) {
  //           final createdAtA = a.createdAt ?? DateTime(0);
  //           final createdAtB = b.createdAt ?? DateTime(0);
  //           return createdAtA.compareTo(createdAtB);
  //         });

  //         await ChatStorageService.addMessage(chatRoomId, newMessage);
  //         sampleChats.refresh(); // Notify listeners of the updated list
  //         log("Latest message from other user added");
  //       } else {
  //         log("Message already exists in the list, skipping addition");
  //       }
  //     }
  //   });
  // }

  void listenToMessages(String chatRoomId) {
    FirebaseFireStoreServices.firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) async {
      log("new message arrived");
      final newChats = snapshot.docs
          .map((doc) {
            return ChatModel.fromJson(doc.data() as Map<String, dynamic>);
          })
          .toList()
          .reversed
          .toList();
      sampleChats.value = newChats;
    });
  }

  var sampleChats = <ChatModel>[].obs;

  ChatPageController(this.receiverId, this.unReadCount,
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
      isRead: null,
      isSend: false,
      mediaUrl: "",
      messageType: MessageType.text,
      receiverId: receiverId,
    );
    sampleChats.add(message);
    _debounce = Timer(const Duration(milliseconds: 100), () async {
      message?.isSend = true;
      // var mediaUrl =
      //     await FirebaseStorageSerivce.uploadUserImage(
      //   phoneNumber: message.receiverId ?? "",
      //   imageFile: File(controller.profileImage.value!.path),
      // );

      // message.mediaUrl = mediaUrl;
      if (isEmpty) {
        log("Empty");
        await ChatRoomService.createChatRoomWithFirstMessage(
          message: message,
          receiverId: receiverId,
          participants: [LocalService.userId ?? "", receiverId],
          isGroup: false,
        );
      } else {
        log("Not Empty");
        await ChatRoomService.sendMessage(
                chatRoomId: chatRoomId, message: message)
            .then(
          (value) async {
            if (value) {
              // // Fetch the latest message
              // var newMessage =
              //     await ChatRoomService.getLatestMessage(
              //         chatRoomId);

              // int index = sampleChats.indexWhere(
              //     (message) => message.id == newMessage?.id);

              // if (index != -1) {
              //   // If the message exists, replace it
              //   await ChatStorageService.addMessage(
              //       chatRoomId, newMessage!);
              //   sampleChats[index] = newMessage!;
              // } else {
              //   // If the message doesn't exist, add it to the list
              //   sampleChats.add(newMessage!);
              //   await ChatStorageService.addMessage(
              //       chatRoomId, newMessage!);
              // }

              log("${value} new message after sending");
              // update();
            }
          },
        );
      }

      messageController.clear();
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

  @override
  void onInit() async {
    super.onInit();
    // chatBox = await Hive.openBox<ChatModel>('chatMessages');

    // sampleChats.value = await loadMessagesFromHive();

    listenToMessages(chatRoomId);
    // listenToNewMessages(chatRoomId);
    // listenToLastMessageFromOtherUser(chatRoomId, LocalService.userId ?? "");
    ChatRoomService.resetUnreadMessageCount(receiverId, unReadCount);
    // ChatStorageService.loadMessages(chatRoomId).then((loadedMessages) {
    //   sampleChats.clear();
    //   sampleChats.addAll(loadedMessages);
    //   sampleChats.refresh(); // Notify listeners (if using GetX)
    //   log("Loaded messages from local storage");
    // });
  }
}
