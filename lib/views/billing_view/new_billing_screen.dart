import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fullcomm_billing/data/local_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fullcomm_billing/models/products_response.dart';
import 'package:fullcomm_billing/res/colors.dart';
import 'package:fullcomm_billing/res/components/buttons.dart';
import 'package:fullcomm_billing/res/components/k_loadings.dart';
import 'package:fullcomm_billing/res/components/k_text.dart';
import 'package:fullcomm_billing/res/components/screen_widgtes.dart';
import 'package:fullcomm_billing/utils/input_formatters.dart';
import 'package:fullcomm_billing/utils/sized_box.dart';
import 'package:fullcomm_billing/utils/text_formats.dart';
import 'package:fullcomm_billing/utils/toast_messages.dart';
import 'package:fullcomm_billing/view_models/billing_provider.dart';
import 'package:fullcomm_billing/view_models/credentials_provider.dart';
import 'package:fullcomm_billing/view_models/customer_provider.dart';
import 'package:provider/provider.dart';
import '../../data/project_data.dart';
import '../../models/billing_product.dart';
import '../../models/customers_response.dart';
import '../../models/place_order.dart';
import '../../res/components/customer_widgets.dart';
import '../../res/components/k_dropdown_menu.dart';
import '../../res/components/k_text_field.dart';
import '../../res/components/keyboard_search.dart';
import '../create_customer_screen.dart';
import '../orders/order_detail_page.dart';

class NextPageIntent extends Intent {
  const NextPageIntent();
}

class ActivateIntent extends Intent {
  const ActivateIntent();
}

class LastBillIntent extends Intent {
  const LastBillIntent();
}

class AltOnlyIntent extends Intent {
  const AltOnlyIntent();
}

class NewBillingScreen extends StatefulWidget {
  const NewBillingScreen({super.key});

  @override
  State<NewBillingScreen> createState() => _NewBillingScreenState();
}

class _NewBillingScreenState extends State<NewBillingScreen> {
  final FocusNode dropdownFocusNode = FocusNode();
  final FocusNode fieldFocusNode = FocusNode();
  final TextEditingController dropdownController = TextEditingController();
  final TextEditingController quantityVariationController =
      TextEditingController();

  // For Scrolling Billing Table :
  ScrollController scrollController = ScrollController();

