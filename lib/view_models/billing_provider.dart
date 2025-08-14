import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_billing/data/local_data.dart';
import 'package:fullcomm_billing/models/order_details.dart';
import 'package:fullcomm_billing/repo/place_order_repo.dart';
import 'package:fullcomm_billing/repo/products_repo.dart';
import 'package:fullcomm_billing/utils/toast_messages.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../models/bill_obj.dart';
import '../models/billing_product.dart';
import '../models/place_order.dart';
import '../models/products_response.dart';
import '../res/colors.dart';
import '../res/components/buttons.dart';
import '../res/components/k_text.dart';
import '../res/components/k_text_field.dart';
import '../utils/input_formatters.dart';
import '../utils/text_formats.dart';
import '../views/billing_view/new_billing_screen.dart';
import '../views/pdf/bill_pdf.dart';

class BillingProvider with ChangeNotifier {
  final ProductsRepository _productsRepo = ProductsRepository();
  final PlaceOrderRepository _placeOrderRepo = PlaceOrderRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedDate = 'Today';

  String get selectedDate => _selectedDate;

  void changeDateFilter(String value) {
    _selectedDate = value;
    notifyListeners();
  }

  String stDate = '';
  String enDate = '';
  PickerDateRange? selectedRange;

  void setDateRange(PickerDateRange? range) {
    selectedRange = range;

    if (range != null) {
      final start = range.startDate!;
      final end = range.endDate ?? DateTime.now();

      stDate = _formatDate(start);
      enDate = _formatDate(end);

      final endForApi = end.add(const Duration(days: 1));
      getAllOrderDetails(start.toString(), endForApi.toString());
    } else {
      stDate = '';
      enDate = '';
    }

    notifyListeners();
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}";
  }

  /// --------------- Cashier Tab ---------------------
  TextEditingController cashierNameController =
      TextEditingController(text: localData.userName);
  TextEditingController cashierCounter = TextEditingController();

  /// ------------- Fetch Products -------------------

  List<ProductData> _productsList = [];
  List<ProductData> get productsList => _productsList;

  // API Call For Products :
  Future<void> getProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _productsRepo.getProducts();

      if (response.responseCode == 200) {
        _productsList = response.productList ?? [];
        //print("products ${_productsList.length}");
        for (int i = 0; i < _productsList.length; i++) {
          //print("barcode ${_productsList[i].barcode} ${_productsList[i].pTitle} ${_productsList[i].pVariation}${_productsList[i].unit}");
        }
      } else {
        _productsList = [];
      }

      log("Products List : ${_productsList.length}");
    } catch (e) {
      Exception("getProducts Error : $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ----------- Billing Calculations ---------------

  List<BillingItem> _billingItems = [];
  List<BillingItem> get billingItems => _billingItems;

  ProductData? selectedProduct;

  List<TextEditingController?> variationControllers = [];
  List<TextEditingController?> quantityControllers = [];
  List<TextEditingController?> gstControllers = [];

  void initializeControllers(List<BillingItem> items) {
    variationControllers = List.generate(
      items.length,
      (_) => TextEditingController(),
    );
    quantityControllers = List.generate(
      items.length,
      (_) => TextEditingController(),
    );
  }

  void setBillingItems(List<BillingItem> items) {
    _billingItems = items;
    initializeControllers(items);
  }

  // Add Billing Items : (Add Billing Item From the Header)
  void addBillingItem(BillingItem newItem) {
    // Check if the product already exists in the list
    final existingIndex = _billingItems
        .indexWhere((item) => item.product.id == newItem.product.id);

    if (existingIndex != -1) {
      // Update the existing item
      final existingItem = _billingItems[existingIndex];

      final updatedItem = BillingItem(
        id: existingItem.id,
        product: existingItem.product,
        productTitle: existingItem.productTitle,
        variation: existingItem.product.isLoose == '1'
            ? existingItem.variation + newItem.variation
            : 1,
        variationUnit: existingItem.variationUnit,
        quantity: existingItem.product.isLoose == '0'
            ? existingItem.quantity + newItem.quantity
            : 1,
      );

      _billingItems[existingIndex] = updatedItem; // Replace the old item
      variationControllers[existingIndex]?.text =
          updatedItem.variation.toString();
      quantityControllers[existingIndex]?.text =
          updatedItem.quantity.toString();
    } else {
      // Add the new item if it doesn't exist
      _billingItems.add(newItem);

      // Initialize controllers for the new item
      variationControllers
          .add(TextEditingController(text: newItem.variation.toString()));
      quantityControllers
          .add(TextEditingController(text: newItem.quantity.toString()));
    }

    notifyListeners(); // Notify listeners about the change
  }

  // Update Temporary Variation or Quantity for a Product (Headers) :
  double temporaryVariation = 1.0;
  int temporaryQuantity = 1;

  // Header Billing
  void updateTemporaryFields({double? variation, int? quantity}) {
    if (variation != null) temporaryVariation = variation;
    if (quantity != null) temporaryQuantity = quantity;
    notifyListeners();
  }

  String _variation = "";
  String get variation => _variation;
  void changeVariation(String value) {
    _variation = value;
    notifyListeners();
  }

  // Update Billing Items : (For Edit Option)
  void updateBillingItem(int index,
      {required String isLoose, double? variation, int? quantity}) {
    if (index < 0 || index >= billingItems.length) {
      log("Invalid index: $index");
      return; // Exit if index is invalid
    }

    if (variation != null && isLoose == '1') {
      billingItems[index].variation = variation;

      // Ensure the controller exists
      if (variationControllers[index] != null) {
        variationControllers[index]!.value = TextEditingValue(
          text: variation.toString(),
          selection:
              TextSelection.collapsed(offset: variation.toString().length),
        );
      } else {
        log("Variation controller for index $index is null");
      }
    }

    if (quantity != null && isLoose == '0') {
      billingItems[index].quantity = quantity;

      // Ensure the controller exists
      if (quantityControllers[index] != null) {
        quantityControllers[index]!.value = TextEditingValue(
          text: quantity.toString()=="0"?"":quantity.toString(),
          selection:
              TextSelection.collapsed(offset: quantity.toString().length),
        );
      } else {
        log("Quantity controller for index $index is null");
      }
    }
    notifyListeners();
  }

  // void updateGSTItem(int index, {required String isLoose, double? variation, int? gst}) {
  //   if (index < 0 || index >= billingItems.length) {
  //     log("Invalid index: $index");
  //     return; // Exit if index is invalid
  //   }
  //   if (gst != null && isLoose == '0') {
  //     billingItems[index].sgst = gst.toString();
  //
  //     if (gstControllers[index] != null) {
  //       gstControllers[index]!.value = TextEditingValue(
  //         text: gst.toString()=="0"?"":gst.toString(),
  //         selection:
  //         TextSelection.collapsed(offset: quantity.toString().length),
  //       );
  //     } else {
  //       log("Quantity controller for index $index is null");
  //     }
  //   }
  //
  //   notifyListeners();
  // }

  /// Remove a billing item
  void removeBillingItem({required int index}) {
    if (index < 0 || index >= billingItems.length) return;
    billingItems.removeAt(index);
    variationControllers.removeAt(index);
    quantityControllers.removeAt(index);
    calculatedMrpSubtotal();
    calculateTotalItems();
    calculateTotalDiscount();
    calculatedGrandTotal();
    notifyListeners();
  }

  /// Calculate the grand total
  double get grandTotal {
    return billingItems.fold(
        0.0, (sum, item) => sum + item.calculateSubtotal());
  }

  /// Total No of Billing Items :
  int calculateTotalItems() {
    return billingItems.fold(0, (total, item) => total + item.quantity);
  }

  // Total Discount of Billing Items :
  String calculateTotalDiscount() {
    return TextFormat.formattedAmount(billingItems.fold(
        0.0, (total, item) => total + item.calculateDiscount()));
  }

  // Grand Total of Billing Items :
  // double calculatedGrandTotal() {
  //   return billingItems.fold(
  //       0.0, (total, item) => total + item.calculateSubtotal());
  // }
  double calculatedGrandTotal() {
    // Step 1: Total from all products
    double productsTotal = billingItems.fold(
      0.0,
          (total, item) => total + item.calculateSubtotal(),
    );
    double totalGst = calculateTotalGST();
    // Step 2: Get bill-level charges
    double cuttingPercent = double.tryParse(cuttingCharge.text) ?? 0.0;
    double loadingPercent = double.tryParse(loadingCharge.text) ?? 0.0;
    double freightPercent = double.tryParse(freightCharge.text) ?? 0.0;

    // Step 3: Calculate amounts
    double cuttingAmount = (productsTotal * cuttingPercent) / 100;
    double loadingAmount = (productsTotal * loadingPercent) / 100;
    double freightAmount = (productsTotal * freightPercent) / 100;

    // Step 4: Return final total
    return productsTotal + cuttingAmount + loadingAmount + freightAmount + totalGst;
  }


  String calculatedMrpSubtotal() {
    return TextFormat.formattedAmount(billingItems.fold(
        0.0, (total, item) => total + item.calculateMrpSubtotal()));
  }

  int calculatedTotalProducts() => billingItems.length;

  int calculatedTotalQuantity() =>
      billingItems.fold(0, (total, item) => total + item.quantity);

  double calculateTotalGST() {
    return billingItems.fold(
      0.0,
          (sum, item) => sum + (double.tryParse(item.sgst) ?? 0.0),
    );
  }

  double calculateTotalCGST() {
    return calculateTotalGST() / 2;
  }
  double calculateRoundOff() => (calculatedGrandTotal().roundToDouble() - calculatedGrandTotal());

  double calculateTotalSGST() {
    return calculateTotalGST() / 2;
  }

  /// --------- Print Bill / Place Order ---------------
  RoundedLoadingButtonController printButtonController =
      RoundedLoadingButtonController();
  RoundedLoadingButtonController paymentButtonController =
      RoundedLoadingButtonController();

  final BillPdf pdfService = BillPdf();

  // Place Order Api :
  Future<void> placeOrderAndPrintBill(context, {required Order order}) async {
    try {
      final response =
          await _placeOrderRepo.placeOrder(order: order, context: context);
      log("BIll:${order.customerId}");
      log("BIll:${order.products}");
      if (response.responseCode == 200) {
        log("BIll:$response");
        await pdfService.printBill(context,
            invoiceNo: response.invoiceNo ?? 0); // Prints Bill

        // Clear Billing Fields
        _billingItems = []; // Empty Billing items
        calculateTotalDiscount();
        calculateTotalItems();
        calculatedGrandTotal();

        // Clear Customer Fields
        order.customerName = '';
        order.customerMobile = '';
        order.customerAddress = '';

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const NewBillingScreen()));
      } else {
        Toasts.showToastBar(context: context, text: "Couldn't print receipts");
        printButtonController.reset();
        printAfterChangeButtonController.reset();
        notifyListeners();
      }
    } catch (e) {
      Toasts.showToastBar(
          context: context, text: 'Something went wrong. Try Again');
      throw Exception("placeOrder Provider Error : $e");
    } finally {
      printButtonController.reset();
      printAfterChangeButtonController.reset();
      notifyListeners();
    }
  }

  TextEditingController loadingCharge   = TextEditingController(text: '0');
  TextEditingController freightCharge   = TextEditingController(text: '0');
  TextEditingController cuttingCharge   = TextEditingController(text: '0');

  final FocusNode loadingChargeFocusNode = FocusNode();
  final FocusNode freightChargeFocusNode = FocusNode();
  final FocusNode cuttingChargeFocusNode = FocusNode();

  bool _isFooterButtons = false;
  bool get isFooterButtons => _isFooterButtons;
  void updateFooterButtons(){
    _isFooterButtons =! _isFooterButtons;
    _isFooterButtons =! _isFooterButtons;
    notifyListeners();
  }

  bool _barcodeMode = false;
  bool get barcodeMode => _barcodeMode;

  void barcodeModeChange() {
    _barcodeMode = !_barcodeMode;
    notifyListeners();
  }

  void findProductByBarcode(BuildContext context, String barcode) {
    try {
      final product = productsList.firstWhere((p) => p.barcode == barcode);

      selectedProduct = product;
      print("selectedProduct ${selectedProduct!.pTitle}");
      barcodeScanner.text = selectedProduct!.pTitle.toString();
      updateTemporaryFields(
        variation: product.isLoose == '1' ? 1.0 : null,
        quantity: product.isLoose == '0' ? 1 : null,
      );

      notifyListeners();
    } catch (e) {
      Toasts.showToastBar(
          context: context,
          text: "Please scan correct barcode..",
          color: Colors.red);
      // Product not found — you can log or show a message if needed
    }
  }

  List<String> billMethods = ["Cash", "Money Transfer", "Cheque"];
  List<FocusNode> billMethodFocusNodes = List.generate(4, (_) => FocusNode());
  String? selectBillMethod = "Cash";
  void changeBillMethod(String method) {
    selectBillMethod = method;
    notifyListeners();
  }

  final List<String> billTypes = ["Invoice", "Tax Invoice"];
  String _selectedType = "Invoice";

  String get selectedType => _selectedType;

  void selectType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  final List<String> gst = [
    "Non GST Cash Invoice",
    "GST Cash Invoice"
  ];

  String _selectedGst = "Non GST Cash Invoice";

  String get selectedGst => _selectedGst;

  void selectGst(String type) {
    if (_selectedGst != type) {
      _selectedGst = type;
      notifyListeners();
    }
  }


  List<String> sizes = ["A3", "A4", "A5", "Roll80"];
  String selectedSize = "Roll80";

  void selectSize(String size) {
    selectedSize = size;
    notifyListeners();
  }

  String billNo = "";
  List<BillObj> allBill = [];
  List<BillObj> get allBillList => allBill;
  Future<void> fetchBill(BuildContext context) async {
    try {
      PreviousBillObj response = await _productsRepo.getBill();
      if (response.responseCode == "200") {
        allBill = response.data;
        var i = int.parse(allBill[0].invoiceNo) + 1;
        billNo = i.toString();
      } else {
        billNo = '';
      }
    } catch (e) {
      log("get billNo Error: $e");
    } finally {
      await Future.delayed(
          const Duration(milliseconds: 10)); // let build complete
      notifyListeners(); // Now safe
    }
  }

  /// --------- Payment Box ----------------
  RoundedLoadingButtonController paymentBalanceButtonController =
      RoundedLoadingButtonController();
  RoundedLoadingButtonController printAfterChangeButtonController =
      RoundedLoadingButtonController();

  TextEditingController paymentReceived = TextEditingController();
  TextEditingController paymentBalance = TextEditingController();
  TextEditingController barcodeScanner = TextEditingController();

  String _paymentBalanceAmount = '';

  // Calculate Payment Balance
  void calculatePaymentBalance() {
    try {
      if (paymentReceived.text.isEmpty) {
        _paymentBalanceAmount = '0';
        paymentBalance.text = '0';
      } else {
        int receivedAmount = int.tryParse(paymentReceived.text.trim()) ?? 0;
        int grandTotal = calculatedGrandTotal().toInt();
        _paymentBalanceAmount = (receivedAmount - grandTotal).toString();
        paymentBalance.text = _paymentBalanceAmount;
      }
    } catch (e) {
      _paymentBalanceAmount = '0';
      paymentBalance.text = '0';
    }
  }

  final FocusNode keyboardListenerFocusNode = FocusNode();
  final billMethodFocusNode = FocusNode();
  // Show Payment Balance Dialog
  void showPaymentBalanceDialog(
    BuildContext context, {
    required void Function() onPressPrint,
  }) {
    paymentReceived.addListener(() {
      calculatePaymentBalance();
    });

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: MyText(
                  text: 'Print Bill',
                  fontSize: TextFormat.responsiveFontSize(context, 23),
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: IconButton(
                  icon: SvgPicture.asset("assets/images/clear.svg",width: 30,height: 30,),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          // icon: IconButton(
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //     },
          //     icon: const Icon(
          //       Icons.clear,
          //       color: Colors.red,
          //     )
          // ),
          // iconPadding: EdgeInsets.fromLTRB(300, 0, 1, 1),
          content: Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.30,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Display Total Amount
                RichText(
                  text: TextSpan(
                    text: 'Total Amount : ',
                    style: GoogleFonts.lato(
                      fontSize: TextFormat.responsiveFontSize(context, 20),
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text:
                            TextFormat.formattedAmount(calculatedGrandTotal()),
                        style: GoogleFonts.lato(
                          fontSize: TextFormat.responsiveFontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ),

                // Payment Received Input
                MyTextField(
                  height: null,
                  isOptional: true,
                  labelText: "Payment Received",
                  autofocus: true,
                  controller: paymentReceived,
                  inputFormatters: InputFormatters.mobileNumberInput,
                ),

                // Display Balance
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: paymentBalance,
                  builder: (context, value, child) {
                    return RichText(
                      text: TextSpan(
                        text: 'Balance:     ',
                        style: GoogleFonts.lato(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: value.text.contains('-')
                                ? value.text
                                : "₹ ${value.text}",
                            style: GoogleFonts.lato(
                              color: value.text.contains('-')
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const MyText(
                  text: 'Select Payment Method',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                KeyboardListener(
                  focusNode: keyboardListenerFocusNode,
                  onKeyEvent: (KeyEvent event) {
                    final currentIndex =
                        billMethods.indexOf(selectBillMethod ?? "");
                    if (event is KeyDownEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.enter ||
                          event.logicalKey == LogicalKeyboardKey.arrowRight) {
                        int next = (currentIndex + 1) % billMethods.length;
                        changeBillMethod(billMethods[next]);
                        billMethodFocusNodes[next].requestFocus();
                      } else if (event.logicalKey ==
                          LogicalKeyboardKey.arrowLeft) {
                        int prev = (currentIndex - 1 + billMethods.length) %
                            billMethods.length;
                        changeBillMethod(billMethods[prev]);
                        billMethodFocusNodes[prev].requestFocus();
                      }
                    }
                  },
                  child: Row(
                    children: List.generate(billMethods.length, (index) {
                      final method = billMethods[index];
                      return Row(
                        children: [
                          Radio<String>(
                            value: method,
                            focusNode: billMethodFocusNode,
                            groupValue: selectBillMethod,
                            activeColor: AppColors.primary,
                            onChanged: (value) {
                              changeBillMethod(value!);
                              billMethodFocusNodes[index].requestFocus();
                            },
                          ),
                          MyText(text: method, fontSize: 14),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          actions: [
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.pop(context);
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: AppColors.white,
            //     side: BorderSide(
            //         color: AppColors.primary),
            //     shape: RoundedRectangleBorder(
            //       borderRadius:
            //       BorderRadius.circular(5),
            //     ),
            //   ),
            //   child: const Text(
            //     "Cancel",
            //     style: TextStyle(
            //       color: AppColors.primary,
            //       fontSize: 14,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            Buttons.loginButton(
              context: context,
              loadingButtonController: printAfterChangeButtonController,
              toolTip: 'Print Bill',
              height: 45,
              onPressed: onPressPrint,
              text: 'Print',
            ),
          ],
        );
      },
    );
  }

  bool _isRefresh = true;
  bool get isRefresh => _isRefresh;
  List<OrderData> _lastOrder = [];
  List<OrderData> _allOrders = [];
  List<OrderData> _searchAllOrders = [];
  List<OrderData> get allOrders => _allOrders;
  List<OrderData> get searchAllOrders => _searchAllOrders;
  List<OrderData> get lastOrder => _lastOrder;
  final TextEditingController searchName = TextEditingController();
  final TextEditingController searchAmount = TextEditingController();
  final TextEditingController searchProd = TextEditingController();
  Future<void> getAllOrderDetails(String stDate, String enDate) async {
    try {
      _isRefresh = false;
      _allOrders = [];
      _searchAllOrders = [];
      notifyListeners();

      final response =
          await _placeOrderRepo.getOrderDetails(stDate: stDate, enDate: enDate);

      if (response.responseCode == '200') {
        print("getAllOrderDetails Response: ${response.ordersList}");
        _allOrders = response.ordersList ?? [];
        _searchAllOrders = response.ordersList ?? [];
        _isRefresh = true;
      } else {
        _isRefresh = true;
        _allOrders = [];
        _searchAllOrders = [];
      }
    } catch (e) {
      _isRefresh = true;
      _allOrders = [];
      _searchAllOrders = [];
      throw Exception(e);
    } finally {
      _isRefresh = true;
      notifyListeners();
    }
  }

  Future<void> getLastOrderDetails(context) async {
    try {
      _lastOrder = [];
      notifyListeners();
      final response = await _placeOrderRepo.getLastOrderDetails();

      if (response.responseCode == '200') {
        _lastOrder = response.ordersList ?? [];
        log("_lastOrder.toString()");
        log(_lastOrder.toString());
        await pdfService.printCustomBill(context, data: _lastOrder[0]);
      } else {
        _lastOrder = [];
      }
    } catch (e) {
      _lastOrder = [];
      throw Exception(e);
    } finally {
      _isRefresh = true;
      notifyListeners();
    }
  }

  String _nameQuery = '';
  String _totalQuery = '';
  String _productQuery = '';
  void setSearchQuery({String? name, String? total, String? product}) {
    if (name != null) _nameQuery = name.toLowerCase();
    if (total != null) _totalQuery = total.toLowerCase();
    if (product != null) _productQuery = product.toLowerCase();

    _filterOrders();
  }

  void _filterOrders() {
    _allOrders = _searchAllOrders.where((order) {
      final nameMatch = order.name?.toLowerCase().contains(_nameQuery) ?? false;

      bool totalMatch = true;
      if (_totalQuery.isNotEmpty) {
        final enteredAmount = int.tryParse(_totalQuery);
        final actualAmount = int.tryParse(order.oTotal ?? '');
        if (enteredAmount != null && actualAmount != null) {
          totalMatch = (actualAmount >= enteredAmount - 100 &&
              actualAmount <= enteredAmount + 100);
        } else {
          totalMatch = false;
        }
      }

      final productMatch =
          order.productTitles?.toLowerCase().contains(_productQuery) ?? false;

      return (_nameQuery.isEmpty || nameMatch) &&
          (_totalQuery.isEmpty || totalMatch) &&
          (_productQuery.isEmpty || productMatch);
    }).toList();

    notifyListeners();
  }

  void searchOrders(String value) {
    final suggestions = _searchAllOrders.where((user) {
      final name = user.name?.toLowerCase() ?? '';
      final oTotal = user.oTotal?.toLowerCase() ?? '';
      final productTitles = user.productTitles?.toLowerCase() ?? '';

      // Format the oDate to dd-MM-yyyy
      String formattedDate = '';
      if (user.oDate != null && user.oDate!.isNotEmpty) {
        try {
          DateTime parsedDate = DateTime.parse(user.oDate!);
          formattedDate =
              DateFormat('dd-MM-yyyy').format(parsedDate).toLowerCase();
        } catch (e) {
          // If parse fails, fallback to raw string
          formattedDate = user.oDate!.toLowerCase();
        }
      }

      final input = value.toLowerCase();

      return name.contains(input) ||
          formattedDate.contains(input) ||
          oTotal.contains(input) ||
          productTitles.contains(input);
    }).toList();

    _allOrders = suggestions;
    notifyListeners();
  }

  String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    String formatted = DateFormat('dd-MM-yyyy').format(date);
    return formatted;
  }
}
