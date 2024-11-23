import 'package:chatter/constants/colors.dart';
import 'package:flutter/material.dart';

class SendMicButton extends StatelessWidget {
  final void Function()? onTap;
  final bool isSend;
  const SendMicButton({super.key, this.onTap, required this.isSend});

  @override
  Widget build(BuildContext context) {
    return Ink(
      child: InkWell(
        onTap: onTap,
        child: CircleAvatar(
          radius: 17,
          backgroundColor: AppColors.primaryColor,
          child: Center(
            child: Icon(
              isSend ? Icons.send_rounded : Icons.mic,
              color: AppColors.whiteColor,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
