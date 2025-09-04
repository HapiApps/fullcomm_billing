import 'package:fullcomm_billing/data/project_data.dart';

class ApiUrl {
  /// Dev
  /// //dash.fullcomm.in/V1/billing_scripts.php
  static const String domain =
      "https://dash.fullcomm.in/V1"; //9239239233 // 12345678

  /// Pro
  //static const String domain = "https://martwayd.celwiz.com/P1";  //6381445361

  static String script = '$domain/billing_scripts.php';

  // static String loginEndPoint             = "$baseUrl/b_login.php";
  // static String customersListEndPoint     = "$baseUrl/b_select_customers.php";
  // static String addCustomersEndPoint      = "$baseUrl/b_add_customer.php";
  // static String getProductsEndPoint       = "$baseUrl/b_select_products.php";
  // static String placeOrderEndPoint        = "$baseUrl/b_insert_bill_products.php";
}
