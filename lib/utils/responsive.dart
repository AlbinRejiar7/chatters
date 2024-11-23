import 'package:flutter/material.dart';
import 'package:get/get.dart';

double getResponsiveHeight(
  double baseValue,
) {
  // Adjust the value based on the chosen dimension
  double screenSize = MediaQuery.of(Get.context!).size.height;
  double baseSize = 812; // Adjust base dimensions as needed
  return screenSize * (baseValue / baseSize);
}

double getResponsiveWidth(
  double baseValue,
) {
  // Adjust the value based on the chosen dimension
  double screenSize = MediaQuery.of(Get.context!).size.width;
  double baseSize = 375; // Adjust base dimensions as needed
  return screenSize * (baseValue / baseSize);
}
