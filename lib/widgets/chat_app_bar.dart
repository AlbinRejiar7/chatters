import 'dart:ui';

import 'package:chatter/constants/colors.dart';
import 'package:chatter/constants/light_font_style.dart';
import 'package:chatter/controller/chat.dart';
import 'package:chatter/services/local_chat.dart';
import 'package:chatter/utils/sizedboxwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final String chatRoomId;
  const ChatAppBar({super.key, required this.name, required this.chatRoomId});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: BackButton(
            style: const ButtonStyle(
              iconSize: WidgetStatePropertyAll(18),
            ),
            color: Theme.of(context).primaryColor,
          ),
          backgroundColor: Colors.transparent, // Transparent background
          surfaceTintColor: Colors.transparent,
          elevation: 0, // Remove shadow
          title: Row(
            children: [
              CircleAvatar(
                radius: 17.r,
                backgroundColor: AppColors.primaryColor,
              ),
              SizedBox(width: (8.w)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    "online",
                    style: Theme.of(context).primaryTextTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Icon(
              IconlyLight.video,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            kWidth((22.w)),
            Icon(
              Iconsax.call,
              size: 17,
              color: Theme.of(context).primaryColor,
            ),
            PopupMenuButton(
              padding: EdgeInsets.zero,
              menuPadding: EdgeInsets.zero,
              offset: const Offset(-20, 50),
              icon: Icon(
                Icons.more_vert_outlined,
                size: 22,
                color: Theme.of(context).primaryColor,
              ),
              color: AppColors.whiteColor,
              itemBuilder: (context) => [
                PopupMenuItem(
                    child: Text(
                  'All media',
                  style: LightFontStyle.textMedium,
                )),
                PopupMenuItem(
                    child: Text(
                  'Chat settings',
                  style: LightFontStyle.textMedium,
                )),
                PopupMenuItem(
                    child: Text(
                  'Search',
                  style: LightFontStyle.textMedium,
                )),
                PopupMenuItem(
                    onTap: () async {
                      await ChatStorageService.clearMessages(chatRoomId);
                    },
                    child: Text(
                      'Clear chat',
                      style: LightFontStyle.textMedium,
                    )),
                PopupMenuItem(
                    child: Text(
                  'Mute notification',
                  style: LightFontStyle.textMedium,
                )),
              ],
            ),
          ],
          titleSpacing: 0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
