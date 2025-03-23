import 'dart:async';

import 'package:chatter/constants/colors.dart';
import 'package:chatter/controller/chat.dart';
import 'package:chatter/controller/record_audio.dart';
import 'package:chatter/controller/user_online.dart';
import 'package:chatter/model/chat.dart';
import 'package:chatter/services/chat_service.dart';
import 'package:chatter/services/local_service.dart';
import 'package:chatter/utils/format_time.dart';
import 'package:chatter/utils/is_only_emoji.dart';
import 'package:chatter/utils/seconds.dart';
import 'package:chatter/utils/sizedboxwidget.dart';
import 'package:chatter/view/chat/widgets/delete.dart';
import 'package:chatter/view/chat/widgets/otheruserbubble.dart';
import 'package:chatter/view/chat/widgets/test.dart';
import 'package:chatter/widgets/chat_app_bar.dart';
import 'package:chatter/widgets/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/voice_bubble.dart';

class ChatPage extends StatelessWidget {
  final String image;
  final String name;
  final String receiverId;
  final int unreadCount;
  final List<ChatModel> lastMessages;
  ChatPage(
      {super.key,
      required this.name,
      required this.receiverId,
      required this.unreadCount,
      required this.lastMessages,
      required this.image});
  var audioRecorderCtr = Get.put(RecordAudioController());
  @override
  Widget build(BuildContext context) {
    final chatRoomId = ChatRoomService.getConversationID(receiverId);
    final ChatPageController ctr = Get.put(ChatPageController(
      receiverId,
      unreadCount,
      lastMessages,
      chatRoomId: chatRoomId,
    ));
    UserOnlineStatusController userStatusCtr =
        Get.put(UserOnlineStatusController(otherUserId: receiverId));

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: ChatAppBar(
        userImage: image,
        onlineStatus: Obx(() {
          return Text(
            userStatusCtr.lastSeenString.value,
            style: Theme.of(context).primaryTextTheme.labelSmall,
          );
        }),
        onTapClearChat: () {
          ctr.clearChat(chatRoomId);
        },
        chatRoomId: chatRoomId,
        name: name,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Obx(
                () => ctr.sampleChats.isEmpty
                    ? Center(
                        child: Text(
                          textAlign: TextAlign.center,
                          "Send your message!!",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        reverse: true,
                        itemCount: ctr.sampleChats.length +
                            (userStatusCtr.isTyping.value
                                ? 1
                                : 0), // Add 1 only if typing
                        itemBuilder: (context, index) {
                          // Show "typing..." at the 0th index if isTyping is true
                          if (userStatusCtr.isTyping.value && index == 0) {
                            return Obx(() {
                              return Padding(
                                padding: EdgeInsets.only(left: 10.w),
                                child: TypingIndicator(
                                  size: 0.7.w,
                                  bubbleColor: AppColors.primaryLight,
                                  flashingCircleBrightColor:
                                      AppColors.primaryLight,
                                  flashingCircleDarkColor:
                                      AppColors.primaryColor,
                                  showIndicator:
                                      userStatusCtr.lastSeenString.value ==
                                              "online" &&
                                          userStatusCtr.isTyping.value,
                                ),
                              );
                            });
                          }

                          // Adjust index if "typing..." is present
                          int adjustedIndex =
                              userStatusCtr.isTyping.value ? index - 1 : index;

                          var reversedChat = ctr.sampleChats.toList();
                          final chat = reversedChat[adjustedIndex];

                          chat.isSentByMe =
                              chat.senderId == LocalService.userId;
                          final ChatModel? previous = adjustedIndex > 0
                              ? reversedChat[adjustedIndex - 1]
                              : null;
                          final ChatModel? next =
                              adjustedIndex < reversedChat.length - 1
                                  ? reversedChat[adjustedIndex + 1]
                                  : null;

                          return Column(
                            children: [
                              GetBuilder<ChatPageController>(builder: (__) {
                                return GestureDetector(
                                  onLongPress: () {
                                    showDeleteMessageDialog(
                                        context, chatRoomId, chat.id ?? '');
                                  },
                                  child: SizedBox(
                                    width: context.width,
                                    child: MessageBubble(
                                      entity: chat.messageType?.name ?? "",
                                      chatRoomId: chatRoomId,
                                      chat: chat,
                                      previous: previous,
                                      next: next,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
              ),
            ),
            Row(
              children: [
                Obx(() {
                  return SendTextField(
                    ctr: ctr,
                    hintText: audioRecorderCtr.isRecording.value
                        ? formatDuration(
                            audioRecorderCtr.recordingDuration.value)
                        : "message",
                  );
                }),
                kWidth((5.w)),
                Obx(() {
                  return MicAnimationWidget(
                    isMic: !ctr.isCurrentlyTyping.value,
                    onLongPressStart: () async {
                      await audioRecorderCtr.toggleRecording();
                    },
                    onSendTap: () {
                      ctr.sendMessage(messageType: MessageType.text);
                    },
                    onLongPressRelease: () async {
                      await audioRecorderCtr.toggleRecording();
                      if (audioRecorderCtr.filePath.value.isNotEmpty) {
                        ctr.sendMessage(
                            messageType: MessageType.audio,
                            localPath: audioRecorderCtr.filePath.value,
                            waveformData: audioRecorderCtr.waveForms);
                      }
                    },
                    onSlideToCancel: () {
                      audioRecorderCtr.filePath.value = "";
                      print("Mic slid to the far left - Recording cancelled");
                    },
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SendTextField extends StatelessWidget {
  const SendTextField({
    super.key,
    required this.ctr,
    this.hintText,
  });

  final ChatPageController ctr;
  final String? hintText;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 15.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: AppColors.primaryLight),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.darkColor, fontSize: 14.sp),
                cursorHeight: 16.h,
                minLines: 1,
                maxLines: 4,
                cursorColor: AppColors.primaryColor,
                controller: ctr.messageController,
                onChanged: (value) {
                  bool isTypingNow = value.isNotEmpty;

                  // Update only if the typing state has changed
                  if (isTypingNow != ctr.isCurrentlyTyping.value) {
                    ctr.isCurrentlyTyping.value = isTypingNow;
                    ChatRoomService.updateIsTyping(
                        isTyping: ctr.isCurrentlyTyping.value,
                        chatroomId: ctr.chatRoomId);
                  }

                  // Reset the debounce timer
                  ctr.typingTimer?.cancel();

                  if (isTypingNow) {
                    // If user is typing, don't set a stop timer yet
                    return;
                  }

                  // If user stops typing, wait 1 second before marking as not typing
                  ctr.typingTimer = Timer(const Duration(seconds: 1), () {
                    if (!ctr.isCurrentlyTyping.value) {
                      ChatRoomService.updateIsTyping(
                          isTyping: false, chatroomId: ctr.chatRoomId);
                    }
                  });
                },
                decoration: InputDecoration(
                  hintStyle: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.normal),
                  isDense: true,
                  contentPadding: const EdgeInsets.all(0),
                  hintText: hintText,
                  border: InputBorder.none,
                ),
              ),
            ),
            InkWell(
              onTap: () {},
              child: const Icon(
                Icons.photo_library_rounded,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatModel chat;
  final ChatModel? previous;
  final ChatModel? next;
  final String chatRoomId;
  final String entity;
  const MessageBubble({
    super.key,
    required this.chat,
    required this.previous,
    required this.next,
    required this.chatRoomId,
    required this.entity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: chat.isSentByMe ?? false
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        chat.isSentByMe ?? false
            ? buildSenderBubble(context, chat, entity)
            : Otheruserbubble(
                entity: entity,
                chat: chat,
                previous: previous,
                next: next,
                chatroomId: chatRoomId,
              ),
      ],
    );
  }

  /// Builds the bubble for messages sent by the user.
  Widget buildSenderBubble(
      BuildContext context, ChatModel chat, String entity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      margin: EdgeInsets.only(
        top: 1,
        bottom: shouldAddBottomSpacing(chat, previous, next) ? 10 : 1,
        right: 8,
        left: 100,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Shadow color
            blurRadius: 5, // Soft blur effect
            spreadRadius: 1, // How much the shadow spreads
          ),
        ],
        borderRadius: buildMessageBubbleRadius(
          chat,
          previous,
          next,
          true,
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          if (entity == MessageType.text.name)
            Text(
              chat.message ?? '',
              style: TextStyle(
                color: Colors.white,
                fontSize: isOnlyEmojis(chat.message ?? '') ? 25.sp : 14.sp,
              ),
            ),
          if (entity == MessageType.audio.name)
            AudioBubble(
              isCurrentUser: true,
              waveData: chat.waveformData ?? [],
              isBlackColor: false,
              firebaseAudioPath: chat.fileName ?? "",
            ),
          kWidth(context.width * 0.02),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text(
                formatTime(chat.timestamp),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.white70,
                ),
              ),
              kWidth(context.width * 0.01),
              getChatStatusIcon(
                (chat.isRead ?? false)
                    ? "seen"
                    : (chat.isSend ?? false ? 'send' : 'sending'),
                context,
              ),
            ],
          )
        ],
      ),
    );
  }

  /// Builds the bubble for messages received from the other user.
  // Widget buildReceiverBubble(
  //     {required BuildContext context,
  //     required ChatModel chat,
  //     required ChatModel previous,
  //     required ChatModel next}) {
  //   // if (chat.isRead == null) {
  //   //   ChatRoomService.setReadToTrue(
  //   //       senderId: chat.senderId ?? "", messageId: chat.id ?? "");
  //   // }

  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 7.h),
  //     margin: EdgeInsets.only(
  //       top: 1,
  //       bottom: shouldAddBottomSpacing(chat, previous, next) ? 10 : 1,
  //       right: 100,
  //       left: 8,
  //     ),
  //     decoration: BoxDecoration(
  //       color: AppColors.primaryLight,
  //       borderRadius: buildMessageBubbleRadius(
  //         chat,
  //         previous,
  //         next,
  //         false,
  //       ),
  //     ),
  //     child: Wrap(
  //       alignment: WrapAlignment.start,
  //       crossAxisAlignment: WrapCrossAlignment.end,
  //       children: [
  //         Text(
  //           chat.message ?? '',
  //           style: const TextStyle(color: Colors.black),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

Icon getChatStatusIcon(
  String status,
  BuildContext context,
) {
  switch (status.toLowerCase()) {
    case "sending":
      return Icon(
        Icons.timer_outlined,
        size: 14,
        color: Theme.of(context).colorScheme.primary,
      ); // Single tick
    case "send":
      return Icon(
        Icons.done,
        size: 14,
        color: Theme.of(context).colorScheme.primary,
      ); // Single tick
    case "get":
      return Icon(
        Icons.done_all_rounded,
        color: Theme.of(context).colorScheme.primary,
        size: 14,
      ); // Double tick
    case "seen":
      return Icon(
        Icons.done_all_rounded,
        color: Theme.of(context).colorScheme.onPrimary,
        size: 14,
      ); //// Blue double tick
    default:
      return const Icon(
        Icons.error,
        color: AppColors.whiteColor,
        size: 14,
      ); // // Default status for unknown or pending
  }
}

BorderRadiusGeometry buildMessageBubbleRadius(
    ChatModel message, ChatModel? previous, ChatModel? next, bool isSentByMe) {
  String position;

  // Determine the position based on previous and next messages
  if (previous?.senderId != message.senderId &&
      next?.senderId != message.senderId) {
    position = 'standalone';
  } else if (previous?.senderId != message.senderId &&
      next?.senderId == message.senderId) {
    position = 'first';
  } else if (previous?.senderId == message.senderId &&
      next?.senderId == message.senderId) {
    position = 'middle';
  } else if (previous?.senderId == message.senderId &&
      next?.senderId != message.senderId) {
    position = 'last';
  } else {
    position = 'standalone';
  }

  // Return BorderRadius based on position
  if (isSentByMe) {
    switch (position) {
      case 'last':
        return const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(2),
        );
      case 'middle':
        return const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(3),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(3),
        );
      case 'first':
        return const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(2),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        );
      default: // 'standalone'
        return BorderRadius.circular(15);
    }
  } else {
    switch (position) {
      case 'last':
        return const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
          bottomLeft: Radius.circular(2),
          bottomRight: Radius.circular(15),
        );
      case 'middle':
        return const BorderRadius.only(
          topLeft: Radius.circular(3),
          topRight: Radius.circular(15),
          bottomLeft: Radius.circular(3),
          bottomRight: Radius.circular(15),
        );
      case 'first':
        return const BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(15),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        );
      default: // 'standalone'
        return BorderRadius.circular(15);
    }
  }
}
//  right: chat.isSentByMe ?? false
//                   ? (context: context, baseValue: 8)
//                   : (context: context, baseValue: 100),
//               left: chat.isSentByMe ?? false
//                   ? (context: context, baseValue: 100)
//                   : (context: context, baseValue: 8)),
