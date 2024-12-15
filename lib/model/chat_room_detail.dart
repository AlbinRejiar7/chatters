import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomDetailModel {
  // Common fields for both individual and group chats
  String? chatRoomId;
  bool? isGroup;
  String? chatRoomName;
  String? chatRoomImage;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<String>? participants;
  String? lastMessage;
  DateTime? lastMessageTime;
  String? lastMessageSenderId;
  Map<String, int>?
      unReadMessagesCountMap; // Map to store unread messages per user
  String? lastMessageType;
  String? receiverId;

  // Specific fields for group chats
  String? groupAdminId;
  List<String>? groupAdmins;
  List<String>? pinnedMessages;
  String? description;

  // New fields for archiving and pinning
  bool? archive;
  bool? pinChat;

  // Constructor
  ChatRoomDetailModel({
    this.chatRoomId,
    this.isGroup,
    this.chatRoomName,
    this.chatRoomImage,
    this.createdAt,
    this.updatedAt,
    this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    this.unReadMessagesCountMap, // Added here
    this.lastMessageType,
    this.receiverId,
    this.groupAdminId,
    this.groupAdmins,
    this.pinnedMessages,
    this.description,
    this.archive,
    this.pinChat,
  });
  factory ChatRoomDetailModel.fromMap(Map<String, dynamic> map) {
    return ChatRoomDetailModel(
      chatRoomId: map['chatRoomId'] as String?,
      isGroup: map['isGroup'] as bool?,
      chatRoomName: map['chatRoomName'] as String?,
      chatRoomImage: map['chatRoomImage'] as String?,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      participants: map['participants'] != null
          ? List<String>.from(map['participants'] as List)
          : null,
      lastMessage: map['lastMessage'] as String?,
      lastMessageTime: map['lastMessageTime'] != null
          ? (map['lastMessageTime'] as Timestamp).toDate()
          : null,
      lastMessageSenderId: map['lastMessageSenderId'] as String?,
      unReadMessagesCountMap: map['unReadMessagesCount'] is Map
          ? Map<String, int>.from(map['unReadMessagesCount'] as Map)
          : {}, // Fallback to an empty map if it's not a Map
      lastMessageType: map['lastMessageType'] as String?,
      receiverId: map['receiverId'] as String?,
      groupAdminId: map['groupAdminId'] as String?,
      groupAdmins: map['groupAdmins'] != null
          ? List<String>.from(map['groupAdmins'] as List)
          : null,
      pinnedMessages: map['pinnedMessages'] != null
          ? List<String>.from(map['pinnedMessages'] as List)
          : null,
      description: map['description'] as String?,
      archive: map['archive'] as bool?,
      pinChat: map['pinChat'] as bool?,
    );
  }

  // Convert the model to a Map (useful for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'isGroup': isGroup,
      'chatRoomName': chatRoomName,
      'chatRoomImage': chatRoomImage,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime':
          lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'lastMessageSenderId': lastMessageSenderId,
      'unReadMessagesCount': unReadMessagesCountMap, // Adding the map here
      'lastMessageType': lastMessageType,
      'receiverId': receiverId,
      'groupAdminId': groupAdminId,
      'groupAdmins': groupAdmins,
      'pinnedMessages': pinnedMessages,
      'description': description,
      'archive': archive,
      'pinChat': pinChat,
    };
  }

  // Method to write data with server timestamp
  Future<void> saveChatRoom(String chatRoomId) async {
    FirebaseFirestore.instance.collection('chatRooms').doc(chatRoomId).set({
      'chatRoomId': chatRoomId,
      'isGroup': isGroup ?? false,
      'chatRoomName': chatRoomName ?? '',
      'chatRoomImage': chatRoomImage ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'participants': participants ?? [],
      'lastMessage': lastMessage ?? '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': lastMessageSenderId ?? '',
      'unReadMessagesCount': unReadMessagesCountMap ?? {}, // Save the map here
      'lastMessageType': lastMessageType ?? 'text',
      'receiverId': receiverId ?? '',
      'groupAdminId': groupAdminId ?? '',
      'groupAdmins': groupAdmins ?? [],
      'pinnedMessages': pinnedMessages ?? [],
      'description': description ?? '',
      'archive': archive ?? false,
      'pinChat': pinChat ?? false,
    });
  }
}
