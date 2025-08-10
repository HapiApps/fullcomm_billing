import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_billing/data/local_data.dart';
import 'package:fullcomm_billing/data/project_data.dart';
import 'package:fullcomm_billing/models/billing_product.dart';
import 'package:fullcomm_billing/models/order_details.dart';
import 'package:fullcomm_billing/view_models/billing_provider.dart';
import '../../models/products_response.dart';
import '../../utils/text_formats.dart';
import '../../view_models/customer_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';

class BillPdf {
  // Pdf Widgets :
  pw.TextStyle billText = const pw.TextStyle(
    color: PdfColors.black,
    fontSize: 11,
  );

  pw.TextStyle billTextBold = pw.TextStyle(
      color: PdfColors.black, fontSize: 13, fontWeight: pw.FontWeight.bold);

  pw.TextStyle simpleText = const pw.TextStyle(
    color: PdfColors.black,
    fontSize: 10,
  );
  String _formatPayback(double received, double total) {
    double result = received - total;
    return result % 1 == 0
        ? result.toStringAsFixed(0) // no decimal if whole
        : result.toStringAsFixed(2); // keep 2 decimals
  }
  /// ------------- Print Bill ----------------
  Future<void> printBill(BuildContext context, {required int invoiceNo}) async {
    var pdfFontTheme = pw.ThemeData.withFont(
        base: Font.ttf(
            await rootBundle.load("assets/fonts/RedditSans-Regular.ttf")));

    if (!context.mounted) return;
    final billingProvider =
        Provider.of<BillingProvider>(context, listen: false);
    final customerProvider =
        Provider.of<CustomersProvider>(context, listen: false);

    final doc = pw.Document(
      theme: pdfFontTheme,
    );
    final pageFormat = PdfPageFormat(80 * PdfPageFormat.mm, double.infinity);
    var displayOTotal = billingProvider
        .calculatedGrandTotal()
        .toString()
        .replaceAll(RegExp(r"\.0$"), "");
    var displayReceived = billingProvider.paymentReceived.text == "0.0" ||
            billingProvider.paymentReceived.text == "0"
        ? displayOTotal
        : billingProvider.paymentReceived.text.replaceAll(RegExp(r"\.0$"), "");
    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.symmetric(horizontal: 2),
        build: (pw.Context context) {
          return pw.Container(
              width: double.infinity, // very important
              padding: const pw.EdgeInsets.all(8),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(ProjectData.billTitle,
                      style: const pw.TextStyle(
                        fontSize: 14,
                      ),
                      textAlign: pw.TextAlign.center),
                  pw.Text(ProjectData.billAddress,
                      style: const pw.TextStyle(fontSize: 10),
                      textAlign: pw.TextAlign.center),
                  pw.SizedBox(height: 10),
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                  'Counter : ${billingProvider.cashierNameController.text.isNotEmpty ? billingProvider.cashierNameController.text.trim() : localData.customerName}'
                                  // '${controller.counter ?? 'C1'}'
                                  '\n${DateFormat('dd-MM-yyyy h:mm a').format(DateTime.now())}',
                                  style: simpleText),
                              // pw.Text(
                              //     'Cust.Name: ${customerProvider.selectedCustomerName}',
                              //     style: simpleText),
                              // pw.Text(
                              //   'Cust. Address: ${customerProvider.customerAddressController.text.trim()}',
                              //   style: simpleText,
                              //   maxLines: 2,
                              // )
                            ]),
                        pw.Text('Bill No: $invoiceNo',
                            style: simpleText, textAlign: pw.TextAlign.right),
                      ]),
                  pw.Divider(
                    thickness: 1,
                    color: PdfColors.grey,
                  ),
                  // Product Table Header
                  pw.Table(
                    columnWidths: {
                      0: const pw.FixedColumnWidth(48), // Product Column
                      1: const pw.FixedColumnWidth(20), // Quantity Column
                      2: const pw.FixedColumnWidth(20), // MRP Column
                      3: const pw.FixedColumnWidth(25), // Rate Column
                      4: const pw.FixedColumnWidth(25), // Total Column
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Text('Product',
                              style: billText, textAlign: pw.TextAlign.left),
                          pw.Text('Qty',
                              style: billText, textAlign: pw.TextAlign.right),
                          pw.Text('MRP',
                              style: billText, textAlign: pw.TextAlign.right),
                          pw.Text('Rate',
                              style: billText, textAlign: pw.TextAlign.right),
                          pw.Text('Total',
                              style: billText, textAlign: pw.TextAlign.right),
                        ],
                      ),
                    ],
                  ),
                  pw.Divider(thickness: 1, color: PdfColors.grey),

                  // Product List
                  // pw.ListView.builder(
                  //   itemCount: billingProvider.billingItems.length,
                  //   direction: pw.Axis.vertical,
                  //   itemBuilder: (context, index) {
                  //     final billingItem = billingProvider.billingItems[index];
                  //
                  //     return pw.Table(
                  //       columnWidths: {
                  //         0: const pw.FixedColumnWidth(48),
                  //         1: const pw.FixedColumnWidth(20),
                  //         2: const pw.FixedColumnWidth(20),
                  //         3: const pw.FixedColumnWidth(25),
                  //         4: const pw.FixedColumnWidth(25),
                  //       },
                  //       children: [
                  //         pw.TableRow(
                  //           children: [
                  //             pw.Text(
                  //               billingItem.productTitle,
                  //               style: simpleText,
                  //               textAlign: pw.TextAlign.left,
                  //             ),
                  //             pw.Text(
                  //               billingItem.quantity.toString(),
                  //               style: simpleText,
                  //               textAlign: pw.TextAlign.right,
                  //             ),
                  //             pw.Text(
                  //               billingItem.mrpPerProduct().toStringAsFixed(1),
                  //               style: simpleText,
                  //               textAlign: pw.TextAlign.right,
                  //             ),
                  //             pw.Text(
                  //               billingItem.outPricePerProduct().toStringAsFixed(1),
                  //               style: simpleText,
                  //               textAlign: pw.TextAlign.right,
                  //             ),
                  //             pw.Text(
                  //               billingItem.calculateSubtotal().toStringAsFixed(1),
                  //               style: simpleText,
                  //               textAlign: pw.TextAlign.right,
                  //             ),
                  //           ],
                  //         ),
                  //       ],
                  //     );
                  //   },
                  // ),
                  ...billingProvider.billingItems.map((billingItem) {
                    return pw.Table(
                      columnWidths: {
                        0: const pw.FixedColumnWidth(48),
                        1: const pw.FixedColumnWidth(20),
                        2: const pw.FixedColumnWidth(20),
                        3: const pw.FixedColumnWidth(25),
                        4: const pw.FixedColumnWidth(25),
                      },
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Text(
                              "${billingItem.productTitle} ${billingItem.variationUnit}",
                              style: simpleText,
                              textAlign: pw.TextAlign.left,
                            ),
                            pw.Text(
                              billingItem.quantity.toString(),
                              style: simpleText,
                              textAlign: pw.TextAlign.right,
                            ),
                            pw.Text(
                              billingItem.mrpPerProduct().toStringAsFixed(1),
                              style: simpleText,
                              textAlign: pw.TextAlign.right,
                            ),
                            pw.Text(
                              billingItem
                                  .outPricePerProduct()
                                  .toStringAsFixed(1),
                              style: simpleText,
                              textAlign: pw.TextAlign.right,
                            ),
                            pw.Text(
                              billingItem
                                  .calculateSubtotal()
                                  .toStringAsFixed(1),
                              style: simpleText,
                              textAlign: pw.TextAlign.right,
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                  pw.Divider(
                    thickness: 1,
                    color: PdfColors.grey,
                  ),
                  pw.SizedBox(
                    width:
                        PdfPageFormat.roll80.availableWidth, // constrain width
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Items : ${billingProvider.calculatedTotalProducts()}',
                          style: simpleText,
                        ),
                        pw.Text(
                          'Qty : ${billingProvider.calculatedTotalQuantity()}',
                          style: simpleText,
                        ),
                        pw.Text(
                          'Grand Total : ₹${billingProvider.calculatedGrandTotal().toStringAsFixed(1)}',
                          style: billText,
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(
                    width:
                        PdfPageFormat.roll80.availableWidth, // constrain width
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Received : ${displayReceived == "null" || displayReceived == "" ? displayOTotal : displayReceived}',
                          style: simpleText,
                        ),
                        // pw.Text(
                        //   'Pay Back : ${(displayReceived.isEmpty) ? '0' : displayReceived == displayOTotal ? "0" : ((double.tryParse(displayReceived) ?? 0) - (double.tryParse(displayOTotal) ?? 0)).toString().replaceAll(RegExp(r"\.0$"), "")}',
                        //   style: simpleText,
                        // )
                        pw.Text(
                          'Pay Back : ${(displayReceived.isEmpty)
                              ? '0'
                              : displayReceived == displayOTotal
                              ? '0'
                              : _formatPayback(
                              double.tryParse(displayReceived) ?? 0,
                              double.tryParse(displayOTotal) ?? 0
                          )
                          }',
                          style: simpleText,
                        )

                      ],
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                        'Your Savings : ${billingProvider.calculateTotalDiscount()}',
                        style: billText),
                  ),
                  pw.Divider(
                    thickness: 1,
                    color: PdfColors.grey,
                  ),
                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Text(ProjectData.billFooter,
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.black,
                        ),
                        textAlign: pw.TextAlign.center),
                  ),
                  pw.Divider(
                    thickness: 1,
                    color: PdfColors.grey,
                  ),
                ],
              ));
        },
      ),
    );

    Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      usePrinterSettings: true,
      // format: PdfPageFormat.roll80,
    );
  }

  Future<void> printCustomBill(BuildContext context,
      {required OrderData data}) async {
    log("in invoice");
    List<BillingItem> billingItems = [];
    var products = data.productTitles.toString().split('||');
    var productQuantity = data.productQuantity.toString().split('||');
    var productMrp = data.productMrp.toString().split('||');
    var productOutPrice = data.productOutPrice.toString().split('||');
    var productUnit = data.productUnit.toString().split('||');
    var displayOTotal = data.oTotal.toString().replaceAll(RegExp(r"\.0$"), "");
    var displayReceived = data.receivedAmt.toString() == "0.0" ||
            data.receivedAmt.toString() == "0"
        ? data.oTotal.toString()
        : data.receivedAmt.toString().replaceAll(RegExp(r"\.0$"), "");
    print("displayOTotal $displayOTotal");
    print("received $displayReceived");
    for (var i = 0; i < products.length; i++) {
      billingItems.add(BillingItem(
          id: '',
          product: ProductData(),
          productTitle: products[i],
          variation: double.parse(productMrp[i]),
          variationUnit: productUnit[i],
          quantity: int.parse(productQuantity[i]),
          outPrice: productOutPrice[i]));
    }
    var pdfFontTheme = pw.ThemeData.withFont(
        base: Font.ttf(
            await rootBundle.load("assets/fonts/RedditSans-Regular.ttf")));

    if (!context.mounted) return;
    // final billingProvider = Provider.of<BillingProvider>(context, listen: false);

    final doc = pw.Document(
      theme: pdfFontTheme,
    );
    const pageFormat = PdfPageFormat(80 * PdfPageFormat.mm, double.infinity);
    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.symmetric(horizontal: 2),
        build: (pw.Context context) {
          return pw.Container(
              width: double.infinity, // very important
              padding: const pw.EdgeInsets.all(8),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(ProjectData.billTitle,
                      style: const pw.TextStyle(
                        fontSize: 14,
                      ),
                      textAlign: pw.TextAlign.center),
                  pw.Text(ProjectData.billAddress,
                      style: const pw.TextStyle(fontSize: 10),
                      textAlign: pw.TextAlign.center),
                  pw.SizedBox(height: 10),
                  pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                  'Counter : ${data.createdBy}'
                                  // '${controller.counter ?? 'C1'}'
                                  //'\n${DateFormat('dd-MM-yyyy h:mm a').format(DateTime.now())}',
                                  '\n${DateFormat('dd-MM-yyyy h:mm a').format(DateTime.parse(data.createdTs.toString()))}',
                                  style: simpleText),
                              // pw.Text(
                              //     'Cust.Name: ${customerProvider.selectedCustomerName}',
                              //     style: simpleText),
                              // pw.Text(
                              //   'Cust. Address: ${customerProvider.customerAddressController.text.trim()}',
                              //   style: simpleText,
                              //   maxLines: 2,
                              // )
                            ]),
                        pw.Text('Bill No: ${data.invoiceNo}',
                            style: simpleText, textAlign: pw.TextAlign.right),
                      ]),
                  pw.Divider(
                    thickness: 1,
                    color: PdfColors.grey,
                  ),
                  // Product Table Header
                  pw.Table(
                    columnWidths: {
                      0: const pw.FixedColumnWidth(48), // Product Column
                      1: const pw.FixedColumnWidth(20), // Quantity Column
                      2: const pw.FixedColumnWidth(20), // MRP Column
                      3: const pw.FixedColumnWidth(25), // Rate Column
                      4: const pw.FixedColumnWidth(25), // Total Column
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Text('Product',
                              style: billText, textAlign: pw.TextAlign.left),
                          pw.Text('Qty',
                              style: billText, textAlign: pw.TextAlign.right),
                          pw.Text('MRP',
                              style: billText, textAlign: pw.TextAlign.right),
                          pw.Text('Rate',
                              style: billText, textAlign: pw.TextAlign.right),
                          pw.Text('Total',
                              style: billText, textAlign: pw.TextAlign.right),
                        ],
                      ),
                    ],
                  ),
                  pw.Divider(thickness: 1, color: PdfColors.grey),

                  ...billingItems.map((billingItem) {
                    return pw.Table(
                      columnWidths: {
                        0: const pw.FixedColumnWidth(48),
                        1: const pw.FixedColumnWidth(20),
                        2: const pw.FixedColumnWidth(20),
                        3: const pw.FixedColumnWidth(25),
                        4: const pw.FixedColumnWidth(25),
                      },
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Text(
                              "${billingItem.productTitle} ${billingItem.variationUnit}",
                              style: simpleText,
                              textAlign: pw.TextAlign.left,
                            ),
                            pw.Text(
                              billingItem.quantity.toString(),
                              style: simpleText,
                              textAlign: pw.TextAlign.right,
                            ),
                            pw.Text(
                              billingItem.variation.toStringAsFixed(1),
                              style: simpleText,
                              textAlign: pw.TextAlign.right,
                            ),
                            pw.Text(
                              double.parse(billingItem.outPrice.toString())
                                  .toStringAsFixed(1),
                              style: simpleText,
                              textAlign: pw.TextAlign.right,
                            ),
                            pw.Text(
                              (billingItem.quantity *
                                      int.parse(
                                          billingItem.outPrice.toString()))
                                  .toStringAsFixed(1),
                              style: simpleText,
                              textAlign: pw.TextAlign.right,
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                  pw.Divider(
                    thickness: 1,
                    color: PdfColors.grey,
                  ),
                  pw.SizedBox(
                    width:
                        PdfPageFormat.roll80.availableWidth, // constrain width
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Items : ${billingItems.length}',
                          style: simpleText,
                        ),
                        pw.Text(
                          'Qty : ${billingItems.fold(0, (total, item) => total + item.quantity)}',
                          style: simpleText,
                        ),
                        pw.Text(
                          'Grand Total : ₹${double.parse(data.oTotal.toString()).toStringAsFixed(1)}',
                          style: simpleText,
                          textAlign: pw.TextAlign.right,
                        )
                      ],
                    ),
                  ),
                  pw.SizedBox(
                    width:
                        PdfPageFormat.roll80.availableWidth, // constrain width
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Received : ${displayReceived == "null" || displayReceived == "" ? data.oTotal : displayReceived}',
                          style: simpleText,
                        ),
                        // pw.Text(
                        //   'Pay Back : ${(displayReceived.isEmpty) || (displayReceived == "null") ? '0' : displayReceived == displayOTotal ? "0" : ((double.tryParse(displayReceived) ?? 0) - (double.tryParse(displayOTotal) ?? 0)).toString().replaceAll(RegExp(r"\.0$"), "")}',
                        //   style: simpleText,
                        // )
                        pw.Text(
                          'Pay Back : ${(displayReceived.isEmpty)
                              ? '0'
                              : displayReceived == displayOTotal
                              ? '0'
                              : _formatPayback(
                              double.tryParse(displayReceived) ?? 0,
                              double.tryParse(displayOTotal) ?? 0
                          )
                          }',
                          style: simpleText,
                        )

                      ],
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                        'Your Savings : ₹${data.savings.toString() == "null" || data.savings.toString() == "" ? "0.00" : double.parse(data.savings.toString()).toStringAsFixed(1)}',
                        style: billText),
                  ),
                  pw.Divider(
                    thickness: 1,
                    color: PdfColors.grey,
                  ),
                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Text(ProjectData.billFooter,
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.black,
                        ),
                        textAlign: pw.TextAlign.center),
                  ),
                  pw.Divider(
                    thickness: 1,
                    color: PdfColors.grey,
                  ),
                ],
              ));
        },
      ),
    );

    Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      usePrinterSettings: true,
      // format: PdfPageFormat.roll80,
    );
  }
}
