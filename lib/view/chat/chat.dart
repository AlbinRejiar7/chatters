import 'package:chatter/constants/colors.dart';
import 'package:chatter/controller/chat.dart';
import 'package:chatter/controller/set_profile.dart';
import 'package:chatter/model/chat.dart';
import 'package:chatter/services/chat_service.dart';
import 'package:chatter/services/local_service.dart';
import 'package:chatter/utils/format_time.dart';
import 'package:chatter/utils/sizedboxwidget.dart';
import 'package:chatter/view/chat/widgets/delete.dart';
import 'package:chatter/view/chat/widgets/otheruserbubble.dart';
import 'package:chatter/view/chat/widgets/plus_icon.dart';
import 'package:chatter/widgets/chat_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatPage extends StatelessWidget {
  final String name;
  final String receiverId;
  final int unreadCount;
  final List<ChatModel> lastMessages;
  const ChatPage(
      {super.key,
      required this.name,
      required this.receiverId,
      required this.unreadCount,
      required this.lastMessages});

  @override
  Widget build(BuildContext context) {
    final chatRoomId = ChatRoomService.getConversationID(receiverId);
    final ctr = Get.put(ChatPageController(
      receiverId,
      unreadCount,
      lastMessages,
      chatRoomId: chatRoomId,
    ));
    final SetProfileController controller = Get.put(SetProfileController());
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: ChatAppBar(
        chatRoomId: chatRoomId,
        name: name,
      ),
      body: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          ChatRoomService.setActiveChatId('');
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Obx(
                () => ctr.sampleChats.isEmpty
                    ? Center(
                        child: Text(
                          textAlign: TextAlign.center,
                          "Send your first message!!",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        // key: ctr
                        //     .listKey, // Optional: Remove this if not required for normal ListView
                        // controller: ctr.scrollController,
                        itemCount: ctr.sampleChats.length,
                        itemBuilder: (context, index) {
                          var reversedChat = ctr.sampleChats.toList();

                          final chat = reversedChat[index];
                          chat.isSentByMe =
                              chat.senderId == LocalService.userId;
                          final ChatModel? previous =
                              index > 0 ? reversedChat[index - 1] : null;
                          final ChatModel? next =
                              index < reversedChat.length - 1
                                  ? reversedChat[index + 1]
                                  : null;

                          // Check if this message should display a date header
                          // final bool showDateHeader = previous == null ||
                          //     !isSameDay(chat.timestamp, previous.timestamp);
                          // if (chat.senderId == LocalService.userId) {
                          //   if (chat.isRead == false) {
                          //     ChatRoomService.setReadToTrue(receiverId, chat.id ?? "");
                          //   }
                          // }
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
                                        mainAxisAlignment:
                                            (chat.isSentByMe ?? false)
                                                ? MainAxisAlignment.end
                                                : MainAxisAlignment.start,
                                        children: [
                                          chat.isSend ?? false
                                              ? Image.network(
                                                  chat.mediaUrl ?? "",
                                                  height: 200,
                                                )
                                              : const CupertinoActivityIndicator(
                                                  radius: 50,
                                                  color: AppColors.primaryColor,
                                                ),
                                        ],
                                      )
                                    : GestureDetector(
                                        onLongPress: () {
                                          showDeleteMessageDialog(context,
                                              chatRoomId, chat.id ?? '');
                                        },
                                        child: SizedBox(
                                          width: context.width,
                                          child: TextMessageBubble(
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

            Padding(
              padding: EdgeInsets.all(8.w),
              child: Row(
                children: [
                  SendTextField(ctr: ctr),
                  kWidth((13.w)),
                  SendMicButton(
                    isSend: true,
                    onTap: () {
                      ctr.sendMessage();
                    },
                  ),
                ],
              ),
            ),
            // AudioBubble(filepath: 'asdasdasdasd'),
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
  final String chatRoomId;
  const TextMessageBubble({
    super.key,
    required this.chat,
    required this.previous,
    required this.next,
    required this.chatRoomId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: chat.isSentByMe ?? false
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        chat.isSentByMe ?? false
            ? buildSenderBubble(context, chat)
            : Otheruserbubble(chat: chat, previous: previous, next: next),
      ],
    );
  }

  /// Builds the bubble for messages sent by the user.
  Widget buildSenderBubble(BuildContext context, ChatModel chat) {
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
          Text(
            chat.message ?? '',
            style: const TextStyle(color: Colors.white),
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
