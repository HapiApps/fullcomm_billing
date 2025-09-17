import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fullcomm_billing/repo/credentials_repo.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local_data.dart';
import '../data/project_data.dart';
import '../models/check_privacy_response.dart';
import '../res/colors.dart';
import '../res/components/privacy_dialog.dart';
import '../res/components/update_dialog.dart';
import '../utils/toast_messages.dart';
import '../views/billing_view/new_billing_screen.dart';
import '../views/credentials/login_screen.dart';

class UserDataProvider with ChangeNotifier {
  bool _isVisible = true;

  bool _isLoading = false;
  String _errorMessage = '';
  String _userId = '0'; // User ID 0 by default
  String _userName = ''; // User Name '' by default

  String _companyName = ''; // User Name '' by default
  String _userMobile = ''; // User Mobile '' by default
  String _cosId = ''; // User Mobile '' by default
  String _password = ''; // User Mobile '' by default
  String _storeId = ''; // User Mobile '' by default

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get userId => _userId;
  String get userName => _userName;
  bool get isVisible => _isVisible;

  void toggleVisibility() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  final CredentialsRepository _credentialsRepo = CredentialsRepository();

  RoundedLoadingButtonController loginButtonController =
      RoundedLoadingButtonController();

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

        checkPrivacy(
          mobileNo: mobileController.text.toString(),
          password: passwordController.text.toString(),
          context: context,
        );
        prefs.setBool('seen${ProjectData.version}', true); // Set User Logged In

        await initializeUserData();
        if (!context.mounted) return;
        Toasts.showToastBar(
          context: context,
          text: 'Login Successfully',
          color: AppColors.successMessage,
        );
        if (!context.mounted) return;
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const NewBillingScreen()));
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

  LoginResponse? _loginPrivacyResponse;
  LoginResponse? get loginResponse => _loginPrivacyResponse;

  Future<void> privacyPolicy({
    required String mobileNo,
    required String password,
    required BuildContext context,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _credentialsRepo.privacyPolicy(mobileNo, password);

      if (response.status == 'success') {
        _loginPrivacyResponse = response;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('login', true);
        await prefs.setString('auth_id', response.authId);
        await prefs.setString('cos_id', response.cosId);
        await prefs.setString('userMobile', mobileNo);
        await prefs.setString('userName', response.username);

        log("currentUserID:${response.authId}");
        // show privacy dialog or go home directly
        if (response.showPrivacyPopup) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => const PrivacyPolicyDialog(),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewBillingScreen()),
          );
        }
      } else {
        _errorMessage = response.message;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong')),
      );
      log('login error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  LoginResponse? _loginPrivacy;
  LoginResponse? get loginPrivacy => _loginPrivacy;

  Future<void> checkPrivacy({
    required String mobileNo,
    required String password,
    required BuildContext context,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _credentialsRepo.checkPrivacy(mobileNo, password);

      if (response.status == 'success') {
        _loginPrivacy = response;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('login', true);
        await prefs.setString('auth_id', response.authId);
        await prefs.setString('cos_id', response.cosId);
        await prefs.setString('userMobile', mobileNo);
        await prefs.setString('userName', response.username);

        log("currentUserID:${response.authId}");
        log("currentUserID showPrivacyPopup:${response.showPrivacyPopup}");

        // Privacy check
        if (response.showPrivacyPopup) {
          // show dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => const PrivacyPolicyDialog(),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewBillingScreen()),
          );
        }
      } else {
        _errorMessage = response.message;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong.')),
      );
      log('login error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// App's current version
  String versionNum = '1.0.0';

  /// Latest version from server
  String serverVersion = '';

  /// Flags
  bool versionActive = false;
  bool updateAvailable = false;

  /// Check version against server
  Future<void> currentVersion(BuildContext context) async {
    try {
      versionActive = false;
      updateAvailable = false;

      final response = await _credentialsRepo.checkVersion();
      if (response == null || response.isEmpty) return;

      // safely read values:
      final serverVersionFromApi = response["current_version"];
      final expiredDateStr = response["expired_date"];
      final activeFlag = response["active"];

      if (serverVersionFromApi == null) {
        log("Server did not return current_version");
        return;
      }

      serverVersion = serverVersionFromApi.toString();

      DateTime? expiredDate;
      if (expiredDateStr != null && expiredDateStr.toString().isNotEmpty) {
        expiredDate = _parseExpiredDate(expiredDateStr);
      }

      final now = DateTime.now();
      log("expiredDate: $expiredDate");
      log("serverVersion: $serverVersion");

      // expired date check
      if (expiredDate != null && now.isAfter(expiredDate)) {
        Utils.showExpiredDateDialog(context, expiredDateStr);
        versionActive = true;
        updateAvailable = false;
        notifyListeners();
        return;
      }

      // version check
      if (versionNum != serverVersion) {
        versionActive = true;
        if (activeFlag != null && activeFlag.toString() == "1") {
          Utils.showUpdateDialog(context);
          updateAvailable = true;
        }
      }

      notifyListeners();
    } catch (e, st) {
      log("currentVersion error: $e\n$st");
      versionActive = false;
      notifyListeners();
    }
  }

  DateTime? _parseExpiredDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (_) {
      return null;
    }
  }
}
