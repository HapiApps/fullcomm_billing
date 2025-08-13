import 'package:flutter/material.dart';

import '../colors.dart';

class BackContainer extends StatelessWidget {
  const BackContainer(
      {super.key,
      required this.image,
      required this.child,
      this.padding,
      this.colorFilter});

  final String image;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ColorFilter? colorFilter;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: screenHeight,
      width: screenWidth,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 17),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.cover,
              colorFilter: colorFilter ??
                  ColorFilter.mode(AppColors.black.withOpacity(0.1),
                      BlendMode.dstATop))),
      child: child,
    );
  }
}
