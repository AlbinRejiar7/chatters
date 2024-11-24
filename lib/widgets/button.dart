import 'package:chatter/constants/colors.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomElevatedButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  const CustomElevatedButton({super.key, this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35.h,
      width:(110.w),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: onPressed == null
              ? WidgetStateProperty.all(AppColors.greyColor)
              : WidgetStateProperty.all(AppColors.primaryColor),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primaryLight
                  .withOpacity(0.2); // Color for splash effect
            }
            return null; // Default color (no splash when not pressed)
          }),

          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50), // Rounded corners
            ),
          ),
          elevation: WidgetStateProperty.all(4), // Optional: Add elevation
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(color: AppColors.whiteColor, fontSize: 11),
        ),
      ),
    );
  }
}
