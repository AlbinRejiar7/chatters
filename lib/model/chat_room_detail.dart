import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomDetailModel {
  // Common fields for both individual and group chats
  String? chatRoomId; // Unique ID for the chat room
  bool? isGroup; // Indicates if the chat is a group chat
  String? chatRoomName; // Group name or custom name for the chat
  String? chatRoomImage; // Group image or contact profile picture
  DateTime? createdAt; // When the chat room was created
  DateTime? updatedAt; // When the chat room was last updated
  List<String>? participants; // List of user IDs participating in the chat
  String? lastMessage; // Preview of the last message in the chat
  DateTime? lastMessageTime; // Timestamp of the last message
  String? lastMessageSenderId; // ID of the sender of the last message
  int? unReadMessagesCount; // Count of unread messages
  String? lastMessageType; // Type of the last message (e.g., text, image)

  // Specific fields for group chats
  String? groupAdminId; // ID of the group admin (only for groups)
  List<String>? groupAdmins; // List of group admins (for larger groups)
  List<String>? pinnedMessages; // List of message IDs pinned in the group
  String? description; // Group description (only for groups)

  // New fields for archiving and pinning
  bool? archive; // Whether the chat is archived
  bool? pinChat; // Whether the chat is pinned

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
    this.unReadMessagesCount,
    this.lastMessageType,
    this.groupAdminId,
    this.groupAdmins,
    this.pinnedMessages,
    this.description,
    this.archive,
    this.pinChat,
  });

  // Factory constructor to parse from a Map (useful for Firestore data)
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
      unReadMessagesCount: map['unReadMessagesCount'] as int?,
      lastMessageType: map['lastMessageType'] as String?,
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
      'unReadMessagesCount': unReadMessagesCount,
      'lastMessageType': lastMessageType,
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
      'createdAt': FieldValue.serverTimestamp(), // Set server timestamp
      'updatedAt': FieldValue.serverTimestamp(), // Set server timestamp
      'participants': participants ?? [],
      'lastMessage': lastMessage ?? '',
      'lastMessageTime': FieldValue.serverTimestamp(), // Set server timestamp
      'lastMessageSenderId': lastMessageSenderId ?? '',
      'unReadMessagesCount': unReadMessagesCount ?? 0,
      'lastMessageType': lastMessageType ?? 'text',
      'groupAdminId': groupAdminId ?? '',
      'groupAdmins': groupAdmins ?? [],
      'pinnedMessages': pinnedMessages ?? [],
      'description': description ?? '',
      'archive': archive ?? false,
      'pinChat': pinChat ?? false,
    });
  }
}