  void scrollDown() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + kBottomNavigationBarHeight,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      log("ScrollController is not attached to any scroll view.");
    }
  }

  FocusNode _focusNode = FocusNode();
  FocusNode _focusNodeSearch = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode.requestFocus();
    _focusNodeSearch.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      await Provider.of<UserDataProvider>(context, listen: false).initializeUserData(); // Fetch all Products & Stocks
      Provider.of<BillingProvider>(context, listen: false).getProducts(); // Fetch all Products & Stocks
      Provider.of<CustomersProvider>(context, listen: false).getAllCustomers(context); // Fetch all Products & Stocks
      Provider.of<CustomersProvider>(context, listen: false).resetCustomerDetails(); // Reset Customer details
      Provider.of<BillingProvider>(context, listen: false).fetchBill(context);
      Provider.of<BillingProvider>(context, listen: false).setBillingItems([]); // Set Billing Items with Empty Table
    });
  }

  @override
  void dispose() {
    _focusNodeSearch.dispose();
    dropdownFocusNode.dispose();
    fieldFocusNode.dispose();
    dropdownController.dispose();
    quantityVariationController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Consumer3<UserDataProvider, CustomersProvider, BillingProvider>(
        builder:
            (context, userDataProvider, customerProvider, billingProvider, _) {
      return Shortcuts(
          shortcuts: <LogicalKeySet, Intent>{
            LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.keyP):
                const ActivateIntent(),
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyP):
                const ActivateIntent(),
            LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.keyS):
                const NextPageIntent(),
            LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.keyR):
                const LastBillIntent(),
            LogicalKeySet(LogicalKeyboardKey.alt): const AltOnlyIntent(),
          },
          child: Actions(
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (intent) {
                  if (billingProvider.billingItems.isNotEmpty) {
                    billingProvider.paymentReceived.clear();
                    billingProvider.paymentBalance.clear();
                    showPaymentBalanceDialog(context, onPressPrint: () {
                      if (customerProvider.selectedCustomerId.isEmpty) {
                        customerProvider.setCustomerDetails(
                            customerId: ProjectData.cashId,
                            customerName: "Cash",
                            customerMobile: "1212121212",
                            customerAddress: "Chennai",deliveryAddress: "");
                      }
                      billingProvider.placeOrderAndPrintBill(
                        context,
                        order: Order(
                            customerMobile: customerProvider.selectedCustomerMobile,
                            customerId: customerProvider.selectedCustomerId,
                            customerName: customerProvider.selectedCustomerName,
                            customerAddress: customerProvider.customerAddressController.text,
                            cashier: billingProvider.cashierNameController.text.trim(),
                            paymentMethod: billingProvider.selectBillMethod.toString(),
                            paymentId: billingProvider.selectBillMethod.toString() == "Cash"
                                    ? '2'
                                    : '1',
                            products: billingProvider.billingItems,
                            orderGrandTotal: billingProvider
                                .calculatedGrandTotal()
                                .toString(),
                            orderSubTotal: billingProvider
                                .calculatedGrandTotal()
                                .toString(),
                            receivedAmt: billingProvider
                                    .paymentReceived.text.isEmpty
                                ? "0.0"
                                : double.parse(billingProvider.paymentReceived.text)
                                    .toStringAsFixed(1),
                            payBackAmt:
                                (((billingProvider.paymentReceived.text.isEmpty
                                            ? 0.0
                                            : double.parse(
                                                billingProvider.paymentReceived.text)) -
                                        billingProvider.calculatedGrandTotal())
                                    .abs()
                                    .toStringAsFixed(2)),
                            savings: '${billingProvider.billingItems.fold(0.0, (total, item) => total + item.calculateDiscount())}'),
                      );
                    });
                  } else {
                    billingProvider.printButtonController.reset();
                    Toasts.showToastBar(
                        context: context,
                        text: 'Bill List is empty',
                        color: Colors.red);
                  }
                  return null;
                },
              ),
              NextPageIntent: CallbackAction<NextPageIntent>(
                onInvoke: (intent) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const OrderDetailPage()));
                  return null;
                },
              ),
              LastBillIntent: CallbackAction<LastBillIntent>(
                onInvoke: (intent) {
                  billingProvider.getLastOrderDetails(context);
                  return null;
                },
              ),
              AltOnlyIntent: CallbackAction<Intent>(
                onInvoke: (intent) {
                  return null;
                },
              ),
            },
            child: Focus(
              focusNode: _focusNode,
              autofocus: true,
              child: PopScope(
                canPop: false,
                child: Scaffold(
                  backgroundColor: Color(0xffffffff),
                  appBar: AppBar(
                    backgroundColor: Color(0xffffffff),
                    toolbarHeight: 100,
                    leadingWidth: 150,
                    leading: Image.asset(
                      'assets/logo/app_logo.png',
                      width: 100,
                      height: 90,
                    ),

                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText(
                          text: "ARUU Billing Portal",
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.bold
                        ),
                        MyText(
                            text: " v${ProjectData.version}",
                            color: Colors.grey,
                            fontSize: 15,
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                    centerTitle: true,
                    actions: [
                      CustomerFieldWidgets.iconButton(
                        context: context,
                        toolTip: 'Search bill',
                        icon: 'assets/images/bill.svg',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const OrderDetailPage()),
                          );
                        },
                      ),
                      20.width,
                      CustomerFieldWidgets.iconButton(
                        context: context,
                        toolTip: 'Add Customer',
                        icon: 'assets/images/customer.svg',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AddCustomerDialog(),
                          );
                          //customerProvider.addCustomerDialog(context);
                        },
                      ),
                      20.width,
                      CustomerFieldWidgets.iconButton(
                        context: context,
                        toolTip: 'Refresh Stock Status',
                        icon: 'assets/images/Refresh.svg',
                        onPressed: () {
                          billingProvider.getProducts();
                        },
                      ),
                      20.width,
                      CustomerFieldWidgets.iconButton(
                        context: context,
                        toolTip: 'Logout',
                        icon: 'assets/images/logout.svg',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: AppColors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Do you want to log out?",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.white,
                                            side: BorderSide(
                                                color: AppColors.primary),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                          child: const Text(
                                            "No",
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton(
                                          onPressed: () async {
                                            userDataProvider.logout(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            side: BorderSide(
                                                color: AppColors.secondary),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                          child: const Text(
                                            "Yes",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  body: GestureDetector(
                    onTap: () {
                      _focusNode.requestFocus();
                    },
                    child: billingProvider.isLoading
                        ? LoadingWidgets.circleLoading()
                        : SingleChildScrollView(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    width: screenWidth,
                                    height: 80,
                                    alignment: Alignment.center,
                                    color: Color(0xfffdfafa),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                              // Cashier Name
                                                    Text.rich(
                                                      TextSpan(
                                                        text: '  Bill No :  ',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: AppColors.ash,
                                                        ),
                                                        children: [
                                                          TextSpan(
                                                            text: billingProvider.billNo ??'',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: AppColors.black,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  10.width,
                                                  Text.rich(
                                                    TextSpan(
                                                      text: 'Cashier Name:  ',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color: AppColors.ash,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text: localData.userName,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: AppColors.black,
                                                            fontWeight:
                                                            FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                      SizedBox(
                                        width: screenWidth*0.10,
                                      ),
                                              // Customer Address
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(
                                                    0, 0, 10, 0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    MyText(
                                                        text: 'Customer',
                                                        fontSize: 13,
                                                        color: Color(0xff9E9E9E)),
                                                    SizedBox(
                                                      width: screenWidth * 0.20,
                                                      height: 50,
                                                      child: KeyboardDropdownField<Customer>(
                                                        items: customerProvider.allCustomersList,
                                                        borderRadius: 5,
                                                        borderColor: Colors.grey.shade300,
                                                        hintText: "Cust. Contact",
                                                        labelText: "",
                                                        labelBuilder: (customer) =>'${customer.name} - ${customer.mobile}',
                                                        itemBuilder: (customer) =>
                                                            Container(
                                                              width: screenWidth * 0.20,
                                                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                              child: MyText(
                                                                text: '${customer.name} - ${customer.mobile}',
                                                                color: Colors.black,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                        textEditingController: customerProvider.cusController,
                                                        onSelected: (value) {
                                                          String formatAddress(AddressDetail? value) {
                                                            if (value == null) return '';
                                                            return "${value.addressLine1} ${value.area} ${value.city} ${value.state}-${value.pincode}".replaceAll(',,', ',');
                                                          }

                                                          AddressDetail? homeAddress;
                                                          List<AddressDetail> deliveryAddresses = [];

                                                          // Get Home address (only one)
                                                          try {
                                                            homeAddress = value.addressDetails!.firstWhere(
                                                                  (e) => e.type!.toLowerCase() == 'home',
                                                            );
                                                          } catch (_) {}

                                                          // Get all Delivery addresses as a list
                                                          deliveryAddresses = value.addressDetails!
                                                              .where((e) => e.type!.toLowerCase() == 'delivery')
                                                              .toList();

                                                          // Format all delivery addresses as list of strings
                                                          List<String> deliveryFormattedList =
                                                          deliveryAddresses.map((addr) => formatAddress(addr)).toList();

                                                          // Example: If you want to use only the first delivery address:
                                                          String deliveryFormatted = deliveryFormattedList.isNotEmpty ? deliveryFormattedList.first : '';
                                                          customerProvider.setDeliveryAddressList(deliveryFormattedList);
                                                          customerProvider.setSelectedDeliveryAddress(deliveryFormattedList.isEmpty?"":deliveryFormattedList.first);
                                                          customerProvider.deliveryAddressController.text = deliveryFormattedList.first;
                                                          print("Delivery Addresses: ${customerProvider.deliveryAddressController.text} $deliveryFormatted");
                                                          customerProvider.setCustomerDetails(
                                                              customerId: value.userId.toString(),
                                                              customerName: value.name.toString(),
                                                              customerMobile: value.mobile.toString(),
                                                              customerAddress: formatAddress(homeAddress),
                                                              deliveryAddress: deliveryFormatted
                                                          );
                                                          _focusNode.requestFocus();
                                                        },
                                                        onClear: () {
                                                          customerProvider.setCustomerDetails(
                                                              customerId: "",
                                                              customerName: "",
                                                              customerMobile: "",
                                                              customerAddress: "",
                                                              deliveryAddress: ""
                                                          );
                                                          //quantityVariationController.clear();
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  MyText(
                                                      text: 'Customer Address',
                                                      fontSize: 13,
                                                      color: Color(0xff9E9E9E)),
                                                  MyTextField(
                                                    width: screenWidth * 0.20,
                                                    height: 50,
                                                    isOptional: true,
                                                    controller: customerProvider.customerAddressController,
                                                    hintText: "Customer Address",
                                                    labelText: '',
                                                    focusedBorderColor: AppColors.primary,
                                                    enabledBorderColor: Colors.grey.shade300,
                                                    fillColor: Color(0xffffffff),
                                                    borderRadius: 5,
                                                    //maxLines: null,
                                                    //minLines: 2,
                                                  ),
                                                ],
                                              ),
                                              10.width,
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      MyText(
                                                        text: "Delivery Address",
                                                        fontSize: 13,
                                                        color: Color(0xff9E9E9E),
                                                      ),
                                                 SizedBox(
                                                            width: screenWidth * 0.20,
                                                            height: 40,
                                                            child: Consumer<CustomersProvider>(
                                                              builder: (context, provider, _) {
                                                                return SizedBox(
                                                                  width: screenWidth * 0.20,
                                                                  height: 40,
                                                                    child: MyDropdownMenu<String>(
                                                                      width:screenWidth * 0.20,
                                                                      enableSearch: true,
                                                                      enableFilter: true,
                                                                      menuHeight: 350,
                                                                      initialSelection: provider.selectedDeliveryAddress,
                                                                      inputFormatters: InputFormatters.textOnlyInput,
                                                                      controller: customerProvider.deliveryAddressController,
                                                                      dropdownMenuEntries:provider.deliveryAddressList.map((state) {
                                                                        return MyDropdownMenuEntry<String>(
                                                                          value: state,
                                                                          enabled: true,
                                                                          label: state,
                                                                        );
                                                                      }).toList(),
                                                                      menuStyle: MenuStyle(
                                                                        backgroundColor: WidgetStatePropertyAll(Colors.white),
                                                                      ),
                                                                      hintText: provider.selectedDeliveryAddress.toString().isEmpty?
                                                                      "Select Delivery Address" :
                                                                      provider.selectedDeliveryAddress,
                                                                      onSelected: (selectedAddress) {
                                                                        provider.setSelectedDeliveryAddress(selectedAddress);
                                                                      },
                                                                    ),
                                                                );
                                                              },
                                                            ),)
                                                    ],
                                                  ),
                                          10.width,
                                                  Container(
                                                    height: 70,
                                                    alignment: Alignment.center,
                                                    child: IconButton(
                                                        tooltip: "Add Delivery Address",
                                                        onPressed: (){
                                                          if(customerProvider.selectedCustomerMobile == '' || customerProvider.selectedCustomerName == ''){
                                                            Toasts.showToastBar(
                                                                context: context,
                                                                text: 'Please Select Customer',
                                                                color: AppColors.errorMessage);
                                                          }else{
                                                            customerProvider.addDeliveryAddressDialog(context);
                                                          }
                                                        },
                                                        icon:  Icon(Icons.add_circle,color:AppColors.primary)),
                                                  ),
                                                  10.width
                                        ],
                                      ),
                                    ),
                                  ),
                                10.height,

                                /// Fixed Header:
                                // Row containing Search Dropdown and Variation/Quantity field
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    /// Searchable DropdownMenu (Header)
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          billingProvider.barcodeMode
                                              ? MyTextField(
                                                  width: screenWidth * 0.55,
                                                  height: 45,
                                                  isOptional: true,
                                                  controller: billingProvider.barcodeScanner,
                                                  labelText: 'Scan...',
                                                  maxLines: null,
                                                  minLines: 2,
                                            focusedBorderColor: AppColors.primary,
                                            enabledBorderColor: Color(0xff9e9e9e),
                                                  //textAlign: TextAlign.left,
                                                  autofocus: true,
                                                  onChanged: (value) {
                                                    print("Barcode value $value");
                                                    //billingProvider.findProductByBarcode(value);
                                                  },
                                                  onEditingComplete: () {
                                                    //billingProvider.findProductByBarcode(context,billingProvider.barcodeScanner.text);
                                                    try {
                                                      final product = billingProvider
                                                          .productsList
                                                          .firstWhere((p) =>
                                                              p.barcode ==
                                                              billingProvider
                                                                  .barcodeScanner
                                                                  .text);

                                                      billingProvider.selectedProduct =product;
                                                      billingProvider.barcodeScanner.text =
                                                          "${billingProvider.selectedProduct!.pTitle.toString()} ${billingProvider.selectedProduct!.pVariation.toString()}${billingProvider.selectedProduct!.unit.toString()}";
                                                      // billingProvider.updateTemporaryFields(
                                                      //   variation: product.isLoose == '1'
                                                      //           ? 1.0
                                                      //           : null,
                                                      //   quantity: product.isLoose == '0'
                                                      //           ? 1
                                                      //           : null,
                                                      // );
                                                      fieldFocusNode.requestFocus();
                                                    } catch (e) {
                                                      Toasts.showToastBar(
                                                          context: context,
                                                          text:
                                                              "Please scan correct barcode..",
                                                          color: Colors.red);
                                                      // Product not found — you can log or show a message if needed
                                                    }
                                                  },
                                                )
                                              : SizedBox(
                                                  width: screenWidth * 0.55,
                                                  child: KeyboardDropdownField<ProductData>(
                                                    borderRadius: 20,
                                                    borderColor: Color(0xff9E9E9E),
                                                    focusNode: dropdownFocusNode,
                                                    items: billingProvider.productsList,
                                                    hintText: "Search Product...",
                                                    labelText: " Product",
                                                    labelBuilder: (product) => product.isLoose == '0'
                                                        ? '${product.pTitle} ${product.pVariation}${product.unit}'
                                                        : '${product.pTitle} (${product.pVariation})',
                                                    itemBuilder: (product) =>
                                                        Container(
                                                      width: screenWidth * 0.60,
                                                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          MyText(
                                                            text: product.isLoose == '0'
                                                                ? '${product.pTitle} ${product.pVariation}${product.unit}'
                                                                : '${product.pTitle} (${product.pVariation})',
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                          ),
                                                          SizedBox(
                                                            width: 70,
                                                            child: MyText(
                                                              text: product.isLoose == '1'
                                                                  ? "₹${(double.parse(product.mrp.toString()) / (double.parse(product.stockQty.toString()) / 1000)).toStringAsFixed(1)}/kg"
                                                                  : "₹${double.parse(product.mrp.toString()).toStringAsFixed(1)}",
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.orange,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    textEditingController: dropdownController,
                                                    onSelected: (product) {
                                                      billingProvider.selectedProduct = product;
                                                      billingProvider.updateTemporaryFields(
                                                        variation: product.isLoose == '1'
                                                                ? 1.0
                                                                : null,
                                                        quantity: product.isLoose == '0'
                                                                ? 1
                                                                : null,
                                                      );
                                                      fieldFocusNode.requestFocus();
                                                    },
                                                    onClear: () {
                                                      billingProvider.selectedProduct = null;
                                                      billingProvider.updateTemporaryFields(
                                                        quantity: 0,
                                                        variation: 0.0,
                                                      );
                                                      //quantityVariationController.clear();
                                                    },
                                                  ),
                                                ),
                                          10.width,
                                          IconButton(
                                              tooltip: billingProvider.barcodeMode
                                                  ? 'Search Products'
                                                  : 'Scan Products',
                                              onPressed: () {
                                                //controller.barcodeMode.value = !controller.barcodeMode.value;
                                                if (billingProvider.barcodeMode) {
                                                  dropdownFocusNode.requestFocus();
                                                }
                                                billingProvider.barcodeModeChange();

                                                print(
                                                    "scan ${billingProvider.barcodeMode}");
                                              },
                                              icon: billingProvider.barcodeMode
                                                  ? const Icon(Icons.search,
                                                      color: Colors.grey)
                                                  : const Icon(
                                                      Icons.barcode_reader,
                                                      color: Colors.grey)),
                                          30.width,

                                          /// Variation/Quantity field (Header)
                                          Container(
                                            width: screenWidth * 0.10,
                                            alignment: Alignment.center,
                                            child: MyTextField(
                                              focusNode: fieldFocusNode,
                                              isOptional: true,
                                              height: 50,
                                              focusedBorderColor: AppColors.primary,
                                              enabledBorderColor: Color(0xff9e9e9e),
                                              controller:
                                                  quantityVariationController,
                                              labelText: billingProvider
                                                          .selectedProduct
                                                          ?.isLoose ==
                                                      '1'
                                                  ? "Variation(kg)"
                                                  : "Quantity",
                                              keyboardType: TextInputType.number,
                                              inputFormatters: billingProvider
                                                          .selectedProduct
                                                          ?.isLoose == '1'
                                                  ? InputFormatters.variationInput
                                                  : InputFormatters.quantityInput,
                                              //     : [
                                              //   StrictNonZeroIntFormatter(),
                                              // ],
                                              onChanged: (value) {
                                                if (billingProvider.selectedProduct != null) {
                                                  if (billingProvider.selectedProduct!.isLoose == '1') {
                                                    billingProvider.updateTemporaryFields(
                                                      variation: (double.parse(value) * 1000),
                                                    );
                                                  } else {
                                                    billingProvider
                                                        .updateTemporaryFields(
                                                      quantity: int.tryParse(
                                                              value) ??
                                                          billingProvider
                                                              .temporaryQuantity,
                                                    );
                                                  }
                                                } else {
                                                  // Optionally reset focus or show a message
                                                  //dropdownFocusNode.requestFocus();
                                                  Toasts.showToastBar(
                                                      context: context,
                                                      text: "Please add product",
                                                      color: Colors.red);
                                                }
                                              },
                                              onFieldSubmitted: (_) {
                                                if (billingProvider.selectedProduct != null) {
                                                  int stockQty = int.parse(billingProvider.selectedProduct!.stockQty.toString());
                                                  int enteredQty = int.tryParse(quantityVariationController.text) ?? 0;
                                                  if (enteredQty > stockQty) {
                                                    Toasts.showToastBar(
                                                      context: context,
                                                      text: "Entered quantity is more than the available stock ($stockQty).",
                                                      color: Colors.red,
                                                    );
                                                    fieldFocusNode.requestFocus();
                                                  } else {
                                                    billingProvider.addBillingItem(
                                                      BillingItem(
                                                        id: billingProvider.selectedProduct!.id!.toString(),
                                                        product: billingProvider.selectedProduct!,
                                                        productTitle: billingProvider.selectedProduct!.isLoose == '0'
                                                            ? billingProvider.selectedProduct!.pTitle.toString()
                                                            : "${billingProvider.selectedProduct!.pTitle} ${billingProvider.temporaryVariation / 1000}kg",
                                                        variation: billingProvider.selectedProduct!.isLoose == '1'
                                                            ? billingProvider.temporaryVariation
                                                            : 1,
                                                        variationUnit:
                                                        "${billingProvider.selectedProduct!.pVariation}${billingProvider.selectedProduct!.unit}",
                                                        quantity: billingProvider.selectedProduct!.isLoose == '0'
                                                            ? billingProvider.temporaryQuantity
                                                            : 1,
                                                        proController: TextEditingController(),
                                                        proFocusNode: FocusNode(),
                                                      ),
                                                    );
                                                    billingProvider.barcodeScanner.text = "";
                                                    billingProvider.selectedProduct = null;
                                                    scrollDown();
                                                    dropdownFocusNode.requestFocus();
                                                    dropdownController.clear();
                                                    quantityVariationController.clear();
                                                  }
                                                  // Scroll to bottom
                                                } else {
                                                  log("No product selected!");
                                                  Toasts.showToastBar(
                                                      context: context,
                                                      text: "Please add product",
                                                      color: Colors.red);
                                                  // Reset focus back to dropdown
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              billingProvider.getLastOrderDetails(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                side: BorderSide(
                                                  color: Color(0xff0055989),
                                                  width:
                                                      1.5,
                                                ),
                                              ),
                                              minimumSize: const Size(120, 48),
                                            ),
                                            child: MyText(
                                              text: 'Reprint',
                                              color: AppColors.secondary,
                                              fontSize: 14,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if (billingProvider.billingItems.isNotEmpty) {
                                                billingProvider.paymentReceived.clear();
                                                billingProvider.paymentBalance.clear();
                                                showPaymentBalanceDialog(context,
                                                    onPressPrint: () {
                                                  if (customerProvider
                                                      .selectedCustomerId
                                                      .isEmpty) {
                                                    customerProvider
                                                        .setCustomerDetails(
                                                            customerId:
                                                                ProjectData
                                                                    .cashId,
                                                            customerName: "Cash",
                                                            customerMobile:
                                                                "1212121212",
                                                            customerAddress:
                                                                "Chennai",deliveryAddress: "");
                                                  }
                                                  billingProvider.placeOrderAndPrintBill(
                                                    context,
                                                    order: Order(
                                                        customerMobile: customerProvider
                                                            .selectedCustomerMobile,
                                                        customerId: customerProvider
                                                            .selectedCustomerId,
                                                        customerName: customerProvider
                                                            .selectedCustomerName,
                                                        customerAddress: customerProvider
                                                            .customerAddressController
                                                            .text,
                                                        cashier: localData.userName,
                                                        paymentMethod: billingProvider
                                                            .selectBillMethod
                                                            .toString(),
                                                        paymentId: billingProvider.selectBillMethod.toString() == "Cash"
                                                            ? '2'
                                                            : '1',
                                                        products: billingProvider
                                                            .billingItems,
                                                        orderGrandTotal: billingProvider
                                                            .calculatedGrandTotal()
                                                            .toString(),
                                                        orderSubTotal: billingProvider
                                                            .calculatedGrandTotal()
                                                            .toString(),
                                                        receivedAmt: billingProvider
                                                                .paymentReceived
                                                                .text
                                                                .isEmpty
                                                            ? "0.0"
                                                            : double.parse(billingProvider.paymentReceived.text).toStringAsFixed(1),
                                                        payBackAmt: (((billingProvider.paymentReceived.text.isEmpty ? 0.0 : double.parse(billingProvider.paymentReceived.text)) - billingProvider.calculatedGrandTotal()).abs().toStringAsFixed(2)),
                                                        savings: '${billingProvider.billingItems.fold(0.0, (total, item) => total + item.calculateDiscount())}'),
                                                  );
                                                });
                                              } else {
                                                billingProvider.printButtonController.reset();
                                                Toasts.showToastBar(
                                                    context: context,
                                                    text: 'Bill List is empty',
                                                    color: Colors.red);
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                side: BorderSide(
                                                  color: Color(0xff0055989),
                                                  width: 1.5,
                                                ),
                                              ),
                                              minimumSize: const Size(120, 48),
                                            ),
                                            child: MyText(
                                              text: 'Print Bill',
                                              color: AppColors.secondary,
                                              fontSize:14,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                10.height,

                                ///  Billing Table :
                                billingProvider.billingItems.isEmpty
                                    ? SizedBox(
                                        width: 260,
                                        child: Column(
                                          children: [
                                            ScreenWidgets.emptyAlert(context,
                                                image: 'assets/images/noproduct.svg',
                                                text: 'No Product Found'),
                                          ],
                                        ),
                                      )
                                    : ClipRRect(
                                      borderRadius: BorderRadius.circular(0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xfff0f9ff),
                                          borderRadius:
                                              BorderRadius.circular(0),
                                          // border: Border.all(
                                          //   color: Color(0xfff3f3f2),
                                          //   width: 2.0,
                                          // ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.8), // darker shadow
                                              spreadRadius: 0, // no side spread
                                              blurRadius: 12, // softer & bigger shadow
                                              offset: const Offset(0, 8), // more downward distance
                                            ),
                                          ],
                                        ),
                                        child:
                                            // Table Headings
                                            Container(
                                              width: screenWidth * 0.98,
                                              color: Color(0xffF0F9FF),
                                              height: 420,
                                              child: SingleChildScrollView(
                                                child: DataTable(
                                                  dividerThickness: 0,
                                                  showBottomBorder: false,
                                                  dataRowHeight:
                                                      50, // Row height for all data rows
                                                  headingRowHeight: 50,
                                                  horizontalMargin: 0,
                                                  // Height for header row
                                                  border: const TableBorder(
                                                    verticalInside:
                                                        BorderSide(
                                                            width: 1,
                                                            color: Color(
                                                                0xff9E9E9E)),
                                                    top: BorderSide.none,
                                                    bottom:
                                                        BorderSide.none,
                                                    horizontalInside:
                                                        BorderSide.none,
                                                  ), // Column lines
                                                  headingRowColor:
                                                      MaterialStateProperty
                                                          .resolveWith(
                                                    (states) => Color(
                                                        0xff0078D7), // Header background
                                                  ),
                                                  columns: [
                                                    DataColumn(
                                                      headingRowAlignment: MainAxisAlignment.center,
                                                      label: Text(
                                                          "Change\nName",
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                              color: Colors.white)),
                                                    ),
                                                    DataColumn(
                                                      headingRowAlignment: MainAxisAlignment.center,
                                                      label: SizedBox(
                                                        height: 50,
                                                        child: Center(
                                                            child: MyText(
                                                                text:
                                                                    "S.No",
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      headingRowAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      label: SizedBox(
                                                        height: 50,
                                                        child: Center(
                                                            child: MyText(
                                                                text:
                                                                    "Product",
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      headingRowAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      label: SizedBox(
                                                        height: 50,
                                                        child: Center(
                                                            child: MyText(
                                                                text:
                                                                    "Variation",
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      headingRowAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      label: SizedBox(
                                                        height: 50,
                                                        child: Center(
                                                            child: MyText(
                                                                text:
                                                                    "Quantity",
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      headingRowAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                      label: SizedBox(
                                                        height: 50,
                                                        child: Center(
                                                            child: MyText(
                                                                text:
                                                                "GST",
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      headingRowAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      label: SizedBox(
                                                        height: 50,
                                                        child: Center(
                                                            child: MyText(
                                                                text:
                                                                    "MRP",
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      headingRowAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      label: SizedBox(
                                                        height: 50,
                                                        child: Center(
                                                            child: MyText(
                                                                text:
                                                                    "Our Price",
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      headingRowAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      label: SizedBox(
                                                        height: 50,
                                                        child: Center(
                                                            child: MyText(
                                                                text:
                                                                    "Discount",
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      headingRowAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      label: SizedBox(
                                                        height: 50,
                                                        child: Center(
                                                            child: MyText(
                                                                text:
                                                                    "SubTotal",
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      headingRowAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      label: SizedBox(
                                                        height: 50,
                                                        child: Center(
                                                            child: MyText(
                                                                text:
                                                                    "Remove",
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                    ),
                                                  ],
                                                  rows: List.generate(
                                                      billingProvider
                                                          .billingItems
                                                          .length,
                                                      (index) {
                                                    final billProduct =
                                                        billingProvider.billingItems[index];
                                                    return DataRow(
                                                      color:
                                                          MaterialStateProperty
                                                              .resolveWith(
                                                        (states) => index %
                                                                    2 ==
                                                                0
                                                            ? Colors.white
                                                            : const Color(0xffD9EEFF),
                                                      ),
                                                      cells: [
                                                        DataCell(
                                                          Center(
                                                            child:
                                                                IconButton(
                                                              icon:SvgPicture.asset("assets/images/edit.svg",width: 20,height: 20,),
                                                              tooltip:
                                                                  'Edit Product Name',
                                                              onPressed: () {
                                                                    if(billProduct.product.pTitle.toString().isNotEmpty){
                                                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                                                          setState(() {
                                                                            billProduct.proController.clear();
                                                                            billProduct.proFocusNode.requestFocus();
                                                                            customerProvider.showInputDialog(
                                                                              context: context,
                                                                              width: screenWidth * 0.20,
                                                                              height: screenHeight * 0.07,
                                                                              controller: billProduct.proController,
                                                                              focus: billProduct.proFocusNode,
                                                                              onChanged: () {
                                                                                setState(() {
                                                                                  final text = billProduct.proController.text;
                                                                                  if (text.isNotEmpty) {
                                                                                    billProduct.product.pTitle = "${billProduct.productTitle}/$text";
                                                                                    Navigator.of(context).pop();
                                                                                  } else {
                                                                                    Toasts.showToastBar(
                                                                                      context: context,
                                                                                      text: 'Please Fill Product Name',
                                                                                    );
                                                                                  }
                                                                                });
                                                                              },
                                                                              onSubmitted: (_) {
                                                                                final text = billProduct.proController.text;
                                                                                if (text.isNotEmpty) {
                                                                                  billProduct.product.pTitle = "${billProduct.productTitle}/$text";
                                                                                }
                                                                                Navigator.pop(context);
                                                                              },
                                                                            );
                                                                          });

                                                                      });

                                                                    }else{
                                                                      Toasts.showToastBar(
                                                                          context: context,
                                                                          text: 'Please Select Product Name');
                                                                    }
                                                                // Your existing edit logic here
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(Center(
                                                            child: Text(
                                                          "${index + 1}",
                                                          textAlign:
                                                              TextAlign
                                                                  .center,
                                                        ))),
                                                        DataCell(Center(
                                                          child: Text(
                                                            billProduct.product
                                                                        .isLoose ==
                                                                    '1'
                                                                ? "${billProduct.product.pTitle}"
                                                                : "${billProduct.product.pTitle} ${billProduct.product.pVariation ?? ""}${billProduct.product.unit ?? ""}",
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                          ),
                                                        )),
                                                        DataCell(
                                                          // billProduct.product.isLoose == '1'
                                                          //     ? SizedBox(
                                                          //         height: 40,
                                                          //         child: TextFormField(
                                                          //           controller: TextEditingController(
                                                          //             text: "${billProduct.variation / 1000}",
                                                          //           ),
                                                          //           keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                          //           onChanged: (value) {
                                                          //             // optional: validation / preview only
                                                          //           },
                                                          //           textAlign: TextAlign.center,
                                                          //           decoration: const InputDecoration(
                                                          //             border: InputBorder.none, // Removes underline
                                                          //             isDense: true, // Reduces padding
                                                          //             contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                          //           ),
                                                          //           onFieldSubmitted: (value) {
                                                          //             final parsed = double.tryParse(value);
                                                          //             if (parsed != null && parsed > 0) {
                                                          //               billingProvider.updateBillingItem(
                                                          //                 index,
                                                          //                 isLoose: '1',
                                                          //                 variation: parsed * 1000, // store in grams
                                                          //               );
                                                          //             } else {
                                                          //               Toasts.showToastBar(
                                                          //                 context: context,
                                                          //                 text: 'Please enter valid weight',
                                                          //               );
                                                          //             }
                                                          //           },
                                                          //         ),
                                                          //         // child: TextFormField(
                                                          //         //   controller: TextEditingController(
                                                          //         //     text: "${billProduct.variation / 1000}",
                                                          //         //   ),
                                                          //         //   onChanged: (value) {
                                                          //         //     billingProvider.updateBillingItem(
                                                          //         //       index,
                                                          //         //       isLoose: '1',
                                                          //         //       variation: double.tryParse(value) ?? billProduct.variation * 1000,
                                                          //         //     );
                                                          //         //   },
                                                          //         // ),
                                                          //       ):
                                                        billProduct.product.isLoose == '1'?Center(
                                                        child: Text(
                                                        billProduct.variationUnit,
                                                        )):Center(
                                                                  child: Text(
                                                                  billProduct.variationUnit ?? "",
                                                                )),
                                                        ),
                                                        DataCell(
                                                          billProduct.product.isLoose == '0'
                                                              ? SizedBox(
                                                                  height:
                                                                      40,
                                                                  child:
                                                                      TextFormField(
                                                                    controller: billingProvider.quantityControllers[index] ??
                                                                        TextEditingController(
                                                                          text: "${billProduct.quantity}",
                                                                        ),
                                                                    decoration: const InputDecoration(
                                                                      border: InputBorder.none,
                                                                      isDense: true,
                                                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                                    ),
                                                                    textAlign: TextAlign.center,
                                                                    keyboardType: TextInputType.number,
                                                                    inputFormatters: [
                                                                      LengthLimitingTextInputFormatter(5), // Limit to 5 digits
                                                                    ],
                                                                    onChanged: (value) {
                                                                    if (value.isNotEmpty) {
                                                                      //   int stockQty = int.parse(billingProvider.selectedProduct!.stockQty.toString());
                                                                      //   int enteredQty = int.tryParse(value) ?? billProduct.quantity;
                                                                      //   if (enteredQty > stockQty) {
                                                                      //     Toasts.showToastBar(
                                                                      //       context: context,
                                                                      //       text: "Entered quantity is more than the available stock ($stockQty).",
                                                                      //       color: Colors.red,
                                                                      //     );
                                                                      //   }else{
                                                                          billingProvider.updateBillingItem(
                                                                            index,
                                                                            isLoose: '0',
                                                                            quantity: int.tryParse(value) ?? billProduct.quantity,
                                                                          );
                                                                       // }
                                                                      } else {

                                                                        // billingProvider.updateBillingItem(
                                                                        //   index,
                                                                        //   isLoose: '0',
                                                                        //   quantity: 1,
                                                                        // );
                                                                      }
                                                                    },
                                                                  ),
                                                                ):SizedBox(
                                                            height: 40,
                                                            child: TextFormField(
                                                              controller: TextEditingController(
                                                                text: "${billProduct.variation / 1000}",
                                                              ),
                                                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                              onChanged: (value) {
                                                                // optional: validation / preview only
                                                              },
                                                              textAlign: TextAlign.center,
                                                              decoration: const InputDecoration(
                                                                border: InputBorder.none, // Removes underline
                                                                isDense: true, // Reduces padding
                                                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                              ),
                                                              onFieldSubmitted: (value) {
                                                                final parsed = double.tryParse(value);
                                                                if (parsed != null && parsed > 0) {
                                                                  billingProvider.updateBillingItem(
                                                                    index,
                                                                    isLoose: '1',
                                                                    variation: parsed * 1000, // store in grams
                                                                  );
                                                                } else {
                                                                  Toasts.showToastBar(
                                                                    context: context,
                                                                    text: 'Please enter valid weight',
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                            // child: TextFormField(
                                                            //   controller: TextEditingController(
                                                            //     text: "${billProduct.variation / 1000}",
                                                            //   ),
                                                            //   onChanged: (value) {
                                                            //     billingProvider.updateBillingItem(
                                                            //       index,
                                                            //       isLoose: '1',
                                                            //       variation: double.tryParse(value) ?? billProduct.variation * 1000,
                                                            //     );
                                                            //   },
                                                            // ),
                                                          )
                                                            //   : Align(
                                                            // alignment: Alignment.center,
                                                            //     child: Text(
                                                            //         "${billProduct.quantity}"),
                                                            //   ),
                                                        ),
                                                        DataCell(
                                                          Align(
                                                            alignment: Alignment.center,
                                                            child: Text("${billProduct.sgst}%"),
                                                          ),
                                                        ),

                                                        // DataCell(
                                                        //      Align(
                                                        //        alignment: Alignment.center,
                                                        //        child: Text(
                                                        //            "${billProduct.sgst}%"),
                                                        //      ),
                                                        // ),
                                                        DataCell(Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            TextFormat.formattedAmount(
                                                                billProduct
                                                                    .mrpPerProduct()),
                                                            textAlign: TextAlign.end,
                                                          ),
                                                        )),
                                                        DataCell(Align(
                                                          alignment: Alignment.centerRight,
                                                          child: Text(TextFormat
                                                              .formattedAmount(
                                                                  billProduct
                                                                      .calculateOutPrice())),
                                                        )),
                                                        DataCell(Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(billProduct
                                                              .calculateDiscount()
                                                              .toStringAsFixed(
                                                                  2)),
                                                        )),
                                                        DataCell(Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                              TextFormat
                                                                  .formattedAmount(
                                                            billProduct
                                                                .calculateSubtotal(),
                                                          )),
                                                        )),
                                                        DataCell(
                                                          Center(
                                                            child:
                                                            IconButton(
                                                                  tooltip: 'Delete ${billProduct.product.isLoose == '1'
                                                                      ? "${billProduct.product.pTitle} ${billProduct.variation/1000}kg"
                                                                      : "${billProduct.product.pTitle} ${billProduct.variationUnit}"}',
                                                              icon: SvgPicture.asset("assets/images/delete.svg",width: 20,height: 20,),
                                                              // onPressed: () =>
                                                              //     billingProvider.removeBillingItem(
                                                              //         index:
                                                              //             index),
                                                              onPressed: () {
                                                                String itemName = billProduct.product.isLoose == '1'
                                                                    ? "${billProduct.product.pTitle} ${billProduct.variation / 1000}kg"
                                                                    : "${billProduct.product.pTitle} ${billProduct.variationUnit}";

                                                                showDialog(
                                                                  context: context,
                                                                  builder: (BuildContext context) {
                                                                    return AlertDialog(
                                                                      backgroundColor: Colors.white,
                                                                      contentPadding:
                                                                      const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(8),
                                                                      ),
                                                                      content: Column(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            "Are you sure you want to delete $itemName?",
                                                                            style: const TextStyle(
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: AppColors.primary,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(height: 20),
                                                                          Row(
                                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                                            children: [
                                                                              ElevatedButton(
                                                                                onPressed: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: Colors.grey.shade200,
                                                                                  side: BorderSide(color: AppColors.secondary),
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                  ),
                                                                                ),
                                                                                child: const Text(
                                                                                  "No",
                                                                                  style: TextStyle(
                                                                                    color: AppColors.primary,
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(width: 10),
                                                                              ElevatedButton(
                                                                                onPressed: () {
                                                                                  billingProvider.removeBillingItem(index: index);
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: AppColors.primary,
                                                                                  side: BorderSide(color: AppColors.secondary),
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                  ),
                                                                                ),
                                                                                child: const Text(
                                                                                  "Yes",
                                                                                  style: TextStyle(
                                                                                    color: Colors.white,
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                                ),
                                              ),
                                            ),
                                      ),
                                    ),
                                screenHeight>=700?0.height:billingProvider.isLoading
                                    ? 0.height
                                    : SizedBox(
                                  height: 180,
                                  width: screenWidth,
                                  child: Column(
                                    children: [
                                      Container(
                                          color: Colors.white,
                                          padding: const EdgeInsets.only(
                                              top: 20, left: 12, right: 12, bottom: 0),
                                          height: 90,
                                          width: screenWidth,
                                          child: DataTable(
                                            headingRowHeight: 40, // Height for header
                                            dataRowHeight: 40, // Height for data
                                            headingTextStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            border: const TableBorder(
                                              // left: BorderSide(width: 1, color: Color(0xff9E9E9E)),
                                              // right: BorderSide(width: 1, color: Color(0xff9E9E9E)),
                                              verticalInside: BorderSide(
                                                  width: 1, color: Color(0xff9E9E9E)),
                                              top: BorderSide.none,
                                              bottom: BorderSide.none,
                                              horizontalInside: BorderSide.none,
                                            ),
                                            headingRowColor:
                                            MaterialStateProperty.resolveWith(
                                                  (states) => Color(0xff0078D7),
                                            ),
                                            columns: const [
                                              DataColumn(
                                                label: Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      'Items',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      'Qty',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      'Subtotal',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      'Discount',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      'SGST',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      'CGST',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      'GST',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      'Grand Total',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],

                                            rows: [
                                              DataRow(
                                                cells: [
                                                  DataCell(Center(
                                                    child: Text(billingProvider
                                                        .calculatedTotalProducts()
                                                        .toString()),
                                                  )),
                                                  DataCell(Center(
                                                    child: Text(billingProvider
                                                        .calculatedTotalQuantity()
                                                        .toString()),
                                                  )),
                                                  DataCell(
                                                      Center(
                                                        child: MyText(
                                                            text: billingProvider
                                                                .calculatedMrpSubtotal()
                                                                .toString()),
                                                      )),
                                                  DataCell(Center(
                                                    child: Text(billingProvider
                                                        .calculateTotalDiscount()
                                                        .toString()),
                                                  )),
                                                  DataCell(Center(child: Text(
                                                      '${billingProvider.calculateTotalSGST()}%'))),
                                                  DataCell(Center(child: Text('${billingProvider.calculateTotalCGST()}%'))),
                                                  DataCell(Center(child: Text('${billingProvider.calculateTotalGST()}%'))),
                                                  DataCell(Center(
                                                    child: Text(TextFormat
                                                        .formattedAmount(billingProvider
                                                        .calculatedGrandTotal())),
                                                  )),
                                                ],
                                              ),
                                            ],
                                          )),
                                      Container(
                                        height: 90,
                                        width: screenWidth,
                                        padding: const EdgeInsets.only(
                                            top: 10, left: 12, right: 12, bottom: 0),
                                        decoration: BoxDecoration(
                                          border: const Border(
                                            left: BorderSide(
                                                color: Colors.black,
                                                width: 1), // Outer left border
                                            right: BorderSide(
                                                color: Colors.black,
                                                width: 1), // Outer right border
                                          ),
                                        ),
                                        child: DataTable(
                                          headingRowHeight: 40,
                                          dataRowHeight: 40,
                                          dividerThickness: 0, // No horizontal dividers
                                          headingTextStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          border: const TableBorder(
                                            verticalInside: BorderSide(
                                                color: Color(0xff9E9E9E),
                                                width: 1), // Column dividers
                                            // left: BorderSide(color: Colors.black, width: 1),   // Left border
                                            // right: BorderSide(color: Colors.black, width: 1),  // Right border
                                          ),
                                          headingRowColor:
                                          MaterialStateProperty.resolveWith(
                                                (states) => Color(0xffD9EEFF),
                                          ),
                                          columns: const [
                                            DataColumn(
                                              label: Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Loading Charge',
                                                    style: TextStyle(
                                                        color: Color(0xff0078D7)),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Cutting Charge',
                                                    style: TextStyle(
                                                        color: Color(0xff0078D7)),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Freight Charge',
                                                    style: TextStyle(
                                                        color: Color(0xff0078D7)),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],

                                          rows:  [
                                            DataRow(
                                              cells: [
                                                DataCell(
                                                    Center(
                                                      child: TextField(
                                                        controller: billingProvider.loadingCharge,
                                                        focusNode: billingProvider.loadingChargeFocusNode,
                                                        onSubmitted: (_){
                                                          billingProvider.updateFooterButtons();
                                                          billingProvider.cuttingChargeFocusNode.requestFocus();
                                                        },
                                                        onChanged: (value){
                                                          billingProvider.updateFooterButtons();
                                                        },
                                                        textAlign: TextAlign.center,
                                                        style: GoogleFonts.lato(fontSize: 15),
                                                        decoration: const InputDecoration(border: InputBorder.none,
                                                            contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 5)
                                                        ),
                                                      ),)),
                                                DataCell(
                                                    Center(child: TextField(
                                                      controller: billingProvider.cuttingCharge,
                                                      focusNode: billingProvider.cuttingChargeFocusNode,
                                                      onChanged: (value){
                                                        billingProvider.updateFooterButtons();
                                                      },
                                                      onSubmitted: (_){
                                                        billingProvider.updateFooterButtons();
                                                        billingProvider.freightChargeFocusNode.requestFocus();
                                                      },
                                                      textAlign: TextAlign.center,
                                                      style: GoogleFonts.lato(fontSize: 15),
                                                      decoration: const InputDecoration(border: InputBorder.none,
                                                          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 5)
                                                      ),
                                                    ),)),
                                                DataCell(Center(child: TextField(
                                                  controller: billingProvider.freightCharge,
                                                  focusNode: billingProvider.freightChargeFocusNode,
                                                  onChanged: (value){
                                                    billingProvider.updateFooterButtons();
                                                  },
                                                  onSubmitted: (_){
                                                    billingProvider.updateFooterButtons();
                                                  },
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.lato(fontSize: 15),
                                                  decoration: const InputDecoration(border: InputBorder.none,
                                                      contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 5)
                                                  ),
                                                ),)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ),
                  ),
                  bottomNavigationBar: screenHeight<=700?0.height:billingProvider.isLoading
                      ? 0.height
                      : SizedBox(
                          height: 180,
                          width: screenWidth,
                          child: Column(
                            children: [
                              Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.only(
                                      top: 20, left: 12, right: 12, bottom: 0),
                                  height: 90,
                                  width: screenWidth,
                                  child: DataTable(
                                    headingRowHeight: 40, // Height for header
                                    dataRowHeight: 40, // Height for data
                                    headingTextStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    border: const TableBorder(
                                      // left: BorderSide(width: 1, color: Color(0xff9E9E9E)),
                                      // right: BorderSide(width: 1, color: Color(0xff9E9E9E)),
                                      verticalInside: BorderSide(
                                          width: 1, color: Color(0xff9E9E9E)),
                                      top: BorderSide.none,
                                      bottom: BorderSide.none,
                                      horizontalInside: BorderSide.none,
                                    ),
                                    headingRowColor:
                                        MaterialStateProperty.resolveWith(
                                      (states) => Color(0xff0078D7),
                                    ),
                                    columns: const [
                                      DataColumn(
                                        label: Expanded(
                                          child: Center(
                                            child: Text(
                                              'Items',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Expanded(
                                          child: Center(
                                            child: Text(
                                              'Qty',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Expanded(
                                          child: Center(
                                            child: Text(
                                              'Subtotal',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Expanded(
                                          child: Center(
                                            child: Text(
                                              'Discount',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Expanded(
                                          child: Center(
                                            child: Text(
                                              'SGST',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Expanded(
                                          child: Center(
                                            child: Text(
                                              'CGST',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Expanded(
                                          child: Center(
                                            child: Text(
                                              'GST',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Expanded(
                                          child: Center(
                                            child: Text(
                                              'Grand Total',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],

                                    rows: [
                                      DataRow(
                                        cells: [
                                          DataCell(Center(
                                            child: Text(billingProvider
                                                .calculatedTotalProducts()
                                                .toString()),
                                          )),
                                          DataCell(Center(
                                            child: Text(billingProvider
                                                .calculatedTotalQuantity()
                                                .toString()),
                                          )),
                                          DataCell(
                                              Center(
                                            child: MyText(
                                                text: billingProvider
                                                .calculatedMrpSubtotal()
                                                .toString()),
                                          )),
                                          DataCell(Center(
                                            child: Text(billingProvider
                                                .calculateTotalDiscount()
                                                .toString()),
                                          )),
                                          DataCell(Center(child: Text(
                                              '${billingProvider.calculateTotalSGST()}%'))),
                                          DataCell(Center(child: Text('${billingProvider.calculateTotalCGST()}%'))),
                                          DataCell(Center(child: Text('${billingProvider.calculateTotalGST()}%'))),
                                          DataCell(Center(
                                            child: Text(TextFormat
                                                .formattedAmount(billingProvider
                                                    .calculatedGrandTotal())),
                                          )),
                                        ],
                                      ),
                                    ],
                                  )),
                              Container(
                                height: 90,
                                width: screenWidth,
                                padding: const EdgeInsets.only(
                                    top: 10, left: 12, right: 12, bottom: 0),
                                decoration: BoxDecoration(
                                  border: const Border(
                                    left: BorderSide(
                                        color: Colors.black,
                                        width: 1), // Outer left border
                                    right: BorderSide(
                                        color: Colors.black,
                                        width: 1), // Outer right border
                                  ),
                                ),
                                child: DataTable(
                                  headingRowHeight: 40,
                                  dataRowHeight: 40,
                                  dividerThickness: 0, // No horizontal dividers
                                  headingTextStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  border: const TableBorder(
                                    verticalInside: BorderSide(
                                        color: Color(0xff9E9E9E),
                                        width: 1), // Column dividers
                                    // left: BorderSide(color: Colors.black, width: 1),   // Left border
                                    // right: BorderSide(color: Colors.black, width: 1),  // Right border
                                  ),
                                  headingRowColor:
                                      MaterialStateProperty.resolveWith(
                                    (states) => Color(0xffD9EEFF),
                                  ),
                                  columns: const [
                                    DataColumn(
                                      label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Loading Charge',
                                            style: TextStyle(
                                                color: Color(0xff0078D7)),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Cutting Charge',
                                            style: TextStyle(
                                                color: Color(0xff0078D7)),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Freight Charge',
                                            style: TextStyle(
                                                color: Color(0xff0078D7)),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],

                                  rows:  [
                                    DataRow(
                                      cells: [
                                        DataCell(
                                            Center(
                                              child: TextField(
                                              controller: billingProvider.loadingCharge,
                                              focusNode: billingProvider.loadingChargeFocusNode,
                                              onSubmitted: (_){
                                                billingProvider.updateFooterButtons();
                                                billingProvider.cuttingChargeFocusNode.requestFocus();
                                              },
                                              onChanged: (value){
                                                billingProvider.updateFooterButtons();
                                              },
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.lato(fontSize: 15),
                                              decoration: const InputDecoration(border: InputBorder.none,
                                                  contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 5)
                                              ),
                                            ),)),
                                        DataCell(
                                            Center(child: TextField(
                                          controller: billingProvider.cuttingCharge,
                                          focusNode: billingProvider.cuttingChargeFocusNode,
                                          onChanged: (value){
                                            billingProvider.updateFooterButtons();
                                          },
                                          onSubmitted: (_){
                                            billingProvider.updateFooterButtons();
                                            billingProvider.freightChargeFocusNode.requestFocus();
                                          },
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.lato(fontSize: 15),
                                          decoration: const InputDecoration(border: InputBorder.none,
                                              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 5)
                                          ),
                                        ),)),
                                        DataCell(Center(child: TextField(
                                          controller: billingProvider.freightCharge,
                                          focusNode: billingProvider.freightChargeFocusNode,
                                          onChanged: (value){
                                            billingProvider.updateFooterButtons();
                                          },
                                          onSubmitted: (_){
                                            billingProvider.updateFooterButtons();
                                          },
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.lato(fontSize: 15),
                                          decoration: const InputDecoration(border: InputBorder.none,
                                              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 5)
                                          ),
                                        ),)),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ));
    });
  }

  Future<void> showPaymentBalanceDialog(
      BuildContext context, {
        required void Function() onPressPrint,
      }) async {
    final billingProvider =
    Provider.of<BillingProvider>(context, listen: false);
    billingProvider.paymentReceived.addListener(() {
      billingProvider.calculatePaymentBalance();
    });
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Consumer<BillingProvider>(
                builder: (context, billingProvider, _) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    titlePadding: EdgeInsets.zero,
                    title: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          // bottomLeft and bottomRight will be zero by default, so no radius
                        ),

                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          MyText(
                            text: 'Print Bill',
                            fontSize: TextFormat.responsiveFontSize(context, 20),
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.center,
                            color: Colors.white,
                          ),400.width,
                          IconButton(onPressed: (){
                            Navigator.of(context).pop();
                          }, icon: Icon(Icons.clear,color: Colors.white,))
                        ],
                      ),
                    ),
                    // icon: InkWell(onTap: (){
                    //   Navigator.of(context).pop();
                    // }, child: const Icon(Icons.clear,color: Colors.red,)),
                    // iconPadding: const EdgeInsets.fromLTRB(400, 0, 1, 1),
                    content: Container(
                      color: Colors.white,
                      alignment: Alignment.centerLeft,
                      height: MediaQuery.of(context).size.height * 0.47,
                      child: SingleChildScrollView(
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display Total Amount
                            Align(
                              alignment: Alignment.center,
                              child: RichText(
                                text: TextSpan(
                                  text: 'Total Amount : ',
                                  style: GoogleFonts.lato(
                                    fontSize:
                                    TextFormat.responsiveFontSize(context, 20),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: TextFormat.formattedAmount(
                                          billingProvider.calculatedGrandTotal()),
                                      style: GoogleFonts.lato(
                                        fontSize:
                                        TextFormat.responsiveFontSize(context, 20),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            20.height,
                            // Payment Received Input
                            Text("Payment Received",style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),10.height,
                            MyTextField(
                              height: null,
                              width: 500,
                              borderRadius:2,
                              labelText: "Enter amount",
                              enabledBorderColor: Color(0xff9E9E9E),
                              autofocus: true,
                              isOptional: true,
                              controller: billingProvider.paymentReceived,
                              inputFormatters: InputFormatters.mobileNumberInput,
                              onEditingComplete: () {
                                billingProvider.keyboardListenerFocusNode
                                    .requestFocus();
                              },
                            ),
                            30.height,
                            // Display Balance
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: billingProvider.paymentBalance,
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
                                            : "₹ ${value.text.isEmpty ? "0" : value.text}",
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
                            ),26.height,
                            const MyText(
                              text: 'Select Payment Method',
                              fontSize: 13,
                            ),8.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: billingProvider.billMethods.map((method) {
                                final bool isSelected = billingProvider.selectBillMethod == method;
                                return Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => billingProvider.changeBillMethod(method),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.blue : Colors.white,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isSelected ? Colors.blue : Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          method,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    15.width,
                                  ],
                                );

                              }).toList(),
                            ),10.height,
                            const MyText(
                              text: 'Select Bill Type',
                              fontSize: 13,
                            ),8.height,
                            Row(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min, // prevents row from taking full width
                                  children: List.generate(billingProvider.billTypes.length, (index) {
                                    final type = billingProvider.billTypes[index];
                                    final bool isSelected = billingProvider.selectedType == type;
                                    return GestureDetector(
                                      onTap: () => billingProvider.selectType(type),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18, // smaller left/right padding
                                          vertical: 8,    // smaller top/bottom padding
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.blue : Colors.white,
                                          border: Border.all(color: Colors.grey, width: 1),
                                          borderRadius: BorderRadius.horizontal(
                                            left: index == 0 ? const Radius.circular(6) : Radius.zero,
                                            right: index == billingProvider.billTypes.length - 1
                                                ? const Radius.circular(6)
                                                : Radius.zero,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          type,
                                          style: TextStyle(
                                            fontSize: 13, // smaller text
                                            color: isSelected ? Colors.white : Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),10.width,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(billingProvider.gst.length, (index) {
                                    final type = billingProvider.gst[index];
                                    final bool isSelected = billingProvider.selectedGst == type;
                                    return GestureDetector(
                                      onTap: () => billingProvider.selectGst(type),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.blue : Colors.white,
                                          border: Border.all(color: Colors.grey, width: 1),
                                          borderRadius: BorderRadius.horizontal(
                                            left: index == 0 ? const Radius.circular(6) : Radius.zero,
                                            right: index == billingProvider.gst.length - 1
                                                ? const Radius.circular(6)
                                                : Radius.zero,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          type,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isSelected ? Colors.white : Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),8.height,
                            const MyText(
                              text: 'Select Paper Size',
                              fontSize: 13,
                            ),8.height,

                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: billingProvider.sizes.map((size) {
                                final bool isSelected = billingProvider.selectedSize == size;
                                return Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => billingProvider.selectSize(size),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), // smaller buttons
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.blue : Colors.white,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isSelected ? Colors.blue : Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          size,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10), // spacing between buttons
                                  ],
                                );
                              }).toList(),
                            )

                          ],
                        ),
                      ),
                    ),
                    actions: [
                      Buttons.loginButton(
                        context: context,
                        loadingButtonController: billingProvider.printAfterChangeButtonController,
                        toolTip: 'Print Bill',
                        height: 45,
                        onPressed: onPressPrint,
                        text: 'Print',
                      ),
                    ],
                  );
                });
          },
        );
      },
    );
  }

  /// Table Header Widget :
  Widget _buildHeaderCell(String text) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: MyText(
        text: text,
        fontStyle: FontStyle.normal,
        isBold: true,
        textAlign: TextAlign.center,
        color: AppColors.white,
        fontSize: 14,
      ),
    );
  }

  /// Billing Products Widget :
  Widget _buildCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: MyText(
        text: text == "null" ? "" : text,
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Editable Cell :
  Widget _buildEditableCell(
      {required int index,
      required TextEditingController controller,
      required void Function(String) onChanged,
      required List<TextInputFormatter> inputFormatters,
      required void Function()? onEditingComplete}) {
    final bool isEven = index % 2 == 0;

    return MyTextField(
      controller: controller,
      isOptional: true,
      hintText: "",
      labelText: "",
      borderRadius: 5,
      inputFormatters: inputFormatters,
      textAlign: TextAlign.center,
      enabledBorderColor: isEven ? Color(0xffFFFFFF) : Color(0xffD9EEFF),
      focusedBorderColor: isEven ? Color(0xffFFFFFF) : Color(0xffD9EEFF),
      onChanged: onChanged,
      fillColor: isEven ? Color(0xffF5F5F5) : Color(0xffC5E5FF),
      onEditingComplete: onEditingComplete,
    );
  }
}

DataColumn _buildHeader(String text, double width) {
  return DataColumn(
    label: SizedBox(
      width: width,
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

DataCell _buildCell(String text, double width, Alignment alignment) {
  return DataCell(
    SizedBox(
      width: width,
      child: Align(
        alignment: alignment,
        child: Text(text),
      ),
    ),
  );
}

/// Product Dropdown (Deprecated) :
// MyDropdownMenu<ProductData>(
//   enableSearch: true,
//   enableFilter: true,
//   menuHeight: 300,
//   controller: TextEditingController(
//     text: billProduct.product.isLoose == '1'
//         ? "${billProduct.productTitle} ${billProduct.variation}g"
//         : "${billProduct.productTitle} ${billProduct.variationUnit}",
//   ),
//   dropdownMenuEntries: billingProvider.productsList.map((product) {
//     return MyDropdownMenuEntry<ProductData>(
//       value: product,
//       label: product.isLoose == '1'
//           ? "${product.pTitle}"
//           : "${product.pTitle} ${product.pVariation}${product.unit}",
//       trailingIcon: Row(
//         children: [
//           MyText(
//             text : product.isLoose == '1'
//                 ? "₹${product.outPrice} (₹${product.pricePerG}/g)"
//                 : "₹${product.outPrice}",
//           ),
//         ],
//       ),
//     );
//   }).toList(),
//   // hintText: "Search product...",
//   onSelected: (selectedProduct) {
//     if (selectedProduct != null) {
//       billingProvider.updateBillingItem(
//         index,
//         isLoose: selectedProduct.isLoose.toString(),
//         variation: selectedProduct.isLoose == '1' ? 1 : 0, // Reset variation for loose
//         quantity: selectedProduct.isLoose == '0' ? 1 : 0,  // Reset quantity for non-loose
//       );
//       billProduct.product = selectedProduct; // Update product
//     }
//   },
// ),
