import 'package:chatter/controller/bottom_bar.dart';
import 'package:chatter/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class BottomBarPage extends StatelessWidget {
  const BottomBarPage({super.key});

  @override
  Widget build(BuildContext context) {
    var ctr = Get.put(BottomBarController());
    return Scaffold(
      appBar: const AnimatedSearchAppBar(),
      bottomNavigationBar: Obx(() {
        return NavigationBar(
            height: 60,
            selectedIndex: ctr.selectedIndex.value,
            onDestinationSelected: (value) {
              ctr.onChangeIndex(value);
              ctr.jumpTo();
            },
            destinations: [
              NavigationDestination(
                icon: Icon(
                  Iconsax.message,
                  color: ctr.selectedIndex.value == 0 ? Colors.white : null,
                ),
                label: 'Chat',
              ),
              NavigationDestination(
                  icon: Icon(
                    Iconsax.call,
                    color: ctr.selectedIndex.value == 1 ? Colors.white : null,
                  ),
                  label: 'Call'),
              NavigationDestination(
                  icon: Icon(
                    Iconsax.book_saved,
                    color: ctr.selectedIndex.value == 2 ? Colors.white : null,
                  ),
                  label: 'Contacts'),
              NavigationDestination(
                  icon: Icon(
                    Iconsax.story,
                    color: ctr.selectedIndex.value == 3 ? Colors.white : null,
                  ),
                  label: 'Stories'),
            ]);
      }),
      body: PageView.builder(
        controller: ctr.pageController,
        onPageChanged: (value) {
          ctr.onChangeIndex(value);
        },
        itemCount: ctr.bottomBarPages.length,
        itemBuilder: (BuildContext context, int index) {
          var page = ctr.bottomBarPages[index];
          return page;
        },
      ),
    );
  }
}
