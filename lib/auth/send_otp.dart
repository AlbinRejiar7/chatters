import 'package:chatter/auth/widget/phone_dialoge.dart';
import 'package:chatter/constants/colors.dart';
import 'package:chatter/constants/light_font_style.dart';
import 'package:chatter/controller/send_otp.dart';
import 'package:chatter/utils/sizedboxwidget.dart';
import 'package:chatter/utils/validators.dart';
import 'package:chatter/widgets/button.dart';
import 'package:chatter/widgets/country_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SendOtpPage extends StatelessWidget {
  const SendOtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    var ctr = Get.put<SendOtpContrller>(SendOtpContrller());
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: (20.w), vertical: (40.h)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Phone number",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 25),
              ),
              Text("Enter your phone number to get started.",
                  style: Theme.of(context).textTheme.bodyMedium),
              kHeight((15.h)),
              Column(
                children: [
                  SizedBox(
                    height: 40.h,
                    child: Row(
                      children: [
                        CountryCodeSelectorWidget(),
                        kWidth((15.w)),
                        TextFieldCustom(
                          hintText: "Enter phone number",
                          controller: ctr.phoneController,
                          onChanged: (p0) {
                            ctr.onTextChange(p0);
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: (45.w)),
                    child: GetBuilder<SendOtpContrller>(
                      builder: (controller) => Text(
                        ctr.currentTextValue.value.isEmpty
                            ? ""
                            : Validators.validatePhone(
                                    ctr.currentTextValue.value) ??
                                '',
                        style: LightFontStyle.errorText,
                      ),
                    ),
                  )
                ],
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(() {
                    return CustomElevatedButton(
                      text: 'Continue',
                      onPressed: ctr.currentTextValue.value.isEmpty
                          ? null
                          : () {
                              if (Validators.validatePhone(
                                      ctr.currentTextValue.value) ==
                                  null) {
                                showPhoneNumberDialog(
                                    context, ctr.phoneController.text);
                              }
                            },
                    );
                  }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TextFieldCustom extends StatelessWidget {
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final int? maxLength;
  final String hintText;
  final List<TextInputFormatter>? inputFormatters;
  const TextFieldCustom({
    super.key,
    this.onChanged,
    this.controller,
    this.maxLength,
    this.inputFormatters,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
            border: Border.all(
              width: 0.2,
              color: AppColors.primaryColor,
            ),
            borderRadius: BorderRadius.circular(8),
            color: AppColors.primaryLight),
        child: Column(
          children: [
            TextFormField(
              maxLength: maxLength, // Limit input length to 6 characters

              onChanged: onChanged,
              keyboardType: TextInputType.number,
              controller: controller,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.darkColor),
              cursorHeight: 16.h,
              cursorColor: AppColors.primaryColor,
              decoration: InputDecoration(
                counterText: '',
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.normal),
                contentPadding: const EdgeInsets.all(0),
                isDense: true,
                hintText: hintText,
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
