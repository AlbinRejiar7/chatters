import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomNavigator {
  static void getToPage(Widget pageName) =>
      Get.to(() => pageName, transition: Transition.cupertino);
}
