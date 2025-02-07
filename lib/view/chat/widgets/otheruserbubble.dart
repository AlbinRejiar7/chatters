import 'package:chatter/constants/colors.dart';
import 'package:chatter/model/chat.dart';
import 'package:chatter/view/chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Otheruserbubble extends StatefulWidget {
  final ChatModel chat;
  final ChatModel? previous;
  final ChatModel? next;
  const Otheruserbubble(
      {super.key,
      required this.chat,
      required this.previous,
      required this.next});

  @override
  State<Otheruserbubble> createState() => _OtheruserbubbleState();
}

class _OtheruserbubbleState extends State<Otheruserbubble> {
  @override
  void initState() {
    super.initState();
    // if (widget.chat.isRead == null ||
    //     (widget.chat.isRead == false) &&
    //         (widget.chat.senderId != LocalService.userId)) {
    //   log("message chaning.........");
    //   ChatRoomService.setReadToTrue(
    //       senderId: widget.chat.senderId ?? "",
    //       messageId: widget.chat.id ?? "");
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 7.h),
      margin: EdgeInsets.only(
        top: 1,
        bottom:
            shouldAddBottomSpacing(widget.chat, widget.previous, widget.next)
                ? 10
                : 1,
        right: 100,
        left: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: buildMessageBubbleRadius(
          widget.chat,
          widget.previous,
          widget.next,
          false,
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          Text(
            widget.chat.message ?? '',
            style: const TextStyle(color: Colors.black),
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
      next?.senderId != chat.senderId);
}
