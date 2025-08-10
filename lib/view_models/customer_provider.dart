import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fullcomm_billing/data/local_data.dart';
import 'package:fullcomm_billing/repo/customer_repo.dart';
import 'package:fullcomm_billing/res/colors.dart';
import 'package:fullcomm_billing/res/components/k_dropdown.dart';
import 'package:fullcomm_billing/utils/sized_box.dart';
import 'package:fullcomm_billing/utils/toast_messages.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../models/customers_response.dart';
import '../res/components/buttons.dart';
import '../res/components/k_text.dart';
import '../res/components/k_text_field.dart';
import '../utils/input_formatters.dart';
import '../utils/text_formats.dart';

class CustomersProvider with ChangeNotifier {
  final CustomersRepository _customerRepo = CustomersRepository();

  final List<String> _states = [
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
    "Andaman and Nicobar Islands",
    "Chandigarh",
    "Dadra and Nagar Haveli and Daman and Diu",
    "Delhi",
    "Jammu and Kashmir",
    "Ladakh",
    "Lakshadweep",
    "Puducherry",
    ""
  ];

  String? _selectedState;

  List<String> get states => _states;

  String? get selectedState => _selectedState;

  void changeState(String state) {
    _selectedState = state;
    notifyListeners();
  }
  // Add Customer Fields :
  TextEditingController customerName = TextEditingController();
  TextEditingController customerMobile = TextEditingController();
  TextEditingController customerStreet = TextEditingController();
  TextEditingController customerArea = TextEditingController();
  TextEditingController customerCity = TextEditingController();
  TextEditingController customerPincode = TextEditingController();
  TextEditingController customerCountry = TextEditingController();
  TextEditingController customerState =
      TextEditingController(text: 'TamilNadu');

  // Loading Button Controller:
  RoundedLoadingButtonController loadingButtonController =
      RoundedLoadingButtonController();

  /// ----------- Add Customer ----------------------
  Future<void> addCustomer({
    required BuildContext context,
    required String name,
    required String mobile,
    required String addressLine1,
    required String area,
    required String pincode,
    required String city,
    required String state,
  }) async {
    try {
      final response = await _customerRepo.addCustomer(
          name: name,
          mobile: mobile,
          addressLine1: addressLine1,
          area: area,
          pincode: pincode,
          city: city,
          state: state);

      if (response.responseCode == 200) {
        // Store Customer Details:
        localData.customerName = name;
        localData.customerMobile = mobile;
        localData.customerAddress =
            "$addressLine1,$area,$city,$pincode".replaceAll(',,', ','); // Fix

        // Clear Fields:
        customerName.clear();
        customerMobile.clear();
        customerStreet.clear();
        customerArea.clear();
        customerCity.clear();
        customerPincode.clear();

        if (!context.mounted) return;
        await getAllCustomers(context);

        if (!context.mounted) return;
        Navigator.pop(context);

        Toasts.showToastBar(context: context, text: 'Customer is added.',color: AppColors.successMessage);
      } else if (response.responseCode == 409) {
        // Existing Customer :
        if (!context.mounted) return;
        Toasts.showToastBar(
            context: context,
            text: 'Customer already exists.',
            color: AppColors.errorMessage);
      } else {
        // Invalid Details :
        if (!context.mounted) return;
        Toasts.showToastBar(
            context: context,
            text: 'Enter Valid Details',
            color: AppColors.errorMessage);
        log("Add Address Error: ${response.message}");
      }
    } catch (e) {
      Toasts.showToastBar(
          context: context,
          text: 'Something went wrong.',
          color: AppColors.errorMessage);
      throw Exception("addCustomer Error : $e");
    } finally {
      loadingButtonController.reset();
      notifyListeners();
    }
  }

