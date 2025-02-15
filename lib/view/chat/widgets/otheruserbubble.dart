import 'package:chatter/constants/colors.dart';
import 'package:chatter/controller/chat.dart';
import 'package:chatter/model/chat.dart';
import 'package:chatter/utils/format_time.dart';
import 'package:chatter/utils/is_only_emoji.dart';
import 'package:chatter/utils/sizedboxwidget.dart';
import 'package:chatter/view/chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Otheruserbubble extends StatelessWidget {
  final ChatModel chat;
  final ChatModel? previous;
  final ChatModel? next;
  final String chatroomId;
  const Otheruserbubble(
      {super.key,
      required this.chat,
      required this.previous,
      required this.next,
      required this.chatroomId});

  @override
  Widget build(BuildContext context) {
    var ctr = Get.find<ChatPageController>();
    if (chat.isRead == null) {
      ctr.markMessageAsRead(chatroomId, chat.id ?? "");
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 7.h),
      margin: EdgeInsets.only(
        top: 3,
        bottom: shouldAddBottomSpacing(chat, previous, next) ? 15 : 1,
        right: 100,
        left: 8,
      ),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Shadow color
            blurRadius: 5, // Soft blur effect
            spreadRadius: 1, // How much the shadow spreads
          ),
        ],
        color: AppColors.primaryLight,
        borderRadius: buildMessageBubbleRadius(
          chat,
          previous,
          next,
          false,
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          Text(
            chat.message ?? '',
            style: TextStyle(
              color: Colors.black,
              fontSize: isOnlyEmojis(chat.message ?? '') ? 28.sp : 14.sp,
            ),
          ),
          kWidth(10.w),
          Text(
            formatTime(chat.timestamp),
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.darkColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Determines if the bottom spacing should be added to the bubble.
bool shouldAddBottomSpacing(
  ChatModel chat,
  ChatModel? previous,
  ChatModel? next,
) {
  return (previous?.senderId != chat.senderId &&
      next?.senderId == chat.senderId);
}
