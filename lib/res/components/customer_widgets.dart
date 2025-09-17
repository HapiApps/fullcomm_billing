import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomerFieldWidgets {
  // Icon Button
  static Widget iconButton(
      {required BuildContext context,
      required String toolTip,
      required String icon,
      required void Function() onPressed}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
      child: Tooltip(
        message: toolTip,
        child: InkWell(
          onTap: onPressed,
          child: CircleAvatar(
            radius: 23,
            backgroundColor: Colors.white,
            child: SvgPicture.asset(
              icon,
              width: 37,
              height: 37,
            ),
          ),
        ),
      ),
    );
  }
}
