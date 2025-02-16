import 'package:chatter/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SendMicButton extends StatelessWidget {
  final void Function()? onTap;
  final bool isSend;
  final bool isDelete;
  const SendMicButton(
      {super.key, this.onTap, required this.isSend, this.isDelete = false});

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
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryColor,
          ),
          width: 50.w, // CircleAvatar's diameter
          height: 50.h,
          child: Center(
            child: isDelete
                ? const Icon(
                    Icons.delete_forever_outlined,
                    color: AppColors.whiteColor,
                    size: 20,
                  )
                : isSend
                    ? const Icon(
                        Icons.send,
                        color: AppColors.whiteColor,
                        size: 20,
                      )
                    : const Icon(
                        Icons.mic,
                        color: AppColors.whiteColor,
                        size: 20,
                      ),
          ),
        ),
      ),
    );
  }
}

class MicDeleteButton extends StatelessWidget {
  final void Function()? onTap;
  final bool isSend;
  final bool isDelete;
  const MicDeleteButton(
      {super.key, this.onTap, required this.isSend, this.isDelete = false});

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
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryColor,
          ),
          width: 44.w, // CircleAvatar's diameter
          height: 44.h,
          child: Center(
            child: isDelete
                ? const Icon(
                    Icons.delete_forever_outlined,
                    color: AppColors.whiteColor,
                    size: 20,
                  )
                : isSend
                    ? const Icon(
                        Icons.send,
                        color: AppColors.whiteColor,
                        size: 20,
                      )
                    : const Icon(
                        Icons.mic,
                        color: AppColors.whiteColor,
                        size: 20,
                      ),
          ),
        ),
      ),
    );
  }
}
