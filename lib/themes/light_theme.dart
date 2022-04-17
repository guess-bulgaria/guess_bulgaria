import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LightTheme {
  static const mainColor = MaterialColor(
    0x99C4F7A1,
    <int, Color>{
      50: Color(0x99C4F7A1),
      100: Color(0x99C4F7A1),
      200: Color(0x99C4F7A1),
      300: Color(0x99C4F7A1),
      400: Color(0x99C4F7A1),
      500: Color(0x99C4F7A1),
      600: Color(0x99C4F7A1),
      700: Color(0x99C4F7A1),
      800: Color(0x99C4F7A1),
      900: Color(0x99C4F7A1),
    },
  );

  static const backgroundColor = MaterialColor(
    0xFF8B635C,
    <int, Color>{
      50: Color(0xFF8B635C),
      100: Color(0xFF8B635C),
      200: Color(0xFF8B635C),
      300: Color(0xFF8B635C),
      400: Color(0xFF8B635C),
      500: Color(0xFF8B635C),
      600: Color(0xFF8B635C),
      700: Color(0xFF8B635C),
      800: Color(0xFF8B635C),
      900: Color(0xFF8B635C),
    },
  );

  static ThemeData getTheme() {
    return ThemeData(
        // brightness: Brightness.dark,
        primaryColor: mainColor,
        primarySwatch: mainColor,
        dividerColor: Colors.white38,
        colorScheme: ThemeData().colorScheme.copyWith(
              primary: mainColor,
              secondary: backgroundColor,
            ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blueAccent),
          ),
        ),
        textTheme: TextTheme(
          bodyText1: GoogleFonts.roboto(color: Colors.white70),
          bodyText2: GoogleFonts.roboto(color: Colors.white70),
        ));
  }
}
