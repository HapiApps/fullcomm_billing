
import 'package:flutter/material.dart';
import 'package:fullcomm_billing/res/colors.dart';
import 'package:provider/provider.dart';
import 'package:fullcomm_billing/models/state_obj.dart';
import 'package:fullcomm_billing/res/components/k_text.dart';
import 'package:fullcomm_billing/utils/sized_box.dart';
import 'package:fullcomm_billing/view_models/customer_provider.dart';

import '../res/components/buttons.dart';
import '../res/components/k_dropdown_menu.dart';
import '../res/components/k_text_field.dart';
import '../res/dropdown_list.dart';
import '../utils/input_formatters.dart';
import '../utils/text_formats.dart';
import '../utils/toast_messages.dart';


class AddCustomerDialog extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final List<TextEditingController> addressControllers = List.generate(
    3,
        (_) => TextEditingController(),
  );

  AddCustomerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomersProvider>(
        builder: (context,customerProvider,child){
          if (customerProvider.addresses.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              customerProvider.addAddress();
            });
          }
          if (customerProvider.deliveryAddresses.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              customerProvider.addDeliveryAddress();
            });
          }
          return AlertDialog(
              backgroundColor:Color(0xffEEEFF2),
              titlePadding: EdgeInsets.zero,
              title: Container(
                alignment: Alignment.center,
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
                      text: 'Add Customer',
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
            content: Container(
              width: 755,
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      20.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  MyText(text: "Customer Name",color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15,),
                                  MyText(text: "*", color: Colors.red, fontSize: 20)
                                ],
                              ),
                              5.height,
                              MyTextField(
                                hintText: "Enter Customer Name",
                                autofocus: false,
                                width: 350,
                                textCapitalization: TextCapitalization.words,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next, isOptional: true,
                                labelText: '',
                                focusedBorderColor: AppColors.primary,
                                enabledBorderColor: Colors.grey.shade300,
                                fillColor: Color(0xffffffff),
                                borderRadius: 3,
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    // first letter uppercase + rest as is
                                    String newValue = value[0].toUpperCase() + value.substring(1);
                                    if (newValue != value) {
                                      customerProvider.customerName.value = customerProvider.customerName.value.copyWith(
                                        text: newValue,
                                        selection: TextSelection.collapsed(offset: newValue.length),
                                      );
                                    }
                                  }
                                },
                                controller: customerProvider.customerName,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  MyText(text: "Customer Mobile No",
                                    color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15,),
                                  MyText(text: "*", color: Colors.red, fontSize: 20)
                                ],
                              ),
                              5.height,
                              MyTextField(
                                hintText: "Enter Customer  Mobile No",
                                autofocus: false,
                                width: 350,
                                controller: customerProvider.customerMobile,
                                textCapitalization: TextCapitalization.words,
                                keyboardType: TextInputType.number,
                                inputFormatters: InputFormatters.mobileNumberInput,
                                textInputAction: TextInputAction.next,
                                labelText: '',
                                isOptional: true,
                                focusedBorderColor: AppColors.primary,
                                enabledBorderColor: Colors.grey.shade300,
                                fillColor: Color(0xffffffff),
                                borderRadius: 3,
                              ),
                            ],
                          ),
                        ],
                      ),
                      10.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              MyText(text: "GST",color: Colors.black,
                                fontWeight: FontWeight.bold,fontSize: 15,),
                              5.height,
                              MyTextField(
                                hintText: "Enter GST",
                                autofocus: false,
                                width: 350,
                                labelText: '',
                                isOptional: true,
                                focusedBorderColor: AppColors.primary,
                                enabledBorderColor: Colors.grey.shade300,
                                fillColor: Color(0xffffffff),
                                borderRadius: 3,
                                controller: customerProvider.customerGST,
                                inputFormatters: InputFormatters.gstInputFormat,
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
                              MyText(text: "GST Location",color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15,),5.height,
                              MyTextField(
                                hintText: "Enter GST Location",
                                autofocus: false,
                                width: 350,
                                labelText: '',
                                isOptional: true,
                                focusedBorderColor: AppColors.primary,
                                enabledBorderColor: Colors.grey.shade300,
                                fillColor: Color(0xffffffff),
                                borderRadius: 3,
                                controller: customerProvider.customerGSTLocation,
                                textCapitalization: TextCapitalization.words,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                              ),
                            ],
                          ),
                        ],
                      ),
                      10.height,
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: customerProvider.addresses.length,
                        itemBuilder: (context, index) {
                          final entry = customerProvider.addresses[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.home_filled),5.width,
                                      MyText(text: "Customer Address",color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18,),
                                    ],
                                  ),
                                  //Text('Address ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold)),
                                  10.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          MyText(text: "Door No/Street",color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15,),5.height,
                                          MyTextField(
                                            hintText: "Enter Door No/Street",
                                            autofocus: false,
                                            width: 350,
                                            labelText: '',
                                            isOptional: true,
                                            focusedBorderColor: AppColors.primary,
                                            enabledBorderColor: Colors.grey.shade300,
                                            fillColor: Color(0xffffffff),
                                            borderRadius: 3,
                                            controller: entry.doorController,
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
                                          MyText(text: "Area",color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15,),5.height,
                                          MyTextField(
                                            hintText: "Enter Area",
                                            autofocus: false,
                                            width: 350,
                                            labelText: '',
                                            isOptional: true,
                                            focusedBorderColor: AppColors.primary,
                                            enabledBorderColor: Colors.grey.shade300,
                                            fillColor: Color(0xffffffff),
                                            borderRadius: 5,
                                            controller: entry.areaController,
                                            textCapitalization: TextCapitalization.words,
                                            keyboardType: TextInputType.text,
                                            textInputAction: TextInputAction.next,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),7.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              MyText(text: "City",color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15,),
                                              MyText(text: "*", color: Colors.red, fontSize: 20)
                                            ],
                                          ),
                                          5.height,
                                          MyTextField(
                                            hintText: "Enter City",
                                            autofocus: false,
                                            width: 200,
                                            labelText: '',
                                            isOptional: true,
                                            focusedBorderColor: AppColors.primary,
                                            enabledBorderColor: Colors.grey.shade300,
                                            fillColor: Color(0xffffffff),
                                            borderRadius: 3,
                                            controller:entry.cityController,
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
                                              MyText(text: "State",color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15,),
                                              MyText(text: "*", color: Colors.red, fontSize: 20)
                                            ],
                                          ),5.height,
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width * 0.13,
                                            child: MyDropdownMenu<StateObj>(
                                              width: 280,
                                              enableSearch: true,
                                              enableFilter: true,
                                              menuHeight: 350,
                                              inputFormatters: InputFormatters.textOnlyInput,
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
                                                entry.selectedState = selectedState;
                                                entry.stateController.text = selectedState?.name ?? "";
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
                                              MyText(text: "Pincode",color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15,),
                                              MyText(text: "*", color: Colors.red, fontSize: 20)
                                            ],
                                          ),5.height,
                                          MyTextField(
                                            hintText: "Enter Pincode",
                                            autofocus: false,
                                            width: 200,
                                            labelText: '',
                                            isOptional: true,
                                            focusedBorderColor: AppColors.primary,
                                            enabledBorderColor: Colors.grey.shade300,
                                            fillColor: Color(0xffffffff),
                                            borderRadius: 5,
                                            inputFormatters: InputFormatters.pinCodeInput,
                                            controller:entry.pinController,
                                            textCapitalization: TextCapitalization.words,
                                            keyboardType: TextInputType.text,
                                            textInputAction: TextInputAction.next,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),7.height,
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: index == customerProvider.addresses.length - 1
                                        ? TextButton.icon(
                                      onPressed: () {
                                        if(entry.cityController.text.isEmpty){
                                          Toasts.showToastBar(
                                              context: context,
                                              text: "Please enter city",
                                              color: Colors.red);
                                        }else if(entry.stateController.text.isEmpty){
                                          Toasts.showToastBar(
                                              context: context,
                                              text: "Please enter state",
                                              color: Colors.red);
                                        }else if(entry.pinController.text.isEmpty || entry.pinController.text.length!=6){
                                          Toasts.showToastBar(
                                              context: context,
                                              text: "Please enter pincode",
                                              color: Colors.red);
                                        }else{
                                          customerProvider.addAddress();
                                        }
                                      },
                                      icon: const Icon(Icons.add, color: Color(0xff00B669)),
                                      label: const MyText(text: "Add Address", color: Color(0xff00B669)),
                                    )
                                        : IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        customerProvider.removeAddress(index);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      10.height,
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: customerProvider.deliveryAddresses.length,
                        itemBuilder: (context, index) {
                          final entry = customerProvider.deliveryAddresses[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.local_shipping_outlined),5.width,
                                      MyText(text: "Delivery Address",color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18,),
                                    ],
                                  ),
                                  //Text('Address ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  10.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          MyText(text: "Door No/Street",color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15,),5.height,
                                          MyTextField(
                                            hintText: "Enter Door No/Street",
                                            autofocus: false,
                                            width: 350,
                                            labelText: '',
                                            isOptional: true,
                                            focusedBorderColor: AppColors.primary,
                                            enabledBorderColor: Colors.grey.shade300,
                                            fillColor: Color(0xffffffff),
                                            borderRadius: 3,
                                            controller: entry.doorController,
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
                                          MyText(text: "Area",color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15,),5.height,
                                          MyTextField(
                                            hintText: "Enter Area",
                                            autofocus: false,
                                            width: 350,
                                            labelText: '',
                                            isOptional: true,
                                            focusedBorderColor: AppColors.primary,
                                            enabledBorderColor: Colors.grey.shade300,
                                            fillColor: Color(0xffffffff),
                                            borderRadius: 5,
                                            controller: entry.areaController,
                                            textCapitalization: TextCapitalization.words,
                                            keyboardType: TextInputType.text,
                                            textInputAction: TextInputAction.next,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  10.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              MyText(text: "City",color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15,),
                                              MyText(text: "*", color: Colors.red, fontSize: 20)
                                            ],
                                          ),5.height,
                                          MyTextField(
                                            hintText: "Enter City",
                                            autofocus: false,
                                            width: 200,
                                            labelText: '',
                                            isOptional: true,
                                            focusedBorderColor: AppColors.primary,
                                            enabledBorderColor: Colors.grey.shade300,
                                            fillColor: Color(0xffffffff),
                                            borderRadius: 3,
                                            controller: entry.cityController,
                                            textCapitalization: TextCapitalization.words,
                                            keyboardType: TextInputType.text,
                                            textInputAction: TextInputAction.next,
                                          ),
                                        ],
                                      ),
                                      10.width,
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              MyText(
                                                text: "State",
                                                color: Colors.black,
                                              ),
                                              MyText(text: "*", color: Colors.red, fontSize: 20)
                                            ],
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width * 0.13,
                                            child: MyDropdownMenu<StateObj>(
                                              width: 280,
                                              enableSearch: true,
                                              enableFilter: true,
                                              menuHeight: 350,
                                              inputFormatters: InputFormatters.textOnlyInput,
                                              dropdownMenuEntries: listConstant.statesOfIndia.map((state) {
                                                return MyDropdownMenuEntry<StateObj>(
                                                  value: state,
                                                  enabled: true,
                                                  label: state.name,
                                                );
                                              }).toList(),
                                              menuStyle: MenuStyle(
                                                backgroundColor: WidgetStatePropertyAll(
                                                    Colors.white),
                                              ),
                                              hintText: " ",
                                              onSelected: (StateObj? selectedState) {
                                                entry.stateController.text = selectedState?.name ?? "";
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
                                              MyText(text: "Pincode",color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15,),
                                              MyText(text: "*", color: Colors.red, fontSize: 20)
                                            ],
                                          ),5.height,
                                          MyTextField(
                                            hintText: "Enter Pincode",
                                            autofocus: false,
                                            width: 200,
                                            labelText: '',
                                            isOptional: true,
                                            focusedBorderColor: AppColors.primary,
                                            enabledBorderColor: Colors.grey.shade300,
                                            fillColor: Color(0xffffffff),
                                            borderRadius: 5,
                                            controller: entry.pinController,
                                            inputFormatters: InputFormatters.pinCodeInput,
                                            textCapitalization: TextCapitalization.words,
                                            keyboardType: TextInputType.text,
                                            textInputAction: TextInputAction.next,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: index == customerProvider.deliveryAddresses.length - 1
                                        ? TextButton.icon(
                                      onPressed: () {
                                        if(entry.cityController.text.isEmpty){
                                          Toasts.showToastBar(
                                              context: context,
                                              text: "Please enter city",
                                              color: Colors.red);
                                        }else if(entry.stateController.text.isEmpty){
                                          Toasts.showToastBar(
                                              context: context,
                                              text: "Please enter state",
                                              color: Colors.red);
                                        }else if(entry.pinController.text.isEmpty || entry.pinController.text.length!=6){
                                          Toasts.showToastBar(
                                              context: context,
                                              text: "Please enter pincode",
                                              color: Colors.red);
                                        }else {
                                          customerProvider.addDeliveryAddress();
                                        }
                                      },
                                      icon: const Icon(Icons.add, color: Color(0xff00B669)),
                                      label: const MyText(text: "Add Address", color: Color(0xff00B669)),
                                    )
                                        : IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        customerProvider.removeDeliveryAddress(index);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      20.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              customerProvider.customerName.clear();
                              customerProvider.customerMobile.clear();
                              customerProvider.customerStreet.clear();
                              customerProvider.customerArea.clear();
                              customerProvider.customerCity.clear();
                              customerProvider.customerPincode.clear();
                              customerProvider.customerGST.clear();
                              customerProvider.customerGSTLocation.clear();
                              customerProvider.keepFirstAddressClearRest();
                              customerProvider.keepFirstDeliveryClearRest();
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          20.height,
                          Buttons.loginButton(
                            context: context,
                            width: 160,
                            height: 30,
                            // loadingButtonController: loadingButtonController,
                            onPressed: () {
                              if (customerProvider.customerName.text.isEmpty) {
                                customerProvider.loadingButtonController.reset();
                                Toasts.showToastBar(
                                    context: context,
                                    text: "Please enter customer name",
                                    color: Colors.red);
                              } else if (customerProvider.customerMobile.text.isEmpty) {
                                customerProvider.loadingButtonController.reset();
                                Toasts.showToastBar(
                                    context: context,
                                    text: "Please enter customer mobile",
                                    color: Colors.red);
                              }  else if (customerProvider.customerMobile.text.length!=10) {
                                customerProvider.loadingButtonController.reset();
                                Toasts.showToastBar(
                                    context: context,
                                    text: "Please enter 10 digits mobile number",
                                    color: Colors.red);
                              }else if(customerProvider.addresses[0].cityController.text.isEmpty){
                                customerProvider.loadingButtonController.reset();
                                Toasts.showToastBar(
                                    context: context,
                                    text: "Please enter customer address city",
                                    color: Colors.red);
                              }else if(customerProvider.addresses[0].stateController.text.isEmpty){
                                customerProvider.loadingButtonController.reset();
                                Toasts.showToastBar(
                                    context: context,
                                    text: "Please enter customer address state",
                                    color: Colors.red);
                              }else if(customerProvider.addresses[0].pinController.text.isEmpty){
                                customerProvider.loadingButtonController.reset();
                                Toasts.showToastBar(
                                    context: context,
                                    text: "Please enter customer address pincode",
                                    color: Colors.red);
                              }else if(customerProvider.deliveryAddresses[0].cityController.text.isEmpty){
                                customerProvider.loadingButtonController.reset();
                                Toasts.showToastBar(
                                    context: context,
                                    text: "Please enter delivery address city",
                                    color: Colors.red);
                              }else if(customerProvider.deliveryAddresses[0].stateController.text.isEmpty){
                                customerProvider.loadingButtonController.reset();
                                Toasts.showToastBar(
                                    context: context,
                                    text: "Please enter delivery address state",
                                    color: Colors.red);
                              }else if(customerProvider.deliveryAddresses[0].pinController.text.isEmpty){
                                customerProvider.loadingButtonController.reset();
                                Toasts.showToastBar(
                                    context: context,
                                    text: "Please enter delivery address pincode",
                                    color: Colors.red);
                              }else{
                                customerProvider.addCustomer(
                                    context: context,
                                    name: customerProvider.customerName.text,
                                    mobile: customerProvider.customerMobile.text,
                                    gst: customerProvider.customerGST.text,
                                    gstLocation: customerProvider.customerGSTLocation.text
                                  // addressLine1: customerStreet.text,
                                  // area: customerArea.text,
                                  // pincode: customerPincode.text,
                                  // city: customerCity.text,
                                  // state: customerState.text,
                                );
                              }

                            },
                            text: 'Save Customer', loadingButtonController: customerProvider.loadingButtonController,
                          ),
                        ],
                      ),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     //customerProvider.verifyGstNumber(customerProvider.customerGST.text);
                      //     // Example submission
                      //     print('Name: ${nameController.text}');
                      //     print('Mobile: ${mobileController.text}');
                      //     for (int i = 0; i < addressControllers.length; i++) {
                      //       print('Address ${i + 1}: ${addressControllers[i].text}');
                      //     }
                      //     Navigator.pop(context);
                      //   },
                      //   child: Text('Submit'),
                      // ),
                  ],
                  ),
                ),
              ),
              )
            );

        });
  }
}
