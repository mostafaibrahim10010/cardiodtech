import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../Utils/main_variables.dart';

class AuthTextField extends StatelessWidget {

  AuthTextField(
      {Key? key,
        required this.controller,
        required this.isPassword,
        this.inputType})
      : super(key: key);

  TextEditingController controller = TextEditingController();
  bool isPassword;
  TextInputType? inputType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: GoogleFonts.montserrat(
          color: HexColor(mainColor),
          fontSize: 12,),
      cursorColor: HexColor(mainColor),
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.white,
        focusColor: Colors.white,
      ),

      obscureText: isPassword,
      keyboardType: inputType,

    );
  }
}
