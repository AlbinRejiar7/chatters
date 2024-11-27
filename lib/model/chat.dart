import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/adapters.dart';

part 'chat.g.dart';

@HiveType(typeId: 1)
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

@HiveType(typeId: 0)
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

  // Factory method to create a ChatModel from JSON
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
        id: json['id'],
        senderId: json['senderId'],
        senderName: json['senderName'],
        receiverId: json['receiverId'],
        message: json['message'],
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'])
            : null,
        isSentByMe: json['isSentByMe'],
        isRead: json['isRead'],
        messageType: json['messageType'] != null
            ? MessageType.values.firstWhere(
                (e) => e.toString() == 'MessageType.${json['messageType']}',
              )
            : null,
        mediaUrl: json['mediaUrl'],
        thumbnailUrl: json['thumbnailUrl'],
        fileName: json['fileName'],
        fileSize: json['fileSize'],
        location: json['location'] != null
            ? Map<String, double>.from(json['location'])
            : null,
        isDeleted: json['isDeleted'],
        reactions: json['reactions'] != null
            ? List<String>.from(json['reactions'])
            : [],
        mentions:
            json['mentions'] != null ? List<String>.from(json['mentions']) : [],
        replyToMessageId: json['replyToMessageId'],
        isSend: json['isSend'] != null ? (json['isSend']) : false);
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
      'isSend': isSend
    };
  }
}
