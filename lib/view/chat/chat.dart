import 'dart:io';

import 'package:chatter/constants/colors.dart';
import 'package:chatter/controller/chat.dart';
import 'package:chatter/controller/set_profile.dart';
import 'package:chatter/model/chat.dart';
import 'package:chatter/services/chat_service.dart';
import 'package:chatter/services/firebase_storage.dart';
import 'package:chatter/services/local_service.dart';
import 'package:chatter/utils/format_time.dart';
import 'package:chatter/utils/sizedboxwidget.dart';
import 'package:chatter/view/chat/widgets/plus_icon.dart';
import 'package:chatter/widgets/chat_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatelessWidget {
  final String name;
  final String chatRoomId;
  final String receiverId;
  const ChatPage(
      {super.key,
      required this.name,
      required this.chatRoomId,
      required this.receiverId});

  @override
  Widget build(BuildContext context) {
    final ctr = Get.put(ChatPageController(chatRoomId: chatRoomId));
    final SetProfileController controller = Get.put(SetProfileController());
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: ChatAppBar(
        name: name,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                reverse: true,
                // key: ctr
                //     .listKey, // Optional: Remove this if not required for normal ListView
                // controller: ctr.scrollController,
                itemCount: ctr.sampleChats.length,
                itemBuilder: (context, index) {
                  final chat = ctr.sampleChats.reversed.toList()[index];
                  chat.isSentByMe = chat.senderId == LocalService.userId;
                  final ChatModel? previous =
                      index > 0 ? ctr.sampleChats[index - 1] : null;
                  final ChatModel? next = index < ctr.sampleChats.length - 1
                      ? ctr.sampleChats[index + 1]
                      : null;

                  // Check if this message should display a date header
                  // final bool showDateHeader = previous == null ||
                  //     !isSameDay(chat.timestamp, previous.timestamp);

                  return Column(
                    children: [
                      // Uncomment for date headers:
                      // if (showDateHeader) ...[
                      //   Center(
                      //     child: Padding(
                      //       padding: const EdgeInsets.only(bottom: 5),
                      //       child: Text(formatDate(chat.timestamp),
                      //           style: Theme.of(context)
                      //               .textTheme
                      //               .bodyLarge
                      //               ?.copyWith(fontWeight: FontWeight.normal)),
                      //     ),
                      //   ),
                      // ],

                      GetBuilder<ChatPageController>(builder: (__) {
                        return chat.messageType == MessageType.image
                            ? Row(
                                mainAxisAlignment: (chat.isSentByMe ?? false)
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  chat.isSend ?? false
                                      ? Image.network(
                                          chat.mediaUrl ?? "",
                                          height: 200,
                                        )
                                      : CupertinoActivityIndicator(
                                          radius: 50,
                                          color: AppColors.primaryColor,
                                        ),
                                ],
                              )
                            : SizedBox(
                                width: context.width,
                                child: TextMessageBubble(
                                  chat: chat,
                                  previous: previous,
                                  next: next,
                                ),
                              );
                      }),
                    ],
                  );
                },
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(8.w),
            child: Row(
              children: [
                SendTextField(ctr: ctr),
                kWidth((13.w)),
                SendMicButton(
                  isSend: true,
                  onTap: () async {
                    if (ctr.messageController.text.trim().isNotEmpty) {
                      var message = ChatModel(
                        id: const Uuid().v4(),
                        senderId: LocalService.userId,
                        senderName: LocalService.userName,
                        message: ctr.messageController.text.trim(),
                        timestamp: DateTime.now(),
                        isSentByMe: true,
                        isRead: false,
                        isSend: false,
                        mediaUrl: "",
                        messageType: MessageType.image,
                        receiverId: receiverId,
                      );
                      ctr.sampleChats.add(message);
                      // await Future.delayed(
                      //   const Duration(milliseconds: 10),
                      //   () {},
                      // );
                      var mediaUrl =
                          await FirebaseStorageSerivce.uploadUserImage(
                        phoneNumber: message.receiverId ?? "",
                        imageFile: File(controller.profileImage.value!.path),
                      );
                      message.isSend = true;
                      message.mediaUrl = mediaUrl;
                      ChatRoomService.sendMessage(
                              chatRoomId: chatRoomId, message: message)
                          .then(
                        (value) {
                          if (value) {
                            ctr.update();
                          }
                        },
                      );
                      ctr.messageController.clear();
                    }
                  },
                ),
                Obx(
                  () => GestureDetector(
                    onTap: controller.pickImage,
                    child: CircleAvatar(
                      radius: 50.r,
                      backgroundColor: AppColors.greyColor,
                      backgroundImage: controller.profileImage.value != null
                          ? FileImage(
                              File(controller.profileImage.value!.path),
                            )
                          : null,
                      child: controller.profileImage.value == null
                          ? Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: AppColors.primaryColor,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // AudioBubble(filepath: 'asdasdasdasd'),
        ],
      ),
    );
  }
}

class SendTextField extends StatelessWidget {
  const SendTextField({
    super.key,
    required this.ctr,
  });

  final ChatPageController ctr;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 15.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: AppColors.primaryLight),
        child: Column(
          children: [
            TextField(
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.darkColor),
              cursorHeight: 16.h,
              minLines: 1,
              maxLines: 4,
              cursorColor: AppColors.primaryColor,
              controller: ctr.messageController,
              decoration: InputDecoration(
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.normal),
                contentPadding: const EdgeInsets.all(0),
                isDense: true,
                hintText: "message",
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TextMessageBubble extends StatelessWidget {
  final ChatModel chat;
  final ChatModel? previous;
  final ChatModel? next;

  const TextMessageBubble({
    super.key,
    required this.chat,
    required this.previous,
    required this.next,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: chat.isSentByMe ?? false
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          margin: !(chat.isSentByMe ?? false)
              ? EdgeInsets.only(
                  top: 1,
                  bottom: (previous?.senderId == chat.senderId &&
                              next?.senderId != chat.senderId) ||
                          (previous?.senderId != chat.senderId &&
                              next?.senderId != chat.senderId)
                      ? 10
                      : 1,
                  right: chat.isSentByMe ?? false ? (8.w) : (100.w),
                  left: chat.isSentByMe ?? false ? (100.w) : (8.w))
              : EdgeInsets.only(
                  top: 1,
                  bottom: (previous?.senderId == chat.senderId &&
                              next?.senderId != chat.senderId) ||
                          (previous?.senderId != chat.senderId &&
                              next?.senderId != chat.senderId)
                      ? 10
                      : 1,
                  right: chat.isSentByMe ?? false ? 8 : 100,
                  left: chat.isSentByMe ?? false ? 100 : 8),
          decoration: BoxDecoration(
            color: chat.isSentByMe ?? false
                ? AppColors.primaryColor
                : AppColors.primaryLight,
            borderRadius: buildMessageBubbleRadius(
              chat,
              previous,
              next,
              chat.isSentByMe ?? false,
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text(
                chat.message ?? '',
                style: TextStyle(
                  color: chat.isSentByMe ?? false ? Colors.white : Colors.black,
                ),
              ),
              kWidth(context.width * 0.02),
              Visibility(
                visible: chat.isSentByMe ?? false,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    Text(
                      formatTime(chat.timestamp),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: chat.isSentByMe ?? false
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                    kWidth(context.width * 0.01),
                    getChatStatusIcon(
                        chat.isSend ?? false ? 'send' : 'sending', context),
                  ],
                ),
              )
            ],
          ),
        ),
        // if (chat.isSentByMe ?? false)
        //   Obx(() {
        //     return !(chat.isSend?.value ?? false)
        //         ? Icon(
        //             Icons.schedule,
        //             size: 10,
        //           )
        //         : SizedBox.shrink();
        //   })
      ],
    );
  }
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