// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatModelAdapter extends TypeAdapter<ChatModel> {
  @override
  final int typeId = 1;

  @override
  ChatModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatModel(
      id: fields[0] as String?,
      senderId: fields[1] as String?,
      senderName: fields[2] as String?,
      receiverId: fields[3] as String?,
      message: fields[4] as String?,
      timestamp: fields[5] as DateTime?,
      isSentByMe: fields[6] as bool?,
      isRead: fields[7] as bool?,
      messageType: fields[8] as MessageType?,
      mediaUrl: fields[9] as String?,
      thumbnailUrl: fields[10] as String?,
      fileName: fields[11] as String?,
      fileSize: fields[12] as String?,
      location: (fields[13] as Map?)?.cast<String, double>(),
      isDeleted: fields[14] as bool?,
      isSend: fields[15] as bool?,
      reactions: (fields[16] as List?)?.cast<String>(),
      mentions: (fields[17] as List?)?.cast<String>(),
      replyToMessageId: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.senderId)
      ..writeByte(2)
      ..write(obj.senderName)
      ..writeByte(3)
      ..write(obj.receiverId)
      ..writeByte(4)
      ..write(obj.message)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.isSentByMe)
      ..writeByte(7)
      ..write(obj.isRead)
      ..writeByte(8)
      ..write(obj.messageType)
      ..writeByte(9)
      ..write(obj.mediaUrl)
      ..writeByte(10)
      ..write(obj.thumbnailUrl)
      ..writeByte(11)
      ..write(obj.fileName)
      ..writeByte(12)
      ..write(obj.fileSize)
      ..writeByte(13)
      ..write(obj.location)
      ..writeByte(14)
      ..write(obj.isDeleted)
      ..writeByte(15)
      ..write(obj.isSend)
      ..writeByte(16)
      ..write(obj.reactions)
      ..writeByte(17)
      ..write(obj.mentions)
      ..writeByte(18)
      ..write(obj.replyToMessageId)
      ..writeByte(19);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageTypeAdapter extends TypeAdapter<MessageType> {
  @override
  final int typeId = 2;

  @override
  MessageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageType.text;
      case 1:
        return MessageType.image;
      case 2:
        return MessageType.video;
      case 3:
        return MessageType.audio;
      case 4:
        return MessageType.file;
      case 5:
        return MessageType.location;
      default:
        return MessageType.text;
    }
  }

  @override
  void write(BinaryWriter writer, MessageType obj) {
    switch (obj) {
      case MessageType.text:
        writer.writeByte(0);
        break;
      case MessageType.image:
        writer.writeByte(1);
        break;
      case MessageType.video:
        writer.writeByte(2);
        break;
      case MessageType.audio:
        writer.writeByte(3);
        break;
      case MessageType.file:
        writer.writeByte(4);
        break;
      case MessageType.location:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
