import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:google_fonts/google_fonts.dart';

class TutorialService {
  static void show({
    required BuildContext context,
    required List<TargetFocus> targets,
    Function()? onFinish,
    Function()? onSkip,
  }) {
    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      textSkip: "SKIP",
      textStyleSkip: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold), 
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: onFinish,
      onSkip: () {
        onSkip?.call();
        return true;
      },
    ).show(context: context);
  }
}
