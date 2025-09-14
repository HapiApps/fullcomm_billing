import 'package:flutter/material.dart';

import '../colors.dart';

class DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback onPress;
  final double width;

  const DialogButton(
      {super.key,
      required this.text,
      required this.onPress,
      required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 45,
      child: ElevatedButton(
        onPressed: onPress,
        style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent,
            backgroundColor:
                text == "UPDATE" ? AppColors.primary : AppColors.secondary,
            side: BorderSide(color: AppColors.secondary),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
        child: Text(
          text,
          style: TextStyle(
              color: text == "UPDATE" ? Colors.white : AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.bold),
        ),
        // const CustomText(
        //   text: "No",
        //   colors:Colors.white,
        //   size: 14,
        //   isBold: true,
        // ),
      ),
    );
  }
}
