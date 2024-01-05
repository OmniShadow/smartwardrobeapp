import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wardrobe/home/screens/clothes_screen.dart';
import 'home/screens/home_screen.dart';

var themeData = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.indigo,
    brightness: Brightness.dark,
  ),
  textTheme: TextTheme(
    displayLarge: const TextStyle(
      fontSize: 72,
      fontWeight: FontWeight.bold,
    ),
    // ···
    titleLarge: GoogleFonts.robotoMono(
      fontSize: 40,
      fontStyle: FontStyle.normal,
    ),
    bodyMedium: GoogleFonts.roboto(),
    displaySmall: GoogleFonts.roboto(),
  ),
);
void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.dark,
      ),
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5, // Add other properties as needed
        ),
        titleLarge: GoogleFonts.robotoMono(
          fontSize: 40,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.0, // Replace with your desired color
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 16,
          letterSpacing: 0.5,
        ),
        displaySmall: GoogleFonts.roboto(
          fontSize: 14,
          letterSpacing: 0.2,
        ),
      ),
    ),
    home: HomeScreen(),
    title: "Smart Wardrobe",
  ));
}
