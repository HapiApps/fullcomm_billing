import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fullcomm_billing/repo/credentials_repo.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local_data.dart';
import '../data/project_data.dart';
import '../res/colors.dart';
import '../utils/toast_messages.dart';
import '../views/billing_view/new_billing_screen.dart';
import '../views/credentials/login_screen.dart';

class UserDataProvider with ChangeNotifier {
  bool _isVisible = true;

  bool get isVisible => _isVisible;

  void toggleVisibility() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  final CredentialsRepository _credentialsRepo = CredentialsRepository();

  RoundedLoadingButtonController loginButtonController = RoundedLoadingButtonController();

  // Input Fields :
  TextEditingController mobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  /// ----------- Initialize User Data -------------
  Future<void> initializeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    localData.userId = prefs.getString('userId') ?? '0';
    localData.userName = prefs.getString('userName') ?? ProjectData.title;
    localData.userMobile = prefs.getString('userMobile') ?? '';
    localData.cosId = prefs.getString('cosId') ?? '';
  }

  /// -------------- Login Function------------------
  Future<void> login(
      {required BuildContext context,
      required String mobile,
      required String password}) async {
    try {
      final response = await _credentialsRepo.loginApi(
          mobile: mobile, password: password); // Call the Repo

      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (response.responseCode == 200) {
        prefs.setString('userId', response.userData!.id!);
        prefs.setString('userName', response.userData!.sName!);
        prefs.setString('userMobile', response.userData!.sMobile!);
        prefs.setString('cosId', response.userData!.cosId!);
        mobileController.clear();
        passwordController.clear();

        prefs.setBool('seen${ProjectData.version}', true); // Set User Logged In

        await initializeUserData();
        if (!context.mounted) return;
        Toasts.showToastBar(
          context: context,
          text: 'Login Successfully',
          color: AppColors.successMessage,
        );
        if (!context.mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (context) => const NewBillingScreen()));
      } else {
        if (!context.mounted) return;
        Toasts.showToastBar(
          context: context,
          text: 'Invalid username or password.',
          color: AppColors.errorMessage,
        );
        log("Login Error: ${response.message}");
      }
    } catch (e) {
      if (!context.mounted) return;
      Toasts.showToastBar(
        context: context,
        text: 'Something went wrong.',
        color: AppColors.errorMessage,
      );
      throw Exception("Login Error: $e");
    } finally {
      loginButtonController.reset();
      notifyListeners();
    }
  }

  /// --------- Check before Splash Screen ----------
  // Check For User if logged in :
  Future checkUserExistence(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('seen') ?? false) {
      await initializeUserData();

      if (!context.mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const NewBillingScreen()));
      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const OrderDetailPage()));
    } else {
      if (!context.mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  /// --------- Logout Function -------------------
  void logout(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear Local Storage
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }
}
