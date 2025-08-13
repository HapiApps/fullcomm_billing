import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_billing/res/colors.dart';
import 'package:fullcomm_billing/utils/sized_box.dart';
import 'package:fullcomm_billing/utils/toast_messages.dart';
import 'package:fullcomm_billing/view_models/credentials_provider.dart';
import 'package:provider/provider.dart';
import '../../res/components/buttons.dart';
import '../../res/components/k_back_container.dart';
import '../../res/components/k_text.dart';
import '../../res/components/k_text_field.dart';
import '../../utils/input_formatters.dart';
import '../../utils/text_formats.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  Widget build(BuildContext context) {
    // final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Consumer<UserDataProvider>(builder: (context, userProvider, _) {
      if (kDebugMode) {
        userProvider.mobileController.text = "9239239233";
        userProvider.passwordController.text = "12345678";
      }
      return Scaffold(
        backgroundColor: Colors.white,
        body: BackContainer(
          image: 'assets/vectors/splash_vec.jpg',

          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo/app_logo.png',
                  // width: screenWidth > 800 ? screenWidth * 0.15 : screenWidth * 0.25,
                  // height: screenWidth > 800 ? screenWidth * 0.15 : screenWidth * 0.25,
                  fit: BoxFit.contain,
                ),
                MyText(
                  text: 'BillEase',
                  fontSize: TextFormat.responsiveFontSize(context, 30),
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                  letterSpacing: 0.5,
                ),
                10.height,
                MyText(
                  text: 'Login to your account',
                  fontSize: TextFormat.responsiveFontSize(context, 19),
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkBlue,
                ),
                70.height,
                MyTextField(
                  labelText: 'Mobile Number',
                  isOptional: true,
                  width: screenWidth > 800
                      ? screenWidth * 0.20
                      : screenWidth * 0.35,
                  height: 50,
                  controller: userProvider.mobileController,
                  focusedBorderColor: AppColors.primary,
                  enabledBorderColor: Color(0xff9e9e9e),
                  fillColor: Color(0xffffffff),
                  borderRadius: 5,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  inputFormatters: InputFormatters.mobileNumberInput,
                ),
                25.height,
                MyTextField(
                  labelText: 'Password',
                  height: 50,
                  isOptional: true,
                  obscureText: userProvider.isVisible,
                  focusedBorderColor: AppColors.primary,
                  enabledBorderColor: Color(0xff9e9e9e),
                  fillColor: Color(0xffffffff),
                  borderRadius: 5,
                  suffixIcon: IconButton(
                    icon: Icon(
                      userProvider.isVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      userProvider.toggleVisibility();
                    },
                  ),
                  width: screenWidth > 800
                      ? screenWidth * 0.20
                      : screenWidth * 0.35,
                  controller: userProvider.passwordController,
                  textInputAction: TextInputAction.next,

                  onFieldSubmitted: (value) {
                    userProvider.loginButtonController.start(); // Start Loading

                    if (userProvider.mobileController.text.trim().isEmpty) {
                      userProvider.loginButtonController.reset();
                      Toasts.showToastBar(
                        context: context,
                        text: 'Please enter your mobile number.',
                        color: AppColors.errorMessage,
                      );
                    } else if (userProvider.mobileController.text
                        .trim()
                        .length !=
                        10) {
                      userProvider.loginButtonController.reset();
                      Toasts.showToastBar(
                        context: context,
                        text: 'Please enter 10 digit mobile number.',
                        color: AppColors.errorMessage,
                      );
                    } else if (userProvider.passwordController.text
                        .trim()
                        .isEmpty) {
                      userProvider.loginButtonController.reset();
                      Toasts.showToastBar(
                        context: context,
                        text: 'Please enter your password.',
                        color: AppColors.errorMessage,
                      );
                    } else if (userProvider.passwordController.text
                        .trim()
                        .length <
                        8) {
                      userProvider.loginButtonController.reset();
                      Toasts.showToastBar(
                        context: context,
                        text: 'Password must be at least 8 characters.',
                        color: AppColors.errorMessage,
                      );
                    } else {
                      userProvider.login(
                        context: context,
                        mobile: userProvider.mobileController.text.trim(),
                        password:
                        userProvider.passwordController.text.trim(),
                      );
                      // userProvider.loginButtonController.reset();
                      // Toasts.showToastBar(
                      //   context: context,
                      //   text: 'Invalid Mobile/Password!',
                      //   color: AppColors.errorMessage,
                      // );
                    }
                  },
                ),
                50.height,
                Buttons.loginButton(
                  context: context,
                  loadingButtonController:
                  userProvider.loginButtonController,
                  height: 50,
                  width: screenWidth > 800
                      ? screenWidth * 0.20
                      : screenWidth * 0.35,
                  onPressed: () {
                    if (userProvider.mobileController.text
                        .trim()
                        .isEmpty) {
                      userProvider.loginButtonController.reset();
                      Toasts.showToastBar(
                        context: context,
                        text: 'Please enter your mobile number.',
                        color: AppColors.errorMessage,
                      );
                    } else if (userProvider.mobileController.text
                        .trim()
                        .length !=
                        10) {
                      userProvider.loginButtonController.reset();
                      Toasts.showToastBar(
                        context: context,
                        text: 'Please enter 10 digit mobile number.',
                        color: AppColors.errorMessage,
                      );
                    } else if (userProvider.passwordController.text
                        .trim()
                        .isEmpty) {
                      userProvider.loginButtonController.reset();
                      Toasts.showToastBar(
                        context: context,
                        text: 'Please enter your Password',
                        color: AppColors.errorMessage,
                      );
                    } else if (userProvider.passwordController.text.trim().length < 8) {
                      userProvider.loginButtonController.reset();
                      Toasts.showToastBar(
                        context: context,
                        text: 'Password must be at least 8 characters.',
                        color: AppColors.errorMessage,
                      );
                    } else {
                      userProvider.login(
                        context: context,
                        mobile: userProvider.mobileController.text.trim(),
                        password:
                        userProvider.passwordController.text.trim(),
                      );
                      // userProvider.loginButtonController.reset();
                      // Toasts.showToastBar(
                      //   context: context,
                      //   text: 'Invalid Mobile/Password!',
                      //   color: AppColors.errorMessage,
                      // );
                    }
                  },
                  text: 'LOGIN',
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
