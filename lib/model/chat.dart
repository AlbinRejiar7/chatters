import 'package:get/get.dart';

enum MessageType { text, image, video }

class ChatModel {
  String? id; // Unique ID for the message
  String? senderId; // ID of the sender
  String? senderName; // Name of the sender
  String? message; // The message text
  DateTime? timestamp; // Time the message was sent
  bool? isSentByMe; // Whether the message is sent by the current user
  bool? isRead; // Whether the message has been read
  MessageType? messageType; // Type of the message (text, image, etc.)
  RxBool? isSend = false.obs;
  ChatModel({
    this.id,
    this.senderId,
    this.senderName,
    this.message,
    this.timestamp,
    this.isSentByMe,
    this.isRead,
    this.messageType,
    this.isSend,
  });

  // Factory method to create a ChatModel from JSON
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
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
    );
  }

  // Convert ChatModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp?.toIso8601String(),
      'isSentByMe': isSentByMe,
      'isRead': isRead,
      'messageType': messageType?.toString().split('.').last,
    };
  }
}
