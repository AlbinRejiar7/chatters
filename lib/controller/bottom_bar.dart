import 'package:chatter/view/bottom_bar_page/calls/calls.dart';
import 'package:chatter/view/bottom_bar_page/contacts/contacts.dart';
import 'package:chatter/view/bottom_bar_page/home/home.dart';
import 'package:chatter/view/bottom_bar_page/stories/stories.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomBarController extends GetxController {
  var pageController = PageController();
  var selectedIndex = 0.obs;
  void onChangeIndex(int value) {
    selectedIndex(value);
  }

  void jumpTo() {
    pageController.jumpToPage(
      selectedIndex.value,
    );
  }

  var bottomBarPages = [
    HomePage(),
    CallsPage(),
    ContactsPage(),
    StoriesPage(),
  ];
  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    pageController.dispose();
  }
}
