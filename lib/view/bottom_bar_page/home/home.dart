import 'package:chatter/constants/colors.dart';
import 'package:chatter/controller/home.dart';
import 'package:chatter/model/chat_room_detail.dart';
import 'package:chatter/services/local_service.dart';
import 'package:chatter/utils/sizedboxwidget.dart';
import 'package:chatter/view/chat/chat.dart';
import 'package:chatter/widgets/profile_pic_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var ctr = Get.put(HomeController());
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Obx(() {
        return ListView.separated(
          separatorBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(left: (72.w)),
            child: Divider(
              thickness: 0.2,
              height: 14,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          itemCount: ctr.chatRooms.length,
          itemBuilder: (BuildContext context, int index) {
            var chat = ctr.chatRooms[index];
            return CustomUserTile(
              currentContactNumberasId: chat.participants
                      ?.firstWhere(
                        (element) => element != LocalService.userId,
                      )
                      .toString() ??
                  "",
              chatRoomDetailModel: chat,
            );
          },
        );
      }),
    );
  }
}

class CustomUserTile extends StatelessWidget {
  final ChatRoomDetailModel chatRoomDetailModel;
  final String currentContactNumberasId;
  const CustomUserTile({
    super.key,
    required this.chatRoomDetailModel,
    required this.currentContactNumberasId,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 0,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
      onTap: () {
        Get.to(
            () => ChatPage(
                  image: chatRoomDetailModel.chatRoomImage ?? "",
                  lastMessages: chatRoomDetailModel.lastMessages ?? [],
                  unreadCount: chatRoomDetailModel
                          .unReadMessagesCountMap?["${LocalService.userId}"] ??
                      0,
                  receiverId: currentContactNumberasId,
                  name: chatRoomDetailModel.chatRoomName ?? "",
                ),
            transition: Transition.cupertino);
      },
      leading: ProfilePictureViewer(
          imageUrl: chatRoomDetailModel.chatRoomImage ?? "",
          heroTag: "${chatRoomDetailModel.chatRoomId}"),
      // leading:
      title: Text(
        chatRoomDetailModel.chatRoomName ?? "",
        style: Theme.of(context).textTheme.bodySmall,
      ),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          getChatStatusWhiteIcon('seen', context),
          kWidth((3.w)),
          Text(
            chatRoomDetailModel.lastMessage?.message ?? "",
            style: Theme.of(context).primaryTextTheme.labelSmall,
          ),
        ],
      ),
      trailing: Visibility(
          visible: chatRoomDetailModel
                      .unReadMessagesCountMap?["${LocalService.userId}"] !=
                  0 &&
              chatRoomDetailModel
                      .unReadMessagesCountMap?["${LocalService.userId}"] !=
                  null,
          child: CircleAvatar(
            radius: 8,
            backgroundColor: AppColors.primaryColor,
            child: Center(
              child: Text(
                chatRoomDetailModel
                        .unReadMessagesCountMap?["${LocalService.userId}"]
                        .toString() ??
                    "",
                style: Theme.of(context)
                    .primaryTextTheme
                    .bodyMedium!
                    .copyWith(fontSize: 8.sp, fontWeight: FontWeight.bold),
              ),
            ),
          )),
    );
  }
}

Icon getChatStatusWhiteIcon(
  String status,
  BuildContext context,
) {
  switch (status.toLowerCase()) {
    case "send":
      return Icon(
        Icons.done,
        size: 14,
        color: Theme.of(context).colorScheme.secondary,
      ); // Single tick
    case "get":
      return Icon(
        Icons.done_all_rounded,
        color: Theme.of(context).colorScheme.secondary,
        size: 14,
      ); // Double tick
    case "seen":
      return Icon(
        Icons.done_all_rounded,
        color: Theme.of(context).colorScheme.onSecondary,
        size: 14,
      ); //// Blue double tick
    default:
      return Icon(
        Icons.error,
        color: AppColors.whiteColor,
        size: 14,
      ); // // Default status for unknown or pending
  }
}
