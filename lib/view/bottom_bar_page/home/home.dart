import 'package:chatter/constants/colors.dart';
import 'package:chatter/utils/navigation.dart';
import 'package:chatter/utils/responsive.dart';
import 'package:chatter/utils/sizedboxwidget.dart';
import 'package:chatter/view/chat/chat.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: ListView.separated(
        separatorBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(left: getResponsiveWidth(72)),
          child: Divider(
            thickness: 0.2,
            height: 14,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        itemCount: 20,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            minTileHeight: 0,
            onTap: () {
              CustomNavigator.getToPage(ChatPage());
            },
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryColor,
            ),
            title: Text(
              "Albin",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                getChatStatusWhiteIcon('seen', context),
                kWidth(getResponsiveWidth(3)),
                Text(
                  "hiii",
                  style: Theme.of(context).primaryTextTheme.labelSmall,
                ),
              ],
            ),
            trailing: Text(
              "12:57",
              style: Theme.of(context).primaryTextTheme.labelSmall,
            ),
          );
        },
      ),
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