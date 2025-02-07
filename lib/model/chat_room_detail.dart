import 'package:chatter/model/chat.dart';
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
  List<ChatModel>? lastMessages; // Added List of ChatModel for lastMessages
  ChatModel? lastMessage; // Integrated ChatModel for the latest message
  Map<String, int>? unReadMessagesCountMap;
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
    this.lastMessages,
    this.lastMessage,
    this.unReadMessagesCountMap,
    this.lastMessageType,
    this.receiverId,
    this.groupAdminId,
    this.groupAdmins,
    this.pinnedMessages,
    this.description,
    this.archive,
    this.pinChat,
  });

  // Factory to parse data from a Map
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
          : [],
      lastMessages: map['lastMessages'] != null
          ? List<ChatModel>.from((map['lastMessages'] as List)
              .map((e) => ChatModel.fromJson(e as Map<String, dynamic>)))
          : [],
      lastMessage: map['lastMessage'] != null
          ? ChatModel.fromJson(map['lastMessage'] as Map<String, dynamic>)
          : null,
      unReadMessagesCountMap: map['unReadMessagesCount'] != null
          ? Map<String, int>.from(map['unReadMessagesCount'] as Map)
          : {},
      lastMessageType: map['lastMessageType'] as String?,
      receiverId: map['receiverId'] as String?,
      groupAdminId: map['groupAdminId'] as String?,
      groupAdmins: map['groupAdmins'] != null
          ? List<String>.from(map['groupAdmins'] as List)
          : [],
      pinnedMessages: map['pinnedMessages'] != null
          ? List<String>.from(map['pinnedMessages'] as List)
          : [],
      description: map['description'] as String?,
      archive: map['archive'] as bool?,
      pinChat: map['pinChat'] as bool?,
    );
  }

  // Convert the model to a Map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'isGroup': isGroup,
      'chatRoomName': chatRoomName,
      'chatRoomImage': chatRoomImage,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'participants': participants ?? [],
      'lastMessages': lastMessages != null
          ? lastMessages!.map((message) => message.toJson()).toList()
          : [],
      'lastMessage': lastMessage?.toJson(),
      'unReadMessagesCount': unReadMessagesCountMap,
      'lastMessageType': lastMessageType,
      'receiverId': receiverId,
      'groupAdminId': groupAdminId,
      'groupAdmins': groupAdmins ?? [],
      'pinnedMessages': pinnedMessages ?? [],
      'description': description,
      'archive': archive ?? false,
      'pinChat': pinChat ?? false,
    };
  }

  // Method to save data with server timestamps
  Future<void> saveChatRoom(String chatRoomId) async {
    FirebaseFirestore.instance.collection('chatRooms').doc(chatRoomId).set({
      'chatRoomId': chatRoomId,
      'isGroup': isGroup ?? false,
      'chatRoomName': chatRoomName ?? '',
      'chatRoomImage': chatRoomImage ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'participants': participants ?? [],
      'lastMessages': lastMessages != null
          ? lastMessages!.map((message) => message.toJson()).toList()
          : [],
      'lastMessage': lastMessage?.toJson() ?? {},
      'unReadMessagesCount': unReadMessagesCountMap ?? {},
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
