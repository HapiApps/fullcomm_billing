import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_billing/data/local_data.dart';
import 'package:fullcomm_billing/repo/customer_repo.dart';
import 'package:fullcomm_billing/res/colors.dart';
import 'package:fullcomm_billing/res/components/k_dropdown.dart';
import 'package:fullcomm_billing/utils/sized_box.dart';
import 'package:fullcomm_billing/utils/toast_messages.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../models/customers_response.dart';
import '../models/state_obj.dart';
import '../res/components/buttons.dart';
import '../res/components/k_dropdown_menu.dart';
import '../res/components/k_text.dart';
import '../res/components/k_text_field.dart';
import '../res/dropdown_list.dart';
import '../utils/input_formatters.dart';
import '../utils/text_formats.dart';

class AddressEntry {
  final TextEditingController doorController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  StateObj? selectedState;
  void dispose() {
    doorController.dispose();
    areaController.dispose();
    cityController.dispose();
    stateController.dispose();
    pinController.dispose();
  }
}


class DeliveryAddressEntry {
  final TextEditingController doorController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  StateObj? selectedState;
  void dispose() {
    doorController.dispose();
    areaController.dispose();
    cityController.dispose();
    stateController.dispose();
    pinController.dispose();
  }
  @override
  String toString() {
    return "${doorController.text}, ${areaController.text}, ${cityController.text}, ${stateController.text}, ${pinController.text}";
  }
}

class MenuItem {
  final int id;
  final String label;

  MenuItem(this.id, this.label);

  @override
  String toString() => label; // important for dropdown_search
}

class CustomersProvider with ChangeNotifier {
  final CustomersRepository _customerRepo = CustomersRepository();

