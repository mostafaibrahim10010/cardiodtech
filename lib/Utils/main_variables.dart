import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

String mainColor = "#050A30";
String subColor = "#A5B4FC";


const kblueColor = Color(0xFF00D9F6);
const kgreyColor = Color(0xFF6C7589);
const kbackgroundColor = Color(0xFF0E121E);

final largeTextStyle = GoogleFonts.montserrat(
    color: HexColor(mainColor), fontSize: 60, fontWeight: FontWeight.bold);



final smallTextStyle =
GoogleFonts.montserrat(color: HexColor(mainColor), fontWeight: FontWeight.w600);

// Topics list for learning section
List<String> myTopicsTitles = [
  "Introduction to Heart Health",
  "Understanding Cardiovascular System",
  "Heart Disease Prevention",
  "Exercise and Heart Health",
  "Nutrition for Heart Health",
  "Stress Management",
  "Medication and Treatment",
  "Emergency Response",
];
