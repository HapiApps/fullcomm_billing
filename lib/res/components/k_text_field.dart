import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fullcomm_billing/res/components/k_text.dart';
import 'package:fullcomm_billing/utils/sized_box.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';

class MyTextField extends StatelessWidget {
  const MyTextField(
      {super.key,
      required this.controller,
      this.focusNode,
      this.inputFormatters,
      this.suffixIcon,
      this.onChanged,
      this.onFieldSubmitted,
      this.onEditingComplete,
      this.height,
      this.labelText,
      this.width,
      this.prefixIcon,
      this.hintText,
      this.keyboardType,
      this.textInputAction,
      this.textCapitalization,
      this.enabled,
      this.autofocus,
      this.obscureText,
      this.autofillHints,
      this.textAlign,
      this.maxLines,
      this.minLines, required this.isOptional, this.borderRadius, this.fillColor, this.focusedBorderColor, this.enabledBorderColor, this.labelBlackText,});

  final TextEditingController controller;
  final FocusNode? focusNode;
  final double? height;
  final String? labelText;
  final String? hintText;
  final double? width;
  final bool? enabled;
  final int? maxLines;
  final int? minLines;
  final bool? autofocus;
  final bool? obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final bool isOptional;
  final Widget? prefixIcon;
  final TextCapitalization? textCapitalization;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onEditingComplete;
  final Iterable<String>? autofillHints;
  final TextAlign? textAlign;
  final double? borderRadius;
  final Color? fillColor;
  final Color? focusedBorderColor;
  final Color? enabledBorderColor;
  final String? labelBlackText;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: height ?? screenHeight * 0.05,
      width: width ?? screenWidth * 0.25,
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.lato(
          fontSize: 14,
        ),
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        textInputAction: textInputAction ?? TextInputAction.next,
        focusNode: focusNode,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        autofocus: false,
        obscureText: obscureText ?? false,
        obscuringCharacter: '•',
        textAlign: textAlign ?? TextAlign.start,
        decoration: InputDecoration(
          filled: true,
          fillColor: fillColor ?? AppColors.textFieldBackground,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children:[
              MyText(
                text: labelText.toString(),
              ),
                  isOptional==false?const MyText(
                    text: "*",
                    color:Colors.red,
                    fontSize: 20,
                  ):0.height,

            ],
          ),
          labelStyle: GoogleFonts.lato(),
          hintText: hintText,
          hintStyle: GoogleFonts.lato(),
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          contentPadding: const EdgeInsets.fromLTRB(10, 30, 5, 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 20),
            borderSide:  BorderSide(
              width: 0,
              color:  enabledBorderColor ?? AppColors.textFieldBackground,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 20),
            borderSide:  BorderSide(
              width: 0,
              color:  enabledBorderColor ?? AppColors.textFieldBackground,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 20),
            borderSide:  BorderSide(
              width: 0,
              color: focusedBorderColor ?? AppColors.primary,
            ),
          ),
        ),
        onChanged: onChanged,
        //maxLines: maxLines,
        autofillHints: autofillHints,
        onFieldSubmitted: onFieldSubmitted,
        onEditingComplete: onEditingComplete,
        enabled: enabled ?? true,
        //minLines: minLines,
      ),
    );
  }
}
