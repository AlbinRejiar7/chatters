import 'package:chatter/constants/colors.dart';
import 'package:chatter/constants/light_font_style.dart';
import 'package:chatter/controller/search.dart';
import 'package:chatter/services/local_service.dart';
import 'package:chatter/view/setting/logout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AnimatedSearchAppBar extends StatelessWidget
    implements PreferredSizeWidget {
    
  const AnimatedSearchAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchBarController searchController = Get.put(SearchBarController());
    return AppBar(
      automaticallyImplyLeading: false,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent, // Semi-transparent
      elevation: 0.0, // Remove shadow
      title: Obx(() {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(-1, 0), // Start from off-screen (left)
              end: Offset.zero, // Slide to its final position
            ).animate(animation);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          child: searchController.isSearching.value
              ? Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.r),
                      color: AppColors.primaryLight.withOpacity(0.7)),
                  child: TextField(
                    key: const ValueKey('search_field'),
                    autofocus: true,
                    style: Theme.of(context).textTheme.bodyMedium,
                    cursorHeight: 16,
                    cursorColor: Theme.of(context).colorScheme.inversePrimary,
                    decoration: InputDecoration(
                      hintStyle: Theme.of(context).textTheme.bodyMedium,
                      contentPadding: const EdgeInsets.all(0),
                      isDense: true,
                      hintText: "Search",
                      border: InputBorder.none,
                    ),
                  ),
                )
              : Row(
                  key: const ValueKey('title'),
                  children: [
                    CircleAvatar(
                      radius: 18.r,
                      backgroundImage:
                          NetworkImage(LocalService.imageUrl ?? ""),
                    ),
                    SizedBox(width: (20.w)),
                    Text(
                      "Chatter",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
        );
      }),
      actions: [
        Obx(() {
          return IconButton(
            onPressed: () {
              searchController.toggleSearch();
            },
            icon: Icon(
              searchController.isSearching.value ? Icons.close : Icons.search,
              size: 22,
              color: Theme.of(context).primaryColor,
            ),
          );
        }),
        if (!searchController.isSearching.value)
          PopupMenuButton(
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
                'New group',
                style: LightFontStyle.textMedium,
              )),
              PopupMenuItem(
                  child: Text(
                'Mark all read',
                style: LightFontStyle.textMedium,
              )),
              PopupMenuItem(
                  child: Text(
                'Filter unread chats',
                style: LightFontStyle.textMedium,
              )),
              PopupMenuItem(
                  onTap: () {
                    Get.to(() => LogoutPage());
                  },
                  child: Text(
                    'Settings',
                    style: LightFontStyle.textMedium,
                  ))
            ],
          ),
      ],
      titleSpacing: (16.5.w),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
