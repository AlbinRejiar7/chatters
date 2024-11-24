import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SendOtpContrller extends GetxController {
  var currentTextValue = ''.obs;
  final formKeyPhone = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  void onTextChange(value) {
    currentTextValue.value = value;
    update();
  }
}
