import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for SystemNavigator.pop
import 'package:provider/provider.dart';

import '../../view_models/credentials_provider.dart';
import '../colors.dart';
import 'dailog_button.dart';

// you can inject controllers in the constructor if you like

/// Update Dialog
class Utils {
  static void showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Consumer<UserDataProvider>(builder: (context, userProvider, _) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              backgroundColor: Colors.white,
              title: Text(
                "Update Available?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                  fontFamily: "Lato",
                ),
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "A new version of Billing is available!\n"
                      "Current:${userProvider.versionNum} "
                      "-> Latest:${userProvider.serverVersion}",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                        fontFamily: "Lato",
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Update now to enjoy the latest \nfeatures and improvements.",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DialogButton(
                          text: "IGNORE",
                          width: 100,
                          onPress: () {
                            SystemNavigator.pop();
                          },
                        ),
                        DialogButton(
                          text: "LATER",
                          width: 100,
                          onPress: () {
                            Navigator.pop(context);
                          },
                        ),
                        DialogButton(
                          text: "UPDATE",
                          width: 110,
                          onPress: () {
                            // utils.makingWebsite(
                            //     web: controllers.currentApk.value);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  /// Expired Date Dialog
  static void showExpiredDateDialog(BuildContext context, String date) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Image.asset(
                  "assets/images/warn.jpeg",
                  height: 30,
                  width: 30,
                ),
                const SizedBox(width: 8),
                Text(
                  "App Expired",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    fontFamily: "Lato",
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 330,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "This app version expired on ",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                      fontFamily: "Lato",
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                      fontFamily: "Lato",
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
