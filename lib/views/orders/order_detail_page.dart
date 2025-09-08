import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_billing/utils/sized_box.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../data/project_data.dart';
import '../../res/colors.dart';
import '../../res/components/k_text.dart';
import '../../res/components/k_text_field.dart';
import '../../utils/input_formatters.dart';
import '../../utils/text_formats.dart';
import '../../view_models/billing_provider.dart';
import '../pdf/bill_pdf.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  void showDatePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final dateProvider =
            Provider.of<BillingProvider>(context, listen: false);
        dynamic selectedRange; // to store selected value temporarily

        return StatefulBuilder(
          // to update state inside dialog
          builder: (context, setState) {
            return AlertDialog(
              title: const MyText(
                text: '   Select Date',
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              content: SizedBox(
                height: 300,
                width: 300,
                child: SfDateRangePicker(
                  backgroundColor: const Color(0xffFFFCF9),
                  minDate: DateTime(2023),
                  maxDate: DateTime.now(),
                  selectionMode: DateRangePickerSelectionMode.range,
                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) {
                    setState(() {
                      selectedRange = args.value;
                    });
                  },
                ),
              ),
              actions: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText(
                      text: 'Click and drag to select multiple dates',
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: const MyText(
                        text: 'Cancel',
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const MyText(
                        text: 'OK',
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      onPressed: () {
                        if (selectedRange != null) {
                          dateProvider.changeDateFilter(" ");
                          dateProvider.setDateRange(selectedRange);
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      DateTime today = DateTime.now();
      DateTime tomorrow = today.add(const Duration(days: 1));
      String todayStr = DateFormat('yyyy-MM-dd').format(today);
      String tomorrowStr = DateFormat('yyyy-MM-dd').format(tomorrow);
      Provider.of<BillingProvider>(context, listen: false)
          .getAllOrderDetails(todayStr, tomorrowStr);
      final billingProvider =
          Provider.of<BillingProvider>(context, listen: false);
      billingProvider.searchName.clear();
      billingProvider.searchAmount.clear();
      billingProvider.searchProd.clear();
      billingProvider.setDateRange(null);
      billingProvider.changeDateFilter("Today");
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Consumer<BillingProvider>(builder: (context, billingProvider, _) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          ),
          centerTitle: true,
          title: const MyText(
            text: "Search Bill Details",
            color: AppColors.primary,
            isBold: true,
          ),
        ),
        body: Container(
          width: screenWidth,
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              5.height,
              Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: 'Last 30 Days',
                        groupValue: billingProvider.selectedDate,
                        onChanged: (value) {
                          billingProvider.changeDateFilter(value!);
                          DateTime today = DateTime.now();
                          DateTime end =
                              today.subtract(const Duration(days: 30));
                          String todayStr =
                              DateFormat('yyyy-MM-dd').format(today);
                          String endStr = DateFormat('yyyy-MM-dd').format(end);
                          billingProvider.getAllOrderDetails(endStr, todayStr);
                          billingProvider.setDateRange(null);
                        },
                      ),
                      const MyText(
                          text: 'Last 30 Days', color: AppColors.black),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: 'Last 7 Days',
                        groupValue: billingProvider.selectedDate,
                        onChanged: (value) {
                          billingProvider.changeDateFilter(value!);
                          DateTime today = DateTime.now();
                          DateTime end =
                              today.subtract(const Duration(days: 7));
                          String todayStr =
                              DateFormat('yyyy-MM-dd').format(today);
                          String endStr = DateFormat('yyyy-MM-dd').format(end);
                          billingProvider.getAllOrderDetails(endStr, todayStr);
                          billingProvider.setDateRange(null);
                        },
                      ),
                      const MyText(text: 'Last 7 Days', color: AppColors.black),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: 'Today',
                        groupValue: billingProvider.selectedDate,
                        onChanged: (value) {
                          billingProvider.changeDateFilter(value!);
                          DateTime today = DateTime.now();
                          DateTime tomorrow =
                              today.add(const Duration(days: 1));
                          String todayStr =
                              DateFormat('yyyy-MM-dd').format(today);
                          String tomorrowStr =
                              DateFormat('yyyy-MM-dd').format(tomorrow);
                          billingProvider.getAllOrderDetails(
                              todayStr, tomorrowStr);
                          billingProvider.setDateRange(null);
                        },
                      ),
                      const MyText(text: 'Today', color: AppColors.black),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      showDatePickerDialog(context);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MyText(
                          text: 'Select Date',
                          color: Color(0xff9E9E9E),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        Container(
                          width: 210,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              billingProvider.stDate.isEmpty
                                  ? const SizedBox()
                                  : MyText(
                                      text: billingProvider.stDate ==
                                              billingProvider.enDate
                                          ? billingProvider
                                              .stDate // same date => show only once
                                          : "${billingProvider.stDate} to ${billingProvider.enDate}", // different dates
                                      fontSize: 13,
                                      color: Colors.black,
                                    ),
                              const SizedBox(width: 5),
                              const Icon(Icons.calendar_today,
                                  color: Colors.grey, size: 17),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MyText(
                        text: 'Customer Name',
                        color: Color(0xff9E9E9E),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      MyTextField(
                        labelText: 'Customer Name',
                        width: 210,
                        isOptional: true,
                        height: 40,
                        controller: billingProvider.searchName,
                        keyboardType: TextInputType.text,
                        autofocus: true,

                        // 🔑 allow only letters and spaces
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z\s]')),
                        ],

                        textInputAction: TextInputAction.next,
                        focusedBorderColor: AppColors.primary,
                        enabledBorderColor: Colors.grey.shade300,
                        borderRadius: 5,
                        onChanged: (value) {
                          billingProvider.setSearchQuery(name: value);
                        },
                        suffixIcon: IconButton(
                          onPressed: () {
                            billingProvider.searchName.clear();
                            billingProvider.setSearchQuery(name: "");
                          },
                          icon: const Icon(
                            Icons.clear,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MyText(
                        text: 'Amount',
                        color: Color(0xff9E9E9E),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      MyTextField(
                        labelText: 'Amount',
                        isOptional: true,
                        width: 210,
                        height: 40,
                        controller: billingProvider.searchAmount,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        focusedBorderColor: AppColors.primary,
                        enabledBorderColor: Colors.grey.shade300,
                        borderRadius: 5,
                        onChanged: (value) {
                          billingProvider.setSearchQuery(total: value);
                        },
                        suffixIcon: IconButton(
                            onPressed: () {
                              billingProvider.searchAmount.clear();
                              billingProvider.setSearchQuery(total: "");
                            },
                            icon: const Icon(
                              Icons.clear,
                              size: 14,
                            )),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MyText(
                        text: 'Product Name',
                        color: Color(0xff9E9E9E),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      MyTextField(
                        labelText: 'Product Name',
                        isOptional: true,
                        width: 210,
                        height: 40,
                        controller: billingProvider.searchProd,
                        keyboardType: TextInputType.text,
                        autofocus: true,
                        focusedBorderColor: AppColors.primary,
                        enabledBorderColor: Colors.grey.shade300,
                        borderRadius: 5,
                        textInputAction: TextInputAction.next,
                        onChanged: (value) {
                          billingProvider.setSearchQuery(product: value);
                        },
                        suffixIcon: IconButton(
                            onPressed: () {
                              billingProvider.searchProd.clear();
                              billingProvider.setSearchQuery(product: "");
                            },
                            icon: const Icon(
                              Icons.clear,
                              size: 14,
                            )),
                      ),
                    ],
                  ),
                ],
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     IconButton(onPressed: (){
              //       Navigator.pop(context);
              //     }, icon: const Icon(Icons.arrow_back_ios,color: AppColors.primary,)),
              //     Radio<String>(
              //       value: 'Last 30 Days',
              //       groupValue: billingProvider.selectedDate,
              //       onChanged: (value) {
              //         billingProvider.changeDateFilter(value!);
              //         DateTime today = DateTime.now();
              //         DateTime end = today.subtract(const Duration(days: 30));
              //         String todayStr = DateFormat('yyyy-MM-dd').format(today);
              //         String endStr = DateFormat('yyyy-MM-dd').format(end);
              //         billingProvider.getAllOrderDetails(endStr, todayStr);
              //       },
              //     ),
              //     const MyText(text: 'Last 30 Days',color: AppColors.black,),
              //     Radio<String>(
              //       value: 'Last 7 Days',
              //       groupValue: billingProvider.selectedDate,
              //       onChanged: (value){
              //         billingProvider.changeDateFilter(value!);
              //         DateTime today = DateTime.now();
              //         DateTime tomorrow = today.subtract(const Duration(days: 7));
              //         String todayStr = DateFormat('yyyy-MM-dd').format(today);
              //         String tomorrowStr = DateFormat('yyyy-MM-dd').format(tomorrow);
              //         billingProvider.getAllOrderDetails(tomorrowStr, todayStr);
              //       },
              //     ),
              //     const MyText(text: 'Last 7 Days',color: AppColors.black,),
              //     Radio<String>(
              //       value: 'Today',
              //       groupValue: billingProvider.selectedDate,
              //       onChanged: (value){
              //         billingProvider.changeDateFilter(value!);
              //         DateTime today = DateTime.now();
              //         DateTime tomorrow = today.add(const Duration(days: 1));
              //         String todayStr = DateFormat('yyyy-MM-dd').format(today);
              //         String tomorrowStr = DateFormat('yyyy-MM-dd').format(tomorrow);
              //         billingProvider.getAllOrderDetails(todayStr,tomorrowStr);
              //       },
              //     ),
              //     const MyText(text: 'Today',color: AppColors.black,),
              //     InkWell(
              //       onTap:(){
              //         showDatePickerDialog(context);
              //       },
              //       child: Container(
              //         width: 210,
              //         height: 30,
              //         decoration: BoxDecoration(
              //             color: Colors.white,
              //             borderRadius: BorderRadius.circular(20),
              //             border: Border.all(
              //                 color: Colors.grey.shade400
              //             )
              //         ),
              //         child:Row(
              //           mainAxisAlignment: MainAxisAlignment.end,
              //           children:[
              //             billingProvider.stDate.isEmpty?0.width:MyText(
              //               text:"${billingProvider.stDate} to ${billingProvider.enDate} ",
              //               fontSize: 13,
              //               color: Colors.black,
              //             ),
              //             5.width,
              //             const Icon(Icons.calendar_today,color:Colors.grey,size: 17,),10.width,
              //           ],
              //         ),
              //       ),
              //     ),
              //     MyTextField(
              //       labelText: 'Customer Name',
              //       width: 200,
              //       height: 40,
              //       controller: billingProvider.searchName,
              //       keyboardType: TextInputType.text,
              //       autofocus: true,
              //       textInputAction: TextInputAction.next,
              //       onChanged: (value){
              //         billingProvider.setSearchQuery(name: value);
              //       },
              //       //inputFormatters: InputFormatters.mobileNumberInput,
              //     ),
              //     MyTextField(
              //       labelText: 'Amount',
              //       width: 200,
              //       height: 40,
              //       controller: billingProvider.searchAmount,
              //       keyboardType: TextInputType.number,
              //       autofocus: true,
              //       textInputAction: TextInputAction.next,
              //       onChanged: (value){
              //         billingProvider.setSearchQuery(total: value);
              //       },
              //       //inputFormatters: InputFormatters.mobileNumberInput,
              //     ),
              //     MyTextField(
              //       labelText: 'Product Name',
              //       width: 200,
              //       height: 40,
              //       controller: billingProvider.searchProd,
              //       keyboardType: TextInputType.text,
              //       autofocus: true,
              //       textInputAction: TextInputAction.next,
              //       onChanged: (value){
              //         billingProvider.setSearchQuery(product: value);
              //       },
              //       //inputFormatters: InputFormatters.mobileNumberInput,
              //     ),
              //   ],
              // ),
              // Row(
              //   // mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //
              //     MyTextField(
              //       width: screenWidth/1.2,
              //       controller: billingProvider.search,
              //       labelText: 'Search Name or Amount Or Products Or Date (${DateTime.now().day.toString().padLeft(2,"0")}-${DateTime.now().month.toString().padLeft(2,"0")}-${DateTime.now().year})',
              //       textInputAction: TextInputAction.done,
              //       onChanged: (value)  {
              //         billingProvider.searchOrders(value.toString());
              //       },
              //     ),
              //   ],
              // ),

              billingProvider.isRefresh == false
                  ? Column(
                      children: [
                        200.height,
                        const Center(child: CircularProgressIndicator()),
                      ],
                    )
                  : billingProvider.allOrders.isEmpty
                      ? Column(
                          children: [
                            350.height,
                            const MyText(
                              text: "Not Found",
                              color: Colors.grey,
                              fontSize: 20,
                            )
                          ],
                        )
                      : Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      minWidth:
                                          MediaQuery.of(context).size.width),
                                  child: DataTable(
                                    showCheckboxColumn: false,
                                    headingRowColor: WidgetStateProperty.all(
                                        Colors.grey.shade200),
                                    columnSpacing: 30,
                                    columns: const [
                                      DataColumn(
                                          label: Text('Date',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Bill No',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Name',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Mobile Number',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Bill Amount',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DataColumn(
                                          label: Text('Actions',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                    ],
                                    rows: billingProvider.allOrders
                                        .where((data) => data.invoiceNo != "0")
                                        .map((data) {
                                      var products = data.productTitles
                                          .toString()
                                          .split('||');
                                      var productsUnit = data.productUnit
                                          .toString()
                                          .split('||');
                                      return DataRow(
                                        onSelectChanged: (selected) {
                                          if (products.isNotEmpty &&
                                              products[0] != "null") {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const MyText(
                                                  text: "Products",
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                content: SizedBox(
                                                  width: 300,
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: products.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      print(
                                                          "Unit: ${productsUnit[index]}");
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4),
                                                        child: Text(
                                                            "${products[index]} ${productsUnit[index]}",
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black)),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        side: BorderSide(
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                      ),
                                                    ),
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text("Close"),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        },
                                        cells: [
                                          DataCell(Text(
                                              billingProvider.formatDate(
                                                  data.oDate.toString()))),
                                          DataCell(
                                              Text(data.invoiceNo.toString())),
                                          DataCell(Text(
                                              data.name.toString() == "Cash"
                                                  ? "-"
                                                  : data.name.toString())),
                                          DataCell(Text(
                                              data.name.toString() == "Cash"
                                                  ? "-"
                                                  : data.mobile.toString())),
                                          DataCell(SizedBox(
                                            //color : Colors.red,
                                            width: 80,
                                            child: MyText(
                                              text: TextFormat.formattedAmount(
                                                double.parse(
                                                    data.oTotal.toString()),
                                              ),
                                              textAlign: TextAlign.end,
                                            ),
                                          )),
                                          DataCell(Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              // GestureDetector(
                                              //   child: const Icon(
                                              //       Icons
                                              //           .shopping_cart_outlined,
                                              //       color: Colors.grey),
                                              //   onTap: () {
                                              //     if (products.isNotEmpty &&
                                              //         products[0] != "null") {
                                              //       showDialog(
                                              //         context: context,
                                              //         builder: (context) =>
                                              //             AlertDialog(
                                              //           title: const Text(
                                              //               "Products"),
                                              //           content: SizedBox(
                                              //             width: 300,
                                              //             child:
                                              //                 ListView.builder(
                                              //               shrinkWrap: true,
                                              //               itemCount:
                                              //                   products.length,
                                              //               itemBuilder:
                                              //                   (context,
                                              //                       index) {
                                              //                 return Padding(
                                              //                   padding:
                                              //                       const EdgeInsets
                                              //                           .symmetric(
                                              //                           vertical:
                                              //                               4),
                                              //                   child: Text(
                                              //                       "${products[index]} ${productsUnit[index]}",
                                              //                       style: const TextStyle(
                                              //                           color: Colors
                                              //                               .grey)),
                                              //                 );
                                              //               },
                                              //             ),
                                              //           ),
                                              //           actions: [
                                              //             ElevatedButton(
                                              //               style:
                                              //                   ElevatedButton
                                              //                       .styleFrom(
                                              //                 backgroundColor:
                                              //                     Colors.white,
                                              //                 shape:
                                              //                     RoundedRectangleBorder(
                                              //                   borderRadius:
                                              //                       BorderRadius
                                              //                           .circular(
                                              //                               5),
                                              //                   side:
                                              //                       BorderSide(
                                              //                     color: AppColors
                                              //                         .primary,
                                              //                   ),
                                              //                 ),
                                              //               ),
                                              //               onPressed: () =>
                                              //                   Navigator.pop(
                                              //                       context),
                                              //               child: const Text(
                                              //                   "Close"),
                                              //             ),
                                              //           ],
                                              //         ),
                                              //       );
                                              //     }
                                              //   },
                                              // ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.primary,
                                                  shape: const StadiumBorder(),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                ),
                                                onPressed: () async {
                                                  final BillPdf pdfService =
                                                      BillPdf();
                                                  await pdfService
                                                      .printCustomBill(context,
                                                          data: data);
                                                },
                                                child: const Text("Print",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12)),
                                              ),
                                            ],
                                          )),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

              // Column(
              //   children: [
              //     Padding(
              //       padding: const EdgeInsets.fromLTRB(35, 10, 35, 0),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           const MyText(text: "Bill No",fontWeight: FontWeight.bold,fontSize: 16,),
              //           const MyText(text: "Name",fontWeight: FontWeight.bold,fontSize: 16,),
              //           const MyText(text: "Bill Amount",fontWeight: FontWeight.bold,fontSize: 16,),
              //           const MyText(text: "Date",fontWeight: FontWeight.bold,fontSize: 16,),
              //           ElevatedButton(
              //               style: ElevatedButton.styleFrom(
              //                   backgroundColor: AppColors.transparent,
              //                   elevation: 0.0
              //               ),
              //               onPressed:(){}, child: const MyText(text: "",color: Colors.white,))
              //         ],
              //       ),
              //     ),
              //     Expanded(
              //       child: ListView.builder(
              //           itemCount: billingProvider.allOrders.length,
              //           itemBuilder: (context, index) {
              //             final sortedData = billingProvider.allOrders;
              //             final data = sortedData[index];
              //             var products=data.productTitles.toString().split('||');
              //             return Column(
              //               children: [
              //                 Padding(
              //                   padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              //                   child: InkWell(
              //                     onTap:(){
              //                       if(products[0].toString()!="null"){
              //                         showDialog(
              //                           context: context,
              //                           builder: (context) {
              //                             return AlertDialog(
              //                               title: const Text("Products"),
              //                               content: SizedBox(
              //                                 width: 300,
              //                                 child: ListView.builder(
              //                                   shrinkWrap: true,
              //                                   itemCount: products.length,
              //                                   itemBuilder: (context, index) {
              //                                     return Padding(
              //                                       padding: const EdgeInsets.only(top: 5),
              //                                       child: Row(
              //                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                                         children: [
              //                                           Text(
              //                                             products[index],
              //                                             style: const TextStyle(color: Colors.grey),
              //                                           ),
              //                                         ],
              //                                       ),
              //                                     );
              //                                   },
              //                                 ),
              //                               ),
              //                               actions: [
              //                                 TextButton(
              //                                   onPressed: () => Navigator.pop(context),
              //                                   child: const Text("Close"),
              //                                 ),
              //                               ],
              //                             );
              //                           },
              //                         );
              //                       }
              //             },
              //                     child: Container(
              //                       decoration: BoxDecoration(
              //                           color: Colors.white,
              //                           border: Border.all(
              //                             color: AppColors.primary.withOpacity(0.2),
              //                           ),
              //                           borderRadius: BorderRadius.circular(10)
              //                       ),
              //                       child: Padding(
              //                         padding: const EdgeInsets.all(15),
              //                         child: Column(
              //                           children: [
              //                             Row(
              //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                               children: [
              //                                 MyText(text: data.invoiceNo.toString(),fontWeight: FontWeight.bold,fontSize: 15,),
              //                                 MyText(text: data.name.toString()=="Cash"?"-":data.name.toString()),
              //                                 MyText(text: data.oTotal.toString()),
              //                                 MyText(text: billingProvider.formatDate(data.oDate.toString())),
              //                                 ElevatedButton(
              //                                   style: ElevatedButton.styleFrom(
              //                                     backgroundColor: AppColors.primary,
              //                                     shape: const StadiumBorder()
              //                                   ),
              //                                     onPressed: () async {
              //                                       final BillPdf pdfService = BillPdf();
              //                                       await pdfService.printCustomBill(
              //                                           context,
              //                                           data: data);
              //                                 }, child: const MyText(text: "Print Bill",color: Colors.white,))
              //                               ],
              //                             ),
              //                             // Row(
              //                             //   children: [
              //                             //     IconButton(
              //                             //       onPressed: (){
              //                             //
              //                             //       },
              //                             //         icon: Icon(Icons.arrow_circle_right_outlined,
              //                             //           color: AppColors.primary,)),
              //                             //   ],
              //                             // ),
              //
              //                           ],
              //                         ),
              //                       ),
              //                     ),
              //                   ),
              //                 ),
              //                 if(index==billingProvider.allOrders.length-1)
              //                   50.height
              //               ],
              //             );
              //             // :0.width;
              //           }),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      );
    });
  }
}
