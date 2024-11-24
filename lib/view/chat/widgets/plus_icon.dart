import 'package:chatter/constants/colors.dart';
import 'package:flutter/material.dart';

class SendMicButton extends StatelessWidget {
  final void Function()? onTap;
  final bool isSend;

  const SendMicButton({super.key, this.onTap, required this.isSend});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors
          .transparent, // Transparent to retain the CircleAvatar background
      shape:
          const CircleBorder(), // Ensures the splash effect matches the circular shape
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(), // Matches the CircleAvatar's shape
        splashColor:
            Colors.white.withOpacity(0.3), // Optional: Customize splash color
        child: Ink(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryColor,
          ),
          width: 34, // CircleAvatar's diameter
          height: 34,
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
