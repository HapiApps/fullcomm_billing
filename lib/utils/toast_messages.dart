import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oktoast/oktoast.dart';

import '../res/colors.dart';

class Toasts {
  static void showToastBar({
    required BuildContext context,
    required String text,
    Color? color,
    IconData? icon,
    int? milliseconds,
  }) {
    // final snackBar = SnackBar(
    //   content: Container(
    //     constraints: BoxConstraints(
    //       maxWidth: MediaQuery.of(context).size.width * 0.4, // Limit the width
    //     ),
    //     child: Row(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         Icon(
    //           icon ?? Icons.info,
    //           color: AppColors.secondary,
    //           size: 20,
    //         ),
    //         const SizedBox(width: 10),
    //         Flexible(
    //           child: MyText(
    //             text: text,
    //             fontSize: 15.0,
    //             color: AppColors.secondary,
    //             textAlign: TextAlign.start,
    //             maxLines: 3,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    //   backgroundColor: color ?? AppColors.appAccentColor,
    //   duration: Duration(milliseconds: milliseconds ?? 2500),
    //   elevation: 3,
    //   dismissDirection: DismissDirection.horizontal,
    //   behavior: SnackBarBehavior.floating,
    //   margin: EdgeInsets.symmetric(
    //     horizontal: MediaQuery.of(context).size.width * 0.2, // Center horizontally
    //     vertical: 12,
    //   ),
    //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    // );

    // ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // showToast(
    //   text,
    //   duration: const Duration(milliseconds: 3000),
    //   position: ToastPosition.top,
    //   backgroundColor: color ?? AppColors.appAccentColor,
    //   radius: 20.0,
    //   dismissOtherToast: true,
    //   textStyle: GoogleFonts.lato(fontSize: 16.0, color: AppColors.secondary),
    // );
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 450,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: color ?? Colors.black87,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
                InkWell(
                  onTap: () => entry.remove(),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    // Auto-dismiss after 3 seconds (optional)
    Future.delayed(Duration(seconds: 3)).then((_) {
      if (entry.mounted) entry.remove();
    });
  }
}
