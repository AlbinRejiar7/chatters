import 'package:chatter/constants/anim.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

void showLoading() {
  Get.dialog(Container(
    child: Lottie.asset(loading),
  ));
}
