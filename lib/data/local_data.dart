import 'package:flutter/foundation.dart';

final LocalData localData = LocalData();

class LocalData {
  // User Details (Cashier) :
  String userId = '0';
  String userName = '';
  String userMobile = '';
  String cosId = '';

  // Customer Details :
  String customerName = '';
  String customerMobile = '';
  String customerAddress = '';
  String deliveryAddress = '';

  // Platform Key :
  static String platformKey = kIsWeb
      ? '3'
      : (defaultTargetPlatform == TargetPlatform.android
          ? '1'
          : defaultTargetPlatform == TargetPlatform.iOS
              ? '2'
              : '0');
}
