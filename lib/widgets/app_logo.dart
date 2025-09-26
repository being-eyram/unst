import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: "s",
        children: [
          TextSpan(
            text: "e",
            style: GoogleFonts.poppins(
              textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                wordSpacing: 0,
                letterSpacing: -1.5,
              ),
            ),
          ),
          TextSpan(
            text: "rv",
            style: GoogleFonts.poppins(
              textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -2.5,
              ),
            ),
          ),
          TextSpan(
            text: "👌🏿.",
            style: GoogleFonts.poppins(
              textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -5.5,
              ),
            ),
          ),
        ],
        style: GoogleFonts.poppins(
          textStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            wordSpacing: 0,
            letterSpacing: -1.5,
          ),
        ),
      ),
    );
  }
}