  /// --------- Add Customer DialogBox --------------
  void addCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: SingleChildScrollView(
              // Ensures content fits dynamically
              child: Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min, // Adjusts size to fit content
                  children: [
                    MyText(
                      text: 'Add Customer',
                      fontSize: TextFormat.responsiveFontSize(context, 20),
                      fontWeight: FontWeight.bold,
                    ),
                    6.height,
                    MyTextField(
                      labelText: "Customer's Name",
                      controller: customerName,
                      isOptional: false,
                      borderRadius: 8,
                     height: 60,
                    ),
                    10.height,
                    MyTextField(
                      labelText: "Mobile Number",
                      isOptional: false,
                      controller: customerMobile,
                      inputFormatters: InputFormatters.mobileNumberInput,
                      borderRadius: 8,
                      height: 60,
                    ),
                    10.height,
                    MyTextField(
                      labelText: "Door No, Street",
                      isOptional: true,
                      controller: customerStreet,
                      textCapitalization: TextCapitalization.sentences,
                      borderRadius: 8,
                      height: 60,
                    ),
                    6.height,
                    MyTextField(
                      labelText: "Area",
                      isOptional: true,
                      controller: customerArea,
                      textCapitalization: TextCapitalization.sentences,
                      borderRadius: 8,
                      height: 60,
                    ),
                    10.height,
                    MyTextField(
                      labelText: "City",
                      isOptional: false,
                      controller: customerCity,
                      textCapitalization: TextCapitalization.sentences,
                      borderRadius: 8,
                      height: 60,
                    ),
                    10.height,
                    MyTextField(
                      labelText: "Pincode",
                      isOptional: false,
                      controller: customerPincode,
                      inputFormatters: InputFormatters.pinCodeInput,
                      borderRadius: 8,
                      height: 60,
                    ),
                    10.height,

                    MyDropDown(
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: MediaQuery.of(context).size.width * 0.25,
                        labelText: "State",
                      value: selectedState,
                      borderRadius: 8,
                      items: states.map((String state) {
                        return DropdownMenuItem(
                          value: state,
                          child: Text(state),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          customerState.text = value;
                          changeState(customerState.text.trim());
                        }
                      },
                    ),
                    // MyTextField(
                    //   labelText: "State",
                    //   controller: customerState,
                    //   isOptional: true,
                    //   textCapitalization: TextCapitalization.sentences,
                    // ),
                    10.height,
                MyTextField(
                labelText: "Country",
                isOptional: false,
                controller: customerCountry,
                borderRadius: 8,
                height: 60,
              ), 10.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 300,
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                              )
                            ),
                              onPressed: (){
                               setState((){
                                 customerName.clear();
                                   customerMobile.clear();
                               customerStreet.clear();
                               customerArea.clear();
                               customerCity.clear();
                               customerPincode.clear();
                               changeState("");
                               });
                              },
                              child: MyText(text: "Clear",
                                color: AppColors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        Buttons.loginButton(
                          context: context,
                          width: 300,
                          height: 50,
                          loadingButtonController: loadingButtonController,
                          onPressed: () {
                            if (customerName.text.isEmpty) {
                              loadingButtonController.reset();
                              Toasts.showToastBar(
                                  context: context,
                                  text: "Please enter customer name",
                                  color: Colors.red);
                            } else if (customerMobile.text.isEmpty) {
                              loadingButtonController.reset();
                              Toasts.showToastBar(
                                  context: context,
                                  text: "Please enter customer mobile",
                                  color: Colors.red);
                            }  else if (customerMobile.text.length!=10) {
                              loadingButtonController.reset();
                              Toasts.showToastBar(
                                  context: context,
                                  text: "Please enter 10 digits mobile number",
                                  color: Colors.red);
                            }else if (customerCity.text.isEmpty) {
                              loadingButtonController.reset();
                              Toasts.showToastBar(
                                  context: context,
                                  text: "Please enter customer city",
                                  color: Colors.red);
                            } else if (customerPincode.text.isEmpty) {
                              loadingButtonController.reset();
                              Toasts.showToastBar(
                                  context: context,
                                  text: "Please enter customer pincode",
                                  color: Colors.red);
                            } else if (customerPincode.text.length!=6) {
                              loadingButtonController.reset();
                              Toasts.showToastBar(
                                  context: context,
                                  text: "Please enter 6 digits pincode",
                                  color: Colors.red);
                            } else {
                              addCustomer(
                                context: context,
                                name: customerName.text,
                                mobile: customerMobile.text,
                                addressLine1: customerStreet.text,
                                area: customerArea.text,
                                pincode: customerPincode.text,
                                city: customerCity.text,
                                state: customerState.text,
                              );
                            }
                          },
                          text: 'Submit',
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  /// -------- Customer Selection -------------------
  String _selectedCustomerId = '';
  String _selectedCustomerName = '';
  String _selectedCustomerMobile = '';

  String get selectedCustomerId => _selectedCustomerId;
  String get selectedCustomerName => _selectedCustomerName;
  String get selectedCustomerMobile => _selectedCustomerMobile;

  /// -------- Fetch all Customers -----------------

  List<CustomerData> _allCustomers = [];
  List<CustomerData> get allCustomersList => _allCustomers;

  // Fetch all Customers Api :
  Future<void> getAllCustomers(context) async {
    try {
      final response = await _customerRepo.getCustomers();

      if (response.responseCode == '200') {
        _allCustomers = response.customersList ?? [];
      } else {
        _allCustomers = [];
      }
    } catch (e) {
      Toasts.showToastBar(
          context: context, text: 'Failed to receive Customers List');
      throw Exception(e);
    } finally {
      notifyListeners();
    }
  }

  // Select Customer :
  TextEditingController customerAddressController = TextEditingController();

  /// Set Customer Details :
  void setCustomerDetails(
      {required String customerId,
      required String customerName,
      required String customerMobile,
      required String customerAddress}) {
    _selectedCustomerId = customerId;
    _selectedCustomerName = customerName;
    _selectedCustomerMobile = customerMobile;
    customerAddressController.text = customerAddress;
    notifyListeners();
  }

  /// Reset Customer Details (Emptying)
  void resetCustomerDetails() {
    _selectedCustomerId = '';
    _selectedCustomerName = '';
    _selectedCustomerMobile = '';
    customerAddressController.clear();
    notifyListeners();
  }

  void showInputDialog(
      {BuildContext? context,
        TextEditingController? controller,
        FocusNode? focus,
        double? width,
        double? height,
        VoidCallback? onChanged,
        void Function(String)? onSubmitted
      }) {
    showDialog(
      context: context!,
      builder: (context) {
        return AlertDialog(
          title: const MyText(text:'Product ',fontSize: 15,),
          content: SizedBox(
            height: 100,
            child: MyTextField(
              hintText: "Product Name",
              autofocus: false,
              isOptional: true,
              focusNode:focus,
              labelText: "Product Name",
              controller: controller!,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: onSubmitted,
            ),
          ),
          actions: [
            ElevatedButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: MyText(text: "Cancel",color: AppColors.black,)),
            ElevatedButton(
                onPressed: onChanged,
                child: MyText(text: "Ok",color: AppColors.primary,))
          ],
        );
      },
    );
  }

  void addDeliveryAddressDialog(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return Consumer<CustomersProvider>(
                  builder: (context,customersProvider,child){
                    return AlertDialog(
                      title: MyText(
                        text: 'Add Delivery Address',
                        fontSize: TextFormat.responsiveFontSize(context, 20),
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                      content: SingleChildScrollView(
                        child: Container(
                          color: Colors.red,
                          alignment: Alignment.center,
                          child:Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  MyText(text: "Delivery Person Name"),
                                  100.width,
                                  MyText(text: "Delivery Person Mobile No"),
                                ],
                              ),
                              Row(
                                children: [
                                  MyTextField(
                                    hintText: "Delivery Person Name",
                                    autofocus: false,
                                    width: 350,
                                    // controller: customersProvider.deliveryName,
                                    textCapitalization: TextCapitalization.words,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next, isOptional: true,
                                    labelText: '',
                                    focusedBorderColor: Color(0xff9e9e9e),
                                    enabledBorderColor: Color(0xff9e9e9e),
                                    fillColor: Color(0xffffffff),
                                    borderRadius: 5, controller: TextEditingController(),
                                  ),
                                  20.width,
                                  MyTextField(
                                    hintText: "Delivery Person Mobile No",
                                    autofocus: false,
                                    width: 350,
                                    controller: TextEditingController(),
                                    textCapitalization: TextCapitalization.words,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: InputFormatters.mobileNumberInput,
                                    textInputAction: TextInputAction.next,
                                    labelText: '',
                                    isOptional: false,
                                    focusedBorderColor: Color(0xff9e9e9e),
                                    enabledBorderColor: Color(0xff9e9e9e),
                                    fillColor: Color(0xffffffff),
                                    borderRadius: 5,
                                  ),
                                ],
                              ),
                              6.height,
                              Row(
                                children: [
                                  MyText(text: "Delivery Person Name"),
                                  100.width,
                                  MyText(text: "Delivery Person Mobile No"),
                                ],
                              ),
                              Row(
                                children: [
                                  MyTextField(
                                    hintText: "Vehicle Number",
                                    autofocus: false,
                                    width: 350,
                                    labelText: '',
                                    isOptional: false,
                                    focusedBorderColor: Color(0xff9e9e9e),
                                    enabledBorderColor: Color(0xff9e9e9e),
                                    fillColor: Color(0xffffffff),
                                    borderRadius: 5,
                                    controller: TextEditingController(),
                                    textCapitalization: TextCapitalization.words,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  20.width,
                                  MyTextField(
                                    hintText: "Door No / Street",
                                    autofocus: false,
                                    width: 350,
                                    labelText: '',
                                    isOptional: false,
                                    focusedBorderColor: Color(0xff9e9e9e),
                                    enabledBorderColor: Color(0xff9e9e9e),
                                    fillColor: Color(0xffffffff),
                                    borderRadius: 5,
                                    controller: TextEditingController(),
                                    textCapitalization: TextCapitalization.words,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  MyText(text: "Delivery Person Name"),
                                  100.width,
                                  MyText(text: "Delivery Person Mobile No"),
                                ],
                              ),
                              Row(
                                children: [
                                  MyTextField(
                                    hintText: "Area",
                                    autofocus: false,
                                    width: 352,
                                    labelText: '',
                                    isOptional: false,
                                    focusedBorderColor: Color(0xff9e9e9e),
                                    enabledBorderColor: Color(0xff9e9e9e),
                                    fillColor: Color(0xffffffff),
                                    borderRadius: 5,
                                    controller: TextEditingController(),
                                    textCapitalization: TextCapitalization.words,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  20.width,
                                  MyTextField(
                                    width: 350,
                                    hintText: "City",
                                    autofocus: false,
                                    labelText: '',
                                    isOptional: false,
                                    focusedBorderColor: Color(0xff9e9e9e),
                                    enabledBorderColor: Color(0xff9e9e9e),
                                    fillColor: Color(0xffffffff),
                                    borderRadius: 5,
                                    controller: TextEditingController(),
                                    textCapitalization: TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    // validator: validationConstant.validatePincode,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  MyText(text: "Delivery Person Name"),
                                  100.width,
                                  MyText(text: "Delivery Person Mobile No"),
                                ],
                              ),
                              Row(
                                children: [
                                  // SizedBox(
                                  //   width:screenWidth*0.15,
                                  //   child: MyDropdownMenu<CityObj>(
                                  //     width: screenWidth*0.13,
                                  //     enableSearch: true,
                                  //     enableFilter: true,
                                  //     menuHeight: 300,
                                  //     dropdownMenuEntries:listConstant.citiesOfTamilNadu.map((city) {
                                  //       return MyDropdownMenuEntry<CityObj>(
                                  //         value: city,
                                  //         enabled: true,
                                  //         label: city.name,
                                  //       );
                                  //     }).toList(),
                                  //     menuStyle: MenuStyle(
                                  //       backgroundColor: WidgetStatePropertyAll(colorsConstant.white),
                                  //     ),
                                  //     hintText: "Search city...",
                                  //     // labelText: "Category",
                                  //     onSelected: (CityObj? selectedCity) {
                                  //       setState(() {
                                  //         customerProvider.customerCity.text=selectedCity!.name;
                                  //       });
                                  //     },
                                  //   ),
                                  // ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: MyDropDown(
                                      height: MediaQuery.of(context).size.height * 0.08,
                                      width: MediaQuery.of(context).size.width * 0.18,
                                      labelText: "State",
                                      value: selectedState,
                                      borderRadius: 8,
                                      items: states.map((String state) {
                                        return DropdownMenuItem(
                                          value: state,
                                          child: Text(state),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          customerState.text = value;
                                          changeState(customerState.text.trim());
                                        }
                                      },
                                    ),
                                  ),
                                  20.width,
                                  MyTextField(
                                    width: 300,
                                    hintText: "Pincode",
                                    autofocus: false,
                                    controller: TextEditingController(),
                                    textCapitalization: TextCapitalization.words,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: InputFormatters.pinCodeInput,
                                    isOptional: false,
                                    focusedBorderColor: Color(0xff9e9e9e),
                                    enabledBorderColor: Color(0xff9e9e9e),
                                    fillColor: Color(0xffffffff),
                                    borderRadius: 5,
                                    // validator: validationConstant.validatePincode,
                                  ),
                                ],
                              ),
                              Buttons.loginButton(
                                context: context,
                                loadingButtonController: loadingButtonController,
                                onPressed: () {
                                  // addDelivery(
                                  //     context: context,
                                  //     name: deliveryName.text.trim(),
                                  //     mobile: deliveryMobile.text.trim(),
                                  //     dAddressLine1: deliveryStreet.text.trim(), dArea: deliveryArea.text.trim(),
                                  //     dPinCode: deliveryPincode.text.trim(), dCity: deliveryCity.text.trim(),
                                  //     dState: deliveryState.text.trim(),
                                  //     userId: selectedCustomerId,
                                  //     vehicleNo: vehicleNumer.text.trim()
                                  // );
                                },
                                text: 'Submit',
                              ),
                            ],
                          ) ,
                        ),
                      ),
                    );
                  });
            });
      },
    );
  }

}
