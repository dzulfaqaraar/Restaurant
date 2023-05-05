import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryColor = Color(0xFF2D2013);
const Color secondaryColor = Color(0xFF23180D);

final TextTheme myTextTheme = TextTheme(
  headline1: GoogleFonts.satisfy(
      fontSize: 117, fontWeight: FontWeight.w300, letterSpacing: -1.5),
  headline2: GoogleFonts.satisfy(
      fontSize: 73, fontWeight: FontWeight.w300, letterSpacing: -0.5),
  headline3: GoogleFonts.satisfy(fontSize: 58, fontWeight: FontWeight.w400),
  headline4: GoogleFonts.satisfy(
      fontSize: 41, fontWeight: FontWeight.w400, letterSpacing: 0.25),
  headline5: GoogleFonts.satisfy(fontSize: 29, fontWeight: FontWeight.w400),
  headline6: GoogleFonts.satisfy(
      fontSize: 24, fontWeight: FontWeight.w500, letterSpacing: 0.15),
  subtitle1: GoogleFonts.satisfy(
      fontSize: 19, fontWeight: FontWeight.w400, letterSpacing: 0.15),
  subtitle2: GoogleFonts.satisfy(
      fontSize: 17, fontWeight: FontWeight.w500, letterSpacing: 0.1),
  bodyText1: GoogleFonts.baskervville(
      fontSize: 19, fontWeight: FontWeight.w400, letterSpacing: 0.5),
  bodyText2: GoogleFonts.baskervville(
      fontSize: 17, fontWeight: FontWeight.w400, letterSpacing: 0.25),
  button: GoogleFonts.baskervville(
      fontSize: 17, fontWeight: FontWeight.w500, letterSpacing: 1.25),
  caption: GoogleFonts.baskervville(
      fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.4),
  overline: GoogleFonts.baskervville(
      fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 1.5),
);
