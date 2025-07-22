import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryColor = Color(0xFF2D2013);
const Color secondaryColor = Color(0xFF23180D);

final TextTheme myTextTheme = TextTheme(
  displayLarge: GoogleFonts.satisfy(
      fontSize: 117, fontWeight: FontWeight.w300, letterSpacing: -1.5),
  displayMedium: GoogleFonts.satisfy(
      fontSize: 73, fontWeight: FontWeight.w300, letterSpacing: -0.5),
  displaySmall: GoogleFonts.satisfy(fontSize: 58, fontWeight: FontWeight.w400),
  headlineLarge: GoogleFonts.satisfy(
      fontSize: 41, fontWeight: FontWeight.w400, letterSpacing: 0.25),
  headlineMedium: GoogleFonts.satisfy(fontSize: 29, fontWeight: FontWeight.w400),
  headlineSmall: GoogleFonts.satisfy(
      fontSize: 24, fontWeight: FontWeight.w500, letterSpacing: 0.15),
  titleLarge: GoogleFonts.satisfy(
      fontSize: 19, fontWeight: FontWeight.w400, letterSpacing: 0.15),
  titleMedium: GoogleFonts.satisfy(
      fontSize: 17, fontWeight: FontWeight.w500, letterSpacing: 0.1),
  bodyLarge: GoogleFonts.baskervville(
      fontSize: 19, fontWeight: FontWeight.w400, letterSpacing: 0.5),
  bodyMedium: GoogleFonts.baskervville(
      fontSize: 17, fontWeight: FontWeight.w400, letterSpacing: 0.25),
  labelLarge: GoogleFonts.baskervville(
      fontSize: 17, fontWeight: FontWeight.w500, letterSpacing: 1.25),
  bodySmall: GoogleFonts.baskervville(
      fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.4),
  labelSmall: GoogleFonts.baskervville(
      fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 1.5),
);