  final List<MenuItem> stateItems = [
    MenuItem(1, "Andhra Pradesh"),
    MenuItem(2, "Arunachal Pradesh"),
    MenuItem(3, "Assam"),
    MenuItem(4, "Bihar"),
    MenuItem(5, "Chhattisgarh"),
    MenuItem(6, "Goa"),
    MenuItem(7, "Gujarat"),
    MenuItem(8, "Haryana"),
    MenuItem(9, "Himachal Pradesh"),
    MenuItem(10, "Jharkhand"),
    MenuItem(11, "Karnataka"),
    MenuItem(12, "Kerala"),
    MenuItem(13, "Madhya Pradesh"),
    MenuItem(14, "Maharashtra"),
    MenuItem(15, "Manipur"),
    MenuItem(16, "Meghalaya"),
    MenuItem(17, "Mizoram"),
    MenuItem(18, "Nagaland"),
    MenuItem(19, "Odisha"),
    MenuItem(20, "Punjab"),
    MenuItem(21, "Rajasthan"),
    MenuItem(22, "Sikkim"),
    MenuItem(23, "Tamil Nadu"),
    MenuItem(24, "Telangana"),
    MenuItem(25, "Tripura"),
    MenuItem(26, "Uttar Pradesh"),
    MenuItem(27, "Uttarakhand"),
    MenuItem(28, "West Bengal"),
    MenuItem(29, "Andaman and Nicobar Islands"),
    MenuItem(30, "Chandigarh"),
    MenuItem(31, "Dadra and Nagar Haveli and Daman and Diu"),
    MenuItem(32, "Delhi"),
    MenuItem(33, "Jammu and Kashmir"),
    MenuItem(34, "Ladakh"),
    MenuItem(35, "Lakshadweep"),
    MenuItem(36, "Puducherry"),
    MenuItem(37, ""),
  ];

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
   if(state.isEmpty){
     _selectedState = null;
   }else{
     _selectedState = state;
   }
    notifyListeners();
  }

  final List<AddressEntry> _addresses = [];
  List<AddressEntry> get addresses => _addresses;

  final List<DeliveryAddressEntry> _deliveryAddresses = [];
  List<DeliveryAddressEntry> get deliveryAddresses => _deliveryAddresses;

  void addAddress() {
    _addresses.add(AddressEntry());
    notifyListeners();
  }

  void removeAddress(int index) {
    _addresses[index].dispose();
    _addresses.removeAt(index);
    notifyListeners();
  }



  void addDeliveryAddress() {
    _deliveryAddresses.add(DeliveryAddressEntry());
    notifyListeners();
  }

  void removeDeliveryAddress(int index) {
    _deliveryAddresses[index].dispose();
    _deliveryAddresses.removeAt(index);
    notifyListeners();
  }
  void keepFirstAddressClearRest() {
    if (_addresses.isNotEmpty) {
      _addresses.first.doorController.clear();
      _addresses.first.areaController.clear();
      _addresses.first.cityController.clear();
      _addresses.first.stateController.text = "";
      _addresses.first.selectedState = null;
      _addresses.first.pinController.clear();

      // Dispose & remove all others starting from index 1
      for (var i = 1; i < _addresses.length; i++) {
        _addresses[i].dispose();
      }
      _addresses.removeRange(1, _addresses.length);
    }
    notifyListeners();
  }

  void keepFirstDeliveryClearRest() {
    if (_deliveryAddresses.isNotEmpty) {
      _deliveryAddresses.first.doorController.clear();
      _deliveryAddresses.first.areaController.clear();
      _deliveryAddresses.first.cityController.clear();
      _deliveryAddresses.first.stateController.text = "";
      _deliveryAddresses.first.pinController.clear();

      for (var i = 1; i < _deliveryAddresses.length; i++) {
        _deliveryAddresses[i].dispose();
      }
      _deliveryAddresses.removeRange(1, _deliveryAddresses.length);
    }
    notifyListeners();
  }

  void clearAll() {
    for (var entry in _addresses) {
      entry.dispose();
    }
    _addresses.clear();
    notifyListeners();
  }
  void clearAllDelivery() {
    for (var entry in _deliveryAddresses) {
      entry.dispose();
    }
    _deliveryAddresses.clear();
    notifyListeners();
  }


  // Add Customer Fields :
  TextEditingController customerGST         = TextEditingController();
  TextEditingController customerGSTLocation = TextEditingController();
  TextEditingController customerName = TextEditingController();
  TextEditingController customerMobile = TextEditingController();
  TextEditingController customerStreet = TextEditingController();
  TextEditingController customerArea = TextEditingController();
  TextEditingController customerCity = TextEditingController();
  TextEditingController customerPincode = TextEditingController();
  TextEditingController customerCountry = TextEditingController();
  TextEditingController deliveryStreet      = TextEditingController();
  TextEditingController deliveryArea        = TextEditingController();
  TextEditingController deliveryCity        = TextEditingController();
  TextEditingController deliveryPincode     = TextEditingController();
  TextEditingController deliveryState       = TextEditingController(text: 'TamilNadu');
  TextEditingController deliveryName        = TextEditingController();
  TextEditingController deliveryMobile      = TextEditingController();
  TextEditingController vehicleNumer        = TextEditingController();
  TextEditingController customerState = TextEditingController(text: 'TamilNadu');

  // Loading Button Controller:
  RoundedLoadingButtonController loadingButtonController = RoundedLoadingButtonController();
  TextEditingController deliveryAddressController = TextEditingController();

  String? _selectedDeliveryAddress;

  String? get selectedDeliveryAddress => _selectedDeliveryAddress;

  void setSelectedDeliveryAddress(String? address) {
    _selectedDeliveryAddress = address;
    notifyListeners();
  }

  List<String> _deliveryAddressList = [];

  List<String> get deliveryAddressList => _deliveryAddressList;

  void setDeliveryAddressList(List<String> addresses) {
    _deliveryAddressList = addresses;
    notifyListeners();
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
                      backgroundColor:Color(0xffEEEFF2),
                      titlePadding: EdgeInsets.zero,
                      title:  Container(
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
                              text: 'Add Delivery Address',
                              fontSize: TextFormat.responsiveFontSize(context, 20),
                              fontWeight: FontWeight.bold,
                              textAlign: TextAlign.center,
                              color: Colors.white,
                            ),400.width,
                            IconButton(onPressed: (){
                              Navigator.pop(context);
                            }, icon: Icon(Icons.clear,color: Colors.white,))
                          ],
                        ),
                      ),
                      content: SingleChildScrollView(
                        child: Container(
                          color: Color(0xffEEEFF2),
                          alignment: Alignment.center,
                          child:Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          MyText(text: "Delivery Person Name"),
                                          MyText(text: "*", color: Colors.red, fontSize: 20)
                                        ],
                                      ),
                                      MyTextField(
                                        hintText: "Enter Delivery Person Name",
                                        autofocus: false,
                                        width: 350,
                                        height: 40,
                                        // controller: customersProvider.deliveryName,
                                        textCapitalization: TextCapitalization.words,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.next, isOptional: true,
                                        labelText: '',
                                        focusedBorderColor: AppColors.primary,
                                        enabledBorderColor: Colors.grey.shade300,
                                        fillColor: Color(0xffffffff),
                                        borderRadius: 5, controller: deliveryName,
                                      ),
                                    ],
                                  ),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          MyText(text: "Delivery Person Mobile No"),
                                          MyText(text: "*", color: Colors.red, fontSize: 20)
                                        ],
                                      ),
                                      MyTextField(
                                        hintText: "Enter Delivery Person Mobile No",
                                        autofocus: false,
                                        width: 350,
                                        height: 40,
                                        controller: deliveryMobile,
                                        textCapitalization: TextCapitalization.words,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: InputFormatters.mobileNumberInput,
                                        textInputAction: TextInputAction.next,
                                        labelText: '',
                                        isOptional: true,
                                        focusedBorderColor: AppColors.primary,
                                        enabledBorderColor: Colors.grey.shade300,
                                        fillColor: Color(0xffffffff),
                                        borderRadius: 5,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              6.height,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          MyText(text: "Vehicle Number"),
                                          MyText(text: "", color: Colors.red, fontSize: 20)
                                        ],
                                      ),
                                      MyTextField(
                                        hintText: "Enter Vehicle Number",
                                        autofocus: false,
                                        width: 350,
                                        height: 40,
                                        labelText: '',
                                        isOptional: true,
                                        focusedBorderColor: AppColors.primary,
                                        enabledBorderColor: Colors.grey.shade300,
                                        fillColor: Color(0xffffffff),
                                        borderRadius: 5,
                                        controller: vehicleNumer,
                                        textCapitalization: TextCapitalization.words,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.next,
                                      ),
                                    ],
                                  ),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          MyText(text: "Door No / Street"),
                                          MyText(text: "", color: Colors.red, fontSize: 20)
                                        ],
                                      ),
                                      MyTextField(
                                        hintText: "Enter Door No / Street",
                                        autofocus: false,
                                        width: 350,
                                        height: 40,
                                        labelText: '',
                                        isOptional: true,
                                        focusedBorderColor: AppColors.primary,
                                        enabledBorderColor: Colors.grey.shade300,
                                        fillColor: Color(0xffffffff),
                                        borderRadius: 5,
                                        controller: deliveryStreet,
                                        textCapitalization: TextCapitalization.words,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.next,
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          MyText(text: "Area"),
                                          MyText(text: "", color: Colors.red, fontSize: 20)
                                        ],
                                      ),
                                      MyTextField(
                                        hintText: "Enter Area",
                                        autofocus: false,
                                        width: 352,
                                        height: 40,
                                        labelText: '',
                                        isOptional: true,
                                        focusedBorderColor: AppColors.primary,
                                        enabledBorderColor: Colors.grey.shade300,
                                        fillColor: Color(0xffffffff),
                                        borderRadius: 5,
                                        controller: deliveryArea,
                                        textCapitalization: TextCapitalization.words,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.next,
                                      ),
                                    ],
                                  ),
                                  20.width,
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          MyText(text: "City"),
                                          MyText(text: "*", color: Colors.red, fontSize: 20)
                                        ],
                                      ),
                                      MyTextField(
                                        width: 350,
                                        hintText: "Enter City",
                                        autofocus: false,
                                        height: 40,
                                        labelText: '',
                                        isOptional: true,
                                        focusedBorderColor: AppColors.primary,
                                        enabledBorderColor: Colors.grey.shade300,
                                        fillColor: Color(0xffffffff),
                                        borderRadius: 5,
                                        controller: deliveryCity,
                                        textCapitalization: TextCapitalization.words,
                                        textInputAction: TextInputAction.next,
                                        // validator: validationConstant.validatePincode,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          MyText(text: "State"),
                                          MyText(text: "", color: Colors.red, fontSize: 20)
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 1),
                                        child: MyDropdownMenu<StateObj>(
                                          width: 350,
                                          enableSearch: true,
                                          enableFilter: true,
                                          menuHeight: 350,
                                          inputFormatters: InputFormatters.textOnlyInput,
                                          initialSelection: selectedState == null
                                              ? null
                                              : listConstant.statesOfIndia.firstWhere(
                                                (s) => s.name == selectedState,
                                          ),
                                          dropdownMenuEntries: listConstant.statesOfIndia.map((state) {
                                            return MyDropdownMenuEntry<StateObj>(
                                              value: state,
                                              enabled: true,
                                              label: state.name,
                                            );
                                          }).toList(),
                                          menuStyle: MenuStyle(
                                            backgroundColor: WidgetStatePropertyAll(AppColors.white),
                                          ),
                                          hintText: " ",
                                          onSelected: (StateObj? selectedState) {
                                                if (selectedState?.name != null) {
                                                  deliveryState.text = selectedState?.name ?? "";
                                                  changeState(deliveryState.text.trim());
                                                }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          MyText(text: "Pin Code"),
                                          MyText(text: "*", color: Colors.red, fontSize: 20)
                                        ],
                                      ),
                                      MyTextField(
                                        width: 350,
                                        hintText: "Enter Pincode",
                                        height: 50,
                                        labelText: '',
                                        autofocus: false,
                                        controller: deliveryPincode,
                                        textCapitalization: TextCapitalization.words,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.next,
                                        inputFormatters: InputFormatters.pinCodeInput,
                                        isOptional: true,
                                        focusedBorderColor: AppColors.primary,
                                        enabledBorderColor: Colors.grey.shade300,
                                        fillColor: Color(0xffffffff),
                                        borderRadius: 5,
                                        // validator: validationConstant.validatePincode,
                                      ),
                                    ],
                                  ),
                                ],
                              ),10.height,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 50,
                                    width: 100,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        deliveryStreet.clear();
                                        deliveryCity.clear();
                                        deliveryArea.clear();
                                        deliveryPincode.clear();
                                        deliveryName.clear();
                                        deliveryMobile.clear();
                                        vehicleNumer.clear();
                                        deliveryState.clear();
                                        changeState("");
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xffEEEFF2), // button background color
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8), // rounded corners
                                        ),
                                        elevation: 0, // shadow
                                      ),
                                      child: const Text(
                                        "Clear",
                                        style: TextStyle(
                                          fontSize: 18,
                                          //fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  20.width,
                                  Buttons.loginButton(
                                    context: context,
                                    width: 120,
                                    height: 40,
                                    loadingButtonController: loadingButtonController,
                                    onPressed: () {
                                      if (deliveryName.text.isEmpty) {
                                        loadingButtonController.reset();
                                        Toasts.showToastBar(
                                            context: context,
                                            text: "Please enter delivery person name",
                                            color: Colors.red);
                                      } else if (deliveryMobile.text.isEmpty) {
                                        loadingButtonController.reset();
                                        Toasts.showToastBar(
                                            context: context,
                                            text: "Please enter delivery mobile no.",
                                            color: Colors.red);
                                      } else if (deliveryCity.text.isEmpty) {
                                       loadingButtonController.reset();
                                        Toasts.showToastBar(
                                            context: context,
                                            text: "Please enter city",
                                            color: Colors.red);
                                      } else if (deliveryPincode.text.isEmpty || deliveryPincode.text.length!=6) {
                                        loadingButtonController.reset();
                                        Toasts.showToastBar(
                                            context: context,
                                            text: "Please enter pincode",
                                            color: Colors.red);
                                      } else if (deliveryPincode.text.length!=6) {
                                        loadingButtonController.reset();
                                        Toasts.showToastBar(
                                            context: context,
                                            text: "Pincode must be 6 characters.",
                                            color: Colors.red);
                                      }else {
                                        addDelivery(
                                            context: context,
                                            name: deliveryName.text.trim(),
                                            mobile: deliveryMobile.text.trim(),
                                            dAddressLine1: deliveryStreet.text.trim(),
                                            dArea: deliveryArea.text.trim(),
                                            dPinCode: deliveryPincode.text.trim(),
                                            dCity: deliveryCity.text.trim(),
                                            dState: deliveryState.text.trim(),
                                            userId: selectedCustomerId,
                                            vehicleNo: vehicleNumer.text.trim()
                                        );
                                      }
                                    },
                                    text: 'Submit',
                                  ),
                                ],
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

  void clearCustomerData() {
    localData.customerName = "";
    localData.customerMobile = "";
    localData.customerAddress = "";
    localData.deliveryAddress = "";

    customerAddressController.clear();
    deliveryAddressController.clear();
    cusController.text="";
    setSelectedDeliveryAddress("");
    _addresses.clear();
    _deliveryAddresses.clear();

    notifyListeners();
  }
  /// ----------- Add Customer ----------------------
  Future<void> addCustomer({
    required BuildContext context,
    required String name,
    required String mobile,
    required String gst,
    required String gstLocation,
  }) async {
    try {
      final response = await _customerRepo.addCustomer(
          name: name,
          mobile: mobile,
        gst: gst,
        gstLocation: gstLocation,
        addresses: _addresses,
        deliveryAddresses: _deliveryAddresses,
          );
      if (response.responseCode == 200) {
        // Store Customer Details:
        localData.customerName = name;
        localData.customerMobile = mobile;
        localData.customerAddress = "${_addresses.first.doorController.text},${_addresses.first.areaController.text},${_addresses.first.cityController.text},${_addresses.first.pinController.text}".replaceAll(',,', ','); // Fix
        localData.deliveryAddress = "${_deliveryAddresses.first.doorController.text},${_deliveryAddresses.first.areaController.text},${_deliveryAddresses.first.cityController.text},${_deliveryAddresses.first.pinController.text}".replaceAll(',,', ','); // Fix
        customerAddressController.text = localData.customerAddress.toString();

        if (!context.mounted) return;
        await getAllCustomers(context);
        final newCustomer = Customer(
          userId: _allCustomers.last.userId, // or generate temp id
          name: localData.customerName,
          mobile: localData.customerMobile,
          addressDetails: [
            AddressDetail(
              type: "home",
              addressLine1: _addresses.first.doorController.text,
              area: _addresses.first.areaController.text,
              city: _addresses.first.cityController.text,
              state: "", // if needed
              pincode: _addresses.first.pinController.text,
            ),
            AddressDetail(
              type: "delivery",
              addressLine1: _deliveryAddresses.first.doorController.text,
              area: _deliveryAddresses.first.areaController.text,
              city: _deliveryAddresses.first.cityController.text,
              state: "",
              pincode: _deliveryAddresses.first.pinController.text,
            ),
          ],
        );
        if (!context.mounted) return;
        Navigator.pop(context);
        cusController.text = "${localData.customerName} - ${localData.customerMobile}";
        setDeliveryAddressList(
            _deliveryAddresses.map((e) => e.toString()).toList()
        );

        if (_deliveryAddresses.isNotEmpty) {
          final firstValue = _deliveryAddresses.first.toString();
          setSelectedDeliveryAddress(firstValue);
          deliveryAddressController.text = firstValue;
        }
        notifyListeners();
       setCustomerDetails(
          customerId: newCustomer.userId.toString(),
          customerName: localData.customerName,
          customerMobile: localData.customerMobile,
          customerAddress: customerAddressController.text,
          deliveryAddress: deliveryAddressController.text,
        );
        notifyListeners();

        // Clear Fields:
        customerName.clear();
        customerMobile.clear();
        customerStreet.clear();
        customerArea.clear();
        customerCity.clear();
        customerPincode.clear();
        customerGST.clear();
        customerGSTLocation.clear();
        _addresses.clear();
        _deliveryAddresses.clear();
        notifyListeners();

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
            title: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                icon: SvgPicture.asset("assets/images/clear.svg"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
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
                    Row(
                      children: [
                        MyTextField(
                          labelText: "Customer's Name",
                          controller: customerName,
                          isOptional: false,
                          borderRadius: 8,
                         height: 60,
                        ),
                        10.width,
                        MyTextField(
                          labelText: "Mobile Number",
                          isOptional: false,
                          controller: customerMobile,
                          inputFormatters: InputFormatters.mobileNumberInput,
                          borderRadius: 8,
                          height: 60,
                        ),
                      ],
                    ),
                    10.height,
                    Row(
                      children: [
                        MyTextField(
                          labelText: "Door No, Street",
                          isOptional: true,
                          controller: customerStreet,
                          textCapitalization: TextCapitalization.sentences,
                          borderRadius: 8,
                          height: 60,
                        ),
                        10.width,
                        MyTextField(
                          labelText: "Area",
                          isOptional: true,
                          controller: customerArea,
                          textCapitalization: TextCapitalization.sentences,
                          borderRadius: 8,
                          height: 60,
                        ),
                      ],
                    ),

                    10.height,
                    Row(
                      children: [
                        MyTextField(
                          labelText: "City",
                          isOptional: false,
                          controller: customerCity,
                          textCapitalization: TextCapitalization.sentences,
                          borderRadius: 8,
                          height: 60,
                        ),
                        10.width,
                        MyTextField(
                          labelText: "Pincode",
                          isOptional: false,
                          controller: customerPincode,
                          inputFormatters: InputFormatters.pinCodeInput,
                          borderRadius: 8,
                          height: 60,
                        ),
                      ],
                    ),

                    10.height,

                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: MyDropDown(
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
                        ),
                        10.width,
                        MyTextField(
                          labelText: "Country",
                          isOptional: true,
                          controller: customerCountry,
                          borderRadius: 8,
                          height: 60,
                        ),
                      ],
                    ),
                    // MyTextField(
                    //   labelText: "State",
                    //   controller: customerState,
                    //   isOptional: true,
                    //   textCapitalization: TextCapitalization.sentences,
                    // ),
              10.height,
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
                                gst: customerGST.text,
                                gstLocation: customerGSTLocation.text
                                // addressLine1: customerStreet.text,
                                // area: customerArea.text,
                                // pincode: customerPincode.text,
                                // city: customerCity.text,
                                // state: customerState.text,
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

  Future<void> addDelivery({
    required BuildContext context,
    required String name,
    required String mobile,
    required String dAddressLine1,
    required String dArea,
    required String dPinCode,
    required String dCity,
    required String dState,
    required String userId,
    required String vehicleNo,
  }) async {
    try {
      final response = await _customerRepo.addDelivery(
          name: name,
          mobile: mobile,
          dAddressLine1: dAddressLine1, dArea: dArea, dPinCode: dPinCode, dCity: dCity,
          dState: dState,userId: userId,vehicleNo: vehicleNo
      );

      if (response.responseCode == 200) {
        // Store Customer Details:
        localData.customerName = name;
        localData.customerMobile = mobile;
        localData.deliveryAddress = "$dAddressLine1,$dArea,$dCity,$dState,$dPinCode".replaceAll(',,', ',');
        deliveryAddressController.text = "$dAddressLine1,$dArea,$dCity,$dState,$dPinCode".replaceAll(',,', ',');
        //setSelectedDeliveryAddress(deliveryAddressController.text);
        List<String> addresses = [];
        addresses.add(deliveryAddressController.text);
        setDeliveryAddressList(addresses);

        if (_deliveryAddresses.isNotEmpty) {
          final firstValue = _deliveryAddresses.first.toString();
          setSelectedDeliveryAddress(firstValue);
          deliveryAddressController.text = firstValue;
        }
        if (!context.mounted) return;
        Toasts.showToastBar(context: context, text: 'Delivery Address is added.',color: AppColors.green);
        Navigator.pop(context);
        deliveryStreet.clear();
        deliveryCity.clear();
        deliveryArea.clear();
        deliveryPincode.clear();
        deliveryName.clear();
        deliveryMobile.clear();
        vehicleNumer.clear();
        if (!context.mounted) return;
        await getAllCustomers(context);

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

  /// -------- Customer Selection -------------------
  String _selectedCustomerId = '';
  String _selectedCustomerName = '';
  String _selectedCustomerMobile = '';

  String get selectedCustomerId => _selectedCustomerId;
  String get selectedCustomerName => _selectedCustomerName;
  String get selectedCustomerMobile => _selectedCustomerMobile;

  /// -------- Fetch all Customers -----------------
  TextEditingController cusController = TextEditingController();
  List<Customer> _allCustomers = [];
  List<Customer> get allCustomersList => _allCustomers;

  // Fetch all Customers Api :
  Future<void> getAllCustomers(context) async {
    try {
      final response = await _customerRepo.getCustomers();

      if (response.responseCode == '200') {
        _allCustomers = response.data ?? [];
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
  void setCustomerDetails({required String customerId,
    required String customerName,required String customerMobile,required String customerAddress,
    required String deliveryAddress}){
    _selectedCustomerId = customerId;
    _selectedCustomerName = customerName;
    _selectedCustomerMobile = customerMobile;
    customerAddressController.text = customerAddress;
    deliveryAddressController.text = deliveryAddress;
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
          title: const MyText(text:'Product Name',fontSize: 15,color: AppColors.primary,fontWeight: FontWeight.bold,),
          content: SizedBox(
            height: 50,
            child: MyTextField(
              hintText: "Product Name",
              autofocus: false,
              isOptional: true,
              focusNode:focus,
              labelText: "",
              borderRadius: 2,
              focusedBorderColor: AppColors.primary,
              enabledBorderColor: Color(0xff9e9e9e),
              controller: controller!,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: onSubmitted,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(
                    color:AppColors.primary
                  )
                )// Make the button transparent
              ),
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: MyText(text: "Cancel",color: AppColors.black,)),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor:AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(
                            color:AppColors.primary
                        )
                    )// Make the button transparent
                ),
                onPressed: onChanged,
                child: MyText(text: "Ok",color:Colors.white,))
          ],
        );
      },
    );
  }
}
