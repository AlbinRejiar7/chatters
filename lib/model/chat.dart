import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'chat.g.dart'; // Required for generating Hive adapter code

@HiveType(typeId: 1) // Specify a unique type ID for Hive
class ChatModel {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? senderId;

  @HiveField(2)
  String? senderName;

  @HiveField(3)
  String? receiverId;

  @HiveField(4)
  String? message;

  @HiveField(5)
  DateTime? timestamp;

  @HiveField(6)
  bool? isSentByMe;

  @HiveField(7)
  bool? isRead;

  @HiveField(8)
  MessageType? messageType;

  @HiveField(9)
  String? mediaUrl;

  @HiveField(10)
  String? thumbnailUrl;

  @HiveField(11)
  String? fileName;

  @HiveField(12)
  String? fileSize;

  @HiveField(13)
  Map<String, double>? location;

  @HiveField(14)
  bool? isDeleted;

  @HiveField(15)
  bool? isSend;

  @HiveField(16)
  List<String>? reactions;

  @HiveField(17)
  List<String>? mentions;

  @HiveField(18)
  String? replyToMessageId;

  ChatModel({
    this.id,
    this.senderId,
    this.senderName,
    this.receiverId,
    this.message,
    this.timestamp,
    this.isSentByMe,
    this.isRead,
    this.messageType,
    this.mediaUrl,
    this.thumbnailUrl,
    this.fileName,
    this.fileSize,
    this.location,
    this.isDeleted,
    this.isSend,
    this.reactions,
    this.mentions,
    this.replyToMessageId,
  });

  // Factory to parse JSON with added type safety
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id']?.toString(),
      senderId: json['senderId']?.toString(),
      senderName: json['senderName']?.toString(),
      receiverId: json['receiverId']?.toString(),
      message: json['message']?.toString(),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
      isSentByMe: json['isSentByMe'] as bool?,
      isRead: json['isRead'] as bool?,
      messageType: json['messageType'] != null
          ? _parseMessageType(json['messageType'])
          : null,
      mediaUrl: json['mediaUrl']?.toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      fileName: json['fileName']?.toString(),
      fileSize: json['fileSize']?.toString(),
      location: json['location'] != null
          ? Map<String, double>.from(json['location'] as Map)
          : null,
      isDeleted: json['isDeleted'] as bool?,
      reactions: json['reactions'] != null
          ? List<String>.from(json['reactions'] as List)
          : [],
      mentions: json['mentions'] != null
          ? List<String>.from(json['mentions'] as List)
          : [],
      replyToMessageId: json['replyToMessageId']?.toString(),
      isSend: json['isSend'] as bool? ?? false,
    );
  }

  // Helper to parse MessageType safely
  static MessageType? _parseMessageType(dynamic type) {
    try {
      return MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${type.toString()}',
      );
    } catch (_) {
      return null;
    }
  }

  // Convert ChatModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp?.toIso8601String(),
      'isSentByMe': isSentByMe,
      'isRead': isRead,
      'messageType': messageType?.toString().split('.').last,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'location': location,
      'isDeleted': isDeleted,
      'reactions': reactions,
      'mentions': mentions,
      'replyToMessageId': replyToMessageId,
      'createdAt': FieldValue.serverTimestamp(),
      'isSend': isSend,
    };
  }
}

@HiveType(typeId: 2)
enum MessageType {
  @HiveField(0)
  text,

  @HiveField(1)
  image,

  @HiveField(2)
  video,

  @HiveField(3)
  audio,

  @HiveField(4)
  file,

  @HiveField(5)
  location,
}
