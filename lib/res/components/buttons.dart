import 'package:flutter/material.dart';
import 'package:fullcomm_billing/res/components/k_text_field.dart';
import 'package:fullcomm_billing/utils/sized_box.dart';
import 'package:fullcomm_billing/utils/text_formats.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../colors.dart';
import 'k_text.dart';

class Buttons {
  /// Rounded Loading Button :
  static Widget loginButton({
    required BuildContext context,
    required String text,
    required RoundedLoadingButtonController loadingButtonController,
    required void Function() onPressed,
    double? height,
    String? toolTip,
    double? borderRadius,
    double? width,
    double? fontSize,
    OutlinedBorder? shape,
    Color? color,
    Color? textColor,
  }) {
    return Tooltip(
      message: toolTip ?? '',
      child: SizedBox(
        height: height ?? 55,
        width: width ?? MediaQuery.of(context).size.width * 0.35,
        child: RoundedLoadingButton(
            width: width ?? MediaQuery.of(context).size.width * 0.35,
            onPressed: onPressed,
            controller: loadingButtonController,
            color: color ?? AppColors.primary,
            elevation: 3,
            borderRadius: borderRadius ?? 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                text=="Print"?IconButton(onPressed:(){}, icon: Icon(Icons.print,color: Colors.white,)):0.height,
                MyText(
                    text: text,
                    color: textColor ?? AppColors.secondary,
                    fontSize: fontSize ?? 18,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold),
              ],
            )),
      ),
    );
  }

  /// Footer Buttons :
  static Widget footerButton(
    context, {
    required String text,
    required RoundedLoadingButtonController loadingButtonController,
    required void Function() onPressed,
    double? height,
    String? toolTip,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    double? width,
    double? fontSize,
    OutlinedBorder? shape,
    Color? color,
    Color? textColor,
  }) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(right: 8.0),
      child: Tooltip(
        message: toolTip ?? '',
        textAlign: TextAlign.center,
        child: SizedBox(
          height: height ?? MediaQuery.of(context).size.height * 0.04,
          width: width ?? MediaQuery.of(context).size.width * 0.08,
          child: RoundedLoadingButton(
              onPressed: onPressed,
              controller: loadingButtonController,
              color: color ?? AppColors.primary,
              elevation: 3,
              borderRadius: borderRadius ?? 55,
              child: MyText(
                text: text,
                color: textColor ?? AppColors.secondary,
                fontSize: TextFormat.responsiveFontSize(context, 16),
                letterSpacing: 1,
              )),
        ),
      ),
    );
  }
}
