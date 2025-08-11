import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fullcomm_billing/res/colors.dart';

class MyDropDown<T> extends StatelessWidget {
  const MyDropDown(
      {super.key,
        required this.labelText,
        this.value,
        this.validator,
        this.items,
        this.onChanged,
        this.height,
        this.width,
        this.focusNode, this.borderRadius, this.focusedBorderColor, this.enabledBorderColor});

  final String labelText;
  final double? height;
  final double? width;
  final FocusNode? focusNode;
  final T? value;
  final String? Function(T?)? validator;
  final List<DropdownMenuItem<T>>? items;
  final void Function(T?)? onChanged;
  final double? borderRadius;
  final Color? focusedBorderColor;
  final Color? enabledBorderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? MediaQuery.of(context).size.height * 0.08,
      width: width ?? MediaQuery.of(context).size.width * 0.35,
      child: DropdownButtonFormField(
        items: items,
        onChanged: onChanged,
        value: value,
        iconEnabledColor: AppColors.grey,
        focusColor: AppColors.textFieldBackground,
        focusNode: focusNode,
        autofocus: false,
        decoration: InputDecoration(
          focusColor: AppColors.textFieldBackground,
          hoverColor: AppColors.textFieldBackground,
          labelStyle: GoogleFonts.lato(fontSize: 15, color: Colors.black),
          labelText: labelText,
          filled: true,
          fillColor: AppColors.textFieldBackground,
          floatingLabelStyle:
          GoogleFonts.lato(fontSize: 14, color: AppColors.black),
          border: const OutlineInputBorder(
            borderSide: BorderSide(),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 20),
            borderSide:  BorderSide(
              color: enabledBorderColor ??AppColors.textFieldBackground,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 20),
            borderSide:  BorderSide(
              color: focusedBorderColor??AppColors.primary,
            ),
          ),
          hintStyle: GoogleFonts.lato(),
        ),
        //isExpanded: true,
        iconSize: MediaQuery.of(context).size.width * 0.009,
        style: GoogleFonts.lato(
            color: AppColors.black,
            fontSize: 15),
        validator: validator,
      ),
    );
  }
}