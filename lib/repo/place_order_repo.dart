import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fullcomm_billing/api/api_urls.dart';

import '../data/local_data.dart';
import '../data/project_data.dart';
import '../models/order_details.dart';
import '../models/place_order.dart';
import '../models/placed_order_response.dart';
import 'package:http/http.dart' as http;

import '../utils/toast_messages.dart';

class PlaceOrderRepository {
  /// Place Order :
  // Future<PlacedOrderResponse> placeOrder({required Order order}) async {
  //   try {
  //
  //     final response = await http.post(
  //         Uri.parse(ApiUrl.script),
  //         body: jsonEncode(order.toJson())
  //         );
  //
  //     if (response.statusCode == 200) {
  //
  //       final data = jsonDecode(response.body);
  //
  //       return PlacedOrderResponse.fromJson(data);
  //
  //     } else {
  //       log("placeOrder Error : ${response.body} \n"
  //           "Reason:${response.reasonPhrase}");
  //
  //       throw "Error on billing";
  //     }
  //   } catch (e) {
  //     throw Exception("placeOrder Catch Error : $e");
  //   }
  // }
  Future<PlacedOrderResponse> placeOrder(
      {required Order order, required BuildContext context}) async {
    try {
      final Map<String, dynamic> requestBody = {
        ...order.toJson(),
        'action': 'b_insert_bill_products',
        "cos_id": localData.cosId
      };

      final response = await http.post(
        Uri.parse(ApiUrl.script),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      log('placeOrder Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception("Empty response body");
        }

        final data = jsonDecode(response.body);
        return PlacedOrderResponse.fromJson(data);
      } else {
        throw Exception("Server error: ${response.reasonPhrase}");
      }
    } on TimeoutException {
      log("Request timed out!");
      Toasts.showToastBar(
          context: context,
          text: 'Request timed out!. Please try again',
          color: Colors.red);
      throw Exception("Request timed out!");
    } on SocketException {
      log("Network issue!");
      Toasts.showToastBar(
          context: context,
          text: 'Network issue!. Please try again',
          color: Colors.red);
      throw Exception("Network issue!. Please try again");
    } catch (e) {
      log("placeOrder Catch Error: $e");
      throw Exception("placeOrder Catch Error: $e");
    }
  }

  Future<OrdersResponse> getOrderDetails(
      {required String stDate, required String enDate}) async {
    final body = jsonEncode({
      'action': 'b_select_order_details',
      'st_date': stDate,
      'en_date': enDate,
      "cos_id": localData.cosId
    });
    log("body details:${body}");
    try {
      final response = await http.post(Uri.parse(ApiUrl.script), body: body);
      return OrdersResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception("getCustomers Error : $e");
    }
  }

  Future<OrdersResponse> getLastOrderDetails() async {
    final body = jsonEncode({
      'action': 'b_select_last_order',
      'user_id': localData.userName,
      "cos_id": localData.cosId
    });
    try {
      final response = await http.post(Uri.parse(ApiUrl.script), body: body);
      return OrdersResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception("getCustomers Error : $e");
    }
  }
}
