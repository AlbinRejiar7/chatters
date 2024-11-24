import 'package:chatter/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const color = AppColors.darkColor;

class LightFontStyle {
  static TextStyle textMedium = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    color: color,
    fontSize: 12,
  );

  static TextStyle titleMedium = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    color: color,
    fontSize: 17,
  );
  static TextStyle bodySmall = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    color: color,
    fontSize: 13,
  );

  static TextStyle smallSubtitle = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    color: color.withOpacity(0.6),
    fontSize: 10,
  );
}
