import 'package:chatter/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

const color = AppColors.whiteColor;

class DarkFontStyle {
  static TextStyle textMedium = GoogleFonts.poppins(
      fontWeight: FontWeight.w400, color: color, fontSize: 12.sp);
  static TextStyle titleMedium = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    color: color,
    fontSize: 17.sp,
  );

  static TextStyle bodySmall = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    color: color,
    fontSize: 13.sp,
  );
  static TextStyle smallSubtitle = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    color: color.withOpacity(0.6),
    fontSize: 10.sp,
  );
  static TextStyle unreadCountText = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    color: color.withOpacity(0.6),
    fontSize: 7.sp,
  );
}
