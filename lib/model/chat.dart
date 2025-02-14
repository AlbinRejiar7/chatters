import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'chat.g.dart'; // Required for generating Hive adapter code

@HiveType(typeId: 1) // Unique type ID for Hive
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

  @HiveField(19)
  DateTime? createdAt; // New field added

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
    this.createdAt, // Initialize new field
  });

  // Factory to parse JSON
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id']?.toString(),
      senderId: json['senderId']?.toString(),
      senderName: json['senderName']?.toString(),
      receiverId: json['receiverId']?.toString(),
      message: json['message']?.toString(),
      timestamp: _parseTimestamp(json['timestamp']),
      createdAt: _parseTimestamp(json['createdAt']), // Parsing createdAt
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

  // Helper function to parse timestamps
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value);
    } else {
      return null;
    }
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
      'createdAt': Timestamp.fromDate(
          createdAt ?? DateTime.now()), // Include createdAt in JSON
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
      'isSend': isSend,
    };
  }

  /// **🔹 copyWith method**
  /// Allows updating specific fields while keeping others unchanged.
  ChatModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? message,
    DateTime? timestamp,
    bool? isSentByMe,
    bool? isRead,
    MessageType? messageType,
    String? mediaUrl,
    String? thumbnailUrl,
    String? fileName,
    String? fileSize,
    Map<String, double>? location,
    bool? isDeleted,
    bool? isSend,
    List<String>? reactions,
    List<String>? mentions,
    String? replyToMessageId,
    DateTime? createdAt, // Add createdAt to copyWith
  }) {
    return ChatModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt, // Assign createdAt
      isSentByMe: isSentByMe ?? this.isSentByMe,
      isRead: isRead ?? this.isRead,
      messageType: messageType ?? this.messageType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      location: location ?? this.location,
      isDeleted: isDeleted ?? this.isDeleted,
      isSend: isSend ?? this.isSend,
      reactions: reactions ?? this.reactions,
      mentions: mentions ?? this.mentions,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
    );
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
