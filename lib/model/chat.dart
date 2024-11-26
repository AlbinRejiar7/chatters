import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

enum MessageType { text, image, video, audio, file, location }

class ChatModel {
  String? id; // Unique ID for the message
  String? senderId; // ID of the sender
  String? senderName; // Name of the sender
  String? receiverId; // ID of the receiver
  String? message; // The message text
  DateTime? timestamp; // Time the message was sent
  bool? isSentByMe; // Whether the message is sent by the current user
  bool? isRead; // Whether the message has been read
  MessageType? messageType; // Type of the message (text, image, etc.)
  String? mediaUrl; // URL for images, videos, or other media
  String? thumbnailUrl; // URL for video thumbnails
  String? fileName; // For file-type messages
  String? fileSize; // For file-size details
  Map<String, double>?
      location; // For location-based messages (latitude, longitude)
  bool? isDeleted; // Whether the message has been deleted
  RxBool? isSend = false.obs; // Observing send status
  List<String>? reactions; // List of reactions (e.g., emoji strings)
  List<String>? mentions; // List of user IDs mentioned in the message
  String? replyToMessageId; // ID of the message being replied to

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
      timestamp:
          json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
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
      reactions:
          json['reactions'] != null ? List<String>.from(json['reactions']) : [],
      mentions:
          json['mentions'] != null ? List<String>.from(json['mentions']) : [],
      replyToMessageId: json['replyToMessageId'],
    );
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
      'createdAt': FieldValue.serverTimestamp()
    };
  }
}
