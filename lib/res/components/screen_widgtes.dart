import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_billing/utils/sized_box.dart';
import 'package:fullcomm_billing/utils/text_formats.dart';

import 'k_text.dart';

class ScreenWidgets {
  /// ------- Empty Alert --------
  static Widget emptyAlert(context,
      {double? height,
      double? width,
      required String image,
      required String text}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            image,
            height: height ?? MediaQuery.of(context).size.height * 0.35,
            width: width ?? MediaQuery.of(context).size.height * 0.35,
          ),
          MyText(
            text: text,
            fontSize: TextFormat.responsiveFontSize(context, 14),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
