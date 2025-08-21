// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
//
// import '../../res/colors.dart';
// import '../../utils/text_formats.dart';
//
// class OldScreen extends StatelessWidget {
//   const OldScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return DataTable(
//       dividerThickness: 0,
//       showBottomBorder: false,
//       dataRowHeight: 50,
//       headingRowHeight: 50,
//       horizontalMargin: 0,
//       // Height for header row
//       border: const TableBorder(
//         verticalInside:
//             BorderSide(
//                 width: 1,
//                 color: Color(0xff9E9E9E)),
//         top: BorderSide.none,
//         bottom: BorderSide.none,
//         horizontalInside: BorderSide.none,
//       ), // Column lines
//       headingRowColor: MaterialStateProperty.resolveWith(
//         (states) => Color(0xff0078D7), // Header background
//       ),
//       columns: [
//         DataColumn(
//           headingRowAlignment: MainAxisAlignment.center,
//           label: Text(
//               "Change\nName",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                   color: Colors.white)),
//         ),
//         DataColumn(
//           headingRowAlignment: MainAxisAlignment.center,
//           label: SizedBox(
//             height: 50,
//             child: Center(
//                 child: MyText(
//                     text:
//                         "S.No",
//                     color: Colors
//                         .white)),
//           ),
//         ),
//         DataColumn(
//           headingRowAlignment:
//               MainAxisAlignment
//                   .center,
//           label: SizedBox(
//             height: 50,
//             child: Center(
//                 child: MyText(
//                     text:
//                         "Product",
//                     color: Colors
//                         .white)),
//           ),
//         ),
//         DataColumn(
//           headingRowAlignment:
//               MainAxisAlignment
//                   .center,
//           label: SizedBox(
//             height: 50,
//             child: Center(
//                 child: MyText(
//                     text:
//                         "Variation",
//                     color: Colors
//                         .white)),
//           ),
//         ),
//         DataColumn(
//           headingRowAlignment:
//               MainAxisAlignment
//                   .center,
//           label: SizedBox(
//             height: 50,
//             child: Center(
//                 child: MyText(
//                     text:
//                         "Quantity",
//                     color: Colors
//                         .white)),
//           ),
//         ),
//         DataColumn(
//           headingRowAlignment:
//           MainAxisAlignment
//               .center,
//           label: SizedBox(
//             height: 50,
//             child: Center(
//                 child: MyText(
//                     text:
//                     "GST",
//                     color: Colors
//                         .white)),
//           ),
//         ),
//         DataColumn(
//           headingRowAlignment:
//               MainAxisAlignment
//                   .center,
//           label: SizedBox(
//             height: 50,
//             child: Center(
//                 child: MyText(
//                     text:
//                         "MRP",
//                     color: Colors
//                         .white)),
//           ),
//         ),
//         DataColumn(
//           headingRowAlignment:
//               MainAxisAlignment
//                   .center,
//           label: SizedBox(
//             height: 50,
//             child: Center(
//                 child: MyText(
//                     text:
//                         "Our Price",
//                     color: Colors
//                         .white)),
//           ),
//         ),
//         DataColumn(
//           headingRowAlignment:
//               MainAxisAlignment
//                   .center,
//           label: SizedBox(
//             height: 50,
//             child: Center(
//                 child: MyText(
//                     text:
//                         "Discount",
//                     color: Colors
//                         .white)),
//           ),
//         ),
//         DataColumn(
//           headingRowAlignment:
//               MainAxisAlignment
//                   .center,
//           label: SizedBox(
//             height: 50,
//             child: Center(
//                 child: MyText(
//                     text:
//                         "SubTotal",
//                     color: Colors
//                         .white)),
//           ),
//         ),
//         DataColumn(
//           headingRowAlignment:
//               MainAxisAlignment
//                   .center,
//           label: SizedBox(
//             height: 50,
//             child: Center(
//                 child: MyText(
//                     text:
//                         "Remove",
//                     color: Colors
//                         .white)),
//           ),
//         ),
//       ],
//       rows: List.generate(
//           billingProvider.billingItems.length,
//               (index) {
//             final billProduct = billingProvider.billingItems[index];
//             return DataRow(
//               color: MaterialStateProperty
//                   .resolveWith(
//                     (states) => index %
//                     2 ==
//                     0
//                     ? Colors.white
//                     : const Color(0xffD9EEFF),
//               ),
//               cells: [
//                 DataCell(
//                   Center(
//                     child: IconButton(
//                       icon:SvgPicture.asset("assets/images/edit.svg",width: 20,height: 20,),
//                       tooltip:
//                       'Edit Product Name',
//                       onPressed: () {
//                         if(billProduct.product.pTitle.toString().isNotEmpty){
//                           WidgetsBinding.instance.addPostFrameCallback((_) {
//                             setState(() {
//                               billProduct.proController.clear();
//                               billProduct.proFocusNode.requestFocus();
//                               customerProvider.showInputDialog(
//                                 context: context,
//                                 width: screenWidth * 0.20,
//                                 height: screenHeight * 0.07,
//                                 controller: billProduct.proController,
//                                 focus: billProduct.proFocusNode,
//                                 onChanged: () {
//                                   setState(() {
//                                     final text = billProduct.proController.text;
//                                     if (text.isNotEmpty) {
//                                       billProduct.product.pTitle = "${billProduct.productTitle}/$text";
//                                       Navigator.of(context).pop();
//                                     } else {
//                                       Toasts.showToastBar(
//                                         context: context,
//                                         text: 'Please Fill Product Name',
//                                       );
//                                     }
//                                   });
//                                 },
//                                 onSubmitted: (_) {
//                                   final text = billProduct.proController.text;
//                                   if (text.isNotEmpty) {
//                                     billProduct.product.pTitle = "${billProduct.productTitle}/$text";
//                                   }
//                                   Navigator.pop(context);
//                                 },
//                               );
//                             });
//
//                           });
//
//                         }else{
//                           Toasts.showToastBar(
//                               context: context,
//                               text: 'Please Select Product Name');
//                         }
//                         // Your existing edit logic here
//                       },
//                     ),
//                   ),
//                 ),
//                 DataCell(
//                     Center(
//                     child: Text(
//                       "${index + 1}",
//                       textAlign:
//                       TextAlign
//                           .center,
//                     ))
//                 ),
//                 DataCell(
//                     Center(
//                   child: Text(
//                     billProduct.product
//                         .isLoose ==
//                         '1'
//                         ? "${billProduct.product.pTitle}"
//                         : "${billProduct.product.pTitle} ${billProduct.product.pVariation ?? ""}${billProduct.product.unit ?? ""}",
//                     textAlign:
//                     TextAlign
//                         .center,
//                   ),
//                 )
//                 ),
//                 DataCell(
//                   // billProduct.product.isLoose == '1'
//                   //     ? SizedBox(
//                   //         height: 40,
//                   //         child: TextFormField(
//                   //           controller: TextEditingController(
//                   //             text: "${billProduct.variation / 1000}",
//                   //           ),
//                   //           keyboardType: TextInputType.numberWithOptions(decimal: true),
//                   //           onChanged: (value) {
//                   //             // optional: validation / preview only
//                   //           },
//                   //           textAlign: TextAlign.center,
//                   //           decoration: const InputDecoration(
//                   //             border: InputBorder.none, // Removes underline
//                   //             isDense: true, // Reduces padding
//                   //             contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                   //           ),
//                   //           onFieldSubmitted: (value) {
//                   //             final parsed = double.tryParse(value);
//                   //             if (parsed != null && parsed > 0) {
//                   //               billingProvider.updateBillingItem(
//                   //                 index,
//                   //                 isLoose: '1',
//                   //                 variation: parsed * 1000, // store in grams
//                   //               );
//                   //             } else {
//                   //               Toasts.showToastBar(
//                   //                 context: context,
//                   //                 text: 'Please enter valid weight',
//                   //               );
//                   //             }
//                   //           },
//                   //         ),
//                   //         // child: TextFormField(
//                   //         //   controller: TextEditingController(
//                   //         //     text: "${billProduct.variation / 1000}",
//                   //         //   ),
//                   //         //   onChanged: (value) {
//                   //         //     billingProvider.updateBillingItem(
//                   //         //       index,
//                   //         //       isLoose: '1',
//                   //         //       variation: double.tryParse(value) ?? billProduct.variation * 1000,
//                   //         //     );
//                   //         //   },
//                   //         // ),
//                   //       ):
//                   billProduct.product.isLoose == '1'?Center(
//                       child: Text(
//                         billProduct.variationUnit,
//                       )):Center(
//                       child: Text(
//                         billProduct.variationUnit ?? "",
//                       )),
//                 ),
//                 DataCell(
//                     billProduct.product.isLoose == '0'
//                         ? SizedBox(
//                       height:
//                       40,
//                       child:
//                       TextFormField(
//                         controller: billingProvider.quantityControllers[index] ??
//                             TextEditingController(
//                               text: "${billProduct.quantity}",
//                             ),
//                         decoration: const InputDecoration(
//                           border: InputBorder.none,
//                           isDense: true,
//                           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                         ),
//                         textAlign: TextAlign.center,
//                         keyboardType: TextInputType.number,
//                         inputFormatters: [
//                           LengthLimitingTextInputFormatter(5), // Limit to 5 digits
//                         ],
//                         onChanged: (value) {
//                           if (value.isNotEmpty) {
//                             //   int stockQty = int.parse(billingProvider.selectedProduct!.stockQty.toString());
//                             //   int enteredQty = int.tryParse(value) ?? billProduct.quantity;
//                             //   if (enteredQty > stockQty) {
//                             //     Toasts.showToastBar(
//                             //       context: context,
//                             //       text: "Entered quantity is more than the available stock ($stockQty).",
//                             //       color: Colors.red,
//                             //     );
//                             //   }else{
//                             billingProvider.updateBillingItem(
//                               index,
//                               isLoose: '0',
//                               quantity: int.tryParse(value) ?? billProduct.quantity,
//                             );
//                             // }
//                           } else {
//
//                             // billingProvider.updateBillingItem(
//                             //   index,
//                             //   isLoose: '0',
//                             //   quantity: 1,
//                             // );
//                           }
//                         },
//                       ),
//                     ):SizedBox(
//                       height: 40,
//                       child: TextFormField(
//                         controller: TextEditingController(
//                           text: "${billProduct.variation / 1000}",
//                         ),
//                         keyboardType: TextInputType.numberWithOptions(decimal: true),
//                         onChanged: (value) {
//                           // optional: validation / preview only
//                         },
//                         textAlign: TextAlign.center,
//                         decoration: const InputDecoration(
//                           border: InputBorder.none, // Removes underline
//                           isDense: true, // Reduces padding
//                           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                         ),
//                         onFieldSubmitted: (value) {
//                           final parsed = double.tryParse(value);
//                           if (parsed != null && parsed > 0) {
//                             billingProvider.updateBillingItem(
//                               index,
//                               isLoose: '1',
//                               variation: parsed * 1000, // store in grams
//                             );
//                           } else {
//                             Toasts.showToastBar(
//                               context: context,
//                               text: 'Please enter valid weight',
//                             );
//                           }
//                         },
//                       ),
//                       // child: TextFormField(
//                       //   controller: TextEditingController(
//                       //     text: "${billProduct.variation / 1000}",
//                       //   ),
//                       //   onChanged: (value) {
//                       //     billingProvider.updateBillingItem(
//                       //       index,
//                       //       isLoose: '1',
//                       //       variation: double.tryParse(value) ?? billProduct.variation * 1000,
//                       //     );
//                       //   },
//                       // ),
//                     )
//                   //   : Align(
//                   // alignment: Alignment.center,
//                   //     child: Text(
//                   //         "${billProduct.quantity}"),
//                   //   ),
//                 ),
//                 DataCell(
//                   Align(
//                     alignment: Alignment.center,
//                     child: Text("${billProduct.sgst}%"),
//                   ),
//                 ),
//
//                 // DataCell(
//                 //      Align(
//                 //        alignment: Alignment.center,
//                 //        child: Text(
//                 //            "${billProduct.sgst}%"),
//                 //      ),
//                 // ),
//                 DataCell(Align(
//                   alignment: Alignment
//                       .centerRight,
//                   child: Text(
//                     TextFormat.formattedAmount(
//                         billProduct
//                             .mrpPerProduct()),
//                     textAlign: TextAlign.end,
//                   ),
//                 )),
//                 DataCell(Align(
//                   alignment: Alignment.centerRight,
//                   child: Text(TextFormat
//                       .formattedAmount(
//                       billProduct
//                           .calculateOutPrice())),
//                 )),
//                 DataCell(Align(
//                   alignment: Alignment
//                       .centerRight,
//                   child: Text(billProduct
//                       .calculateDiscount()
//                       .toStringAsFixed(
//                       2)),
//                 )),
//                 DataCell(Align(
//                   alignment: Alignment
//                       .centerRight,
//                   child: Text(
//                       TextFormat
//                           .formattedAmount(
//                         billProduct
//                             .calculateSubtotal(),
//                       )),
//                 )),
//                 DataCell(
//                   Center(
//                     child:
//                     IconButton(
//                       tooltip: 'Delete ${billProduct.product.isLoose == '1'
//                           ? "${billProduct.product.pTitle} ${billProduct.variation/1000}kg"
//                           : "${billProduct.product.pTitle} ${billProduct.variationUnit}"}',
//                       icon: SvgPicture.asset("assets/images/delete.svg",width: 20,height: 20,),
//                       // onPressed: () =>
//                       //     billingProvider.removeBillingItem(
//                       //         index:
//                       //             index),
//                       onPressed: () {
//                         String itemName = billProduct.product.isLoose == '1'
//                             ? "${billProduct.product.pTitle} ${billProduct.variation / 1000}kg"
//                             : "${billProduct.product.pTitle} ${billProduct.variationUnit}";
//
//                         showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return AlertDialog(
//                               backgroundColor: Colors.white,
//                               contentPadding:
//                               const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               content: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Are you sure you want to delete $itemName?",
//                                     style: const TextStyle(
//                                       fontSize: 17,
//                                       fontWeight: FontWeight.bold,
//                                       color: AppColors.primary,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 20),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: [
//                                       ElevatedButton(
//                                         onPressed: () {
//                                           Navigator.pop(context);
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: Colors.grey.shade200,
//                                           side: BorderSide(color: AppColors.secondary),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(5),
//                                           ),
//                                         ),
//                                         child: const Text(
//                                           "No",
//                                           style: TextStyle(
//                                             color: AppColors.primary,
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(width: 10),
//                                       ElevatedButton(
//                                         onPressed: () {
//                                           billingProvider.removeBillingItem(index: index);
//                                           Navigator.pop(context);
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: AppColors.primary,
//                                           side: BorderSide(color: AppColors.secondary),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(5),
//                                           ),
//                                         ),
//                                         child: const Text(
//                                           "Yes",
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           }),
//     );
//   }
// }
