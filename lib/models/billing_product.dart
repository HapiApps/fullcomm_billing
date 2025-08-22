import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:fullcomm_billing/models/products_response.dart';

class BillingItem {
  String id;
  ProductData product;
  String productTitle;
  double variation;
  String variationUnit;
  int quantity;
  String sgst = '0';
  String? outPrice;
  TextEditingController proController;
  FocusNode proFocusNode;

  BillingItem({
    required this.id,
    required this.product,
    required this.productTitle,
    required this.variation,
    required this.variationUnit,
    required this.quantity,
    this.sgst = '0',
    this.outPrice,
    TextEditingController? proController,
    FocusNode? proFocusNode,
  })  : proController = proController ?? TextEditingController(),
        proFocusNode = proFocusNode ?? FocusNode();


  /// Calculate Mrp per product (for one product) :
  double mrpPerProduct() {
    if (product.isLoose == '1') {
      // Loose product:
      return (double.parse(product.mrp.toString()) /
              (double.parse(product.stockQty.toString()))) *
          variation;
    } else {
      // Regular product:
      return (double.parse(product.mrp.toString()));
    }
  }

  /// Calculate Mrp per product (for one product) :
  double outPricePerProduct() {
    if (product.isLoose == '1') {
      // Loose product:
      return (variation * double.parse(product.pricePerG));
      // return (double.parse(product.outPrice.toString())/(double.parse(product.stockQty.toString())/1000));
    } else {
      // Regular product:
      return (double.parse(product.outPrice.toString()));
    }
  }

  /// Calculate Out price per product (for one product) :
  double calculateOutPrice() {
    if (product.isLoose == '1') {
      // Loose product:
      //return (double.parse(product.pricePerG) * 1000);
      return double.parse(product.pricePerG);
      // return (double.parse(product.outPrice.toString())/(double.parse(product.stockQty.toString())/1000));
    } else {
      // Regular product:
      return (double.parse(product.outPrice.toString()));
    }
  }

  /// Calculate Subtotal :
  double calculateSubtotal() {
    if (product.isLoose == '1') {
      // Loose product: variation * pricePerGram (Variation is in gram)
      return (variation * double.parse(product.pricePerG));
    } else {

      return (double.parse(product.outPrice.toString()) * quantity);
    }
  }

  /// Calculate MRP Subtotal :
  double calculateMrpSubtotal() {
    if (product.isLoose == '1') {
      // Loose product: variation * pricePerGram (Variation is in gram)
      return (variation * double.parse(product.pricePerG));
    } else {
      // Regular product: price * quantity
      return (double.parse(product.mrp.toString()) * quantity);
    }
  }

  /// Calculates the Sub discount :
  double calculateDiscount() {
    if (product.isLoose == '1') {
      // For Loose Products:
      double mrpPerG = double.parse(product.mrp.toString()) /
          (double.parse(product.stockQty.toString()));
      double outPricePerG = double.parse(product.outPrice.toString()) /
          (double.parse(product.stockQty.toString()));
      log("calculateDiscount ${(variation * (mrpPerG - outPricePerG))}");
      return (variation * (mrpPerG - outPricePerG));
    } else {
      // For Singular Products:
      double mrp = double.parse(product.mrp.toString());
      double outPrice = double.parse(product.outPrice.toString());
      log("calculateDiscount ${((quantity * (mrp - outPrice)))}");
      return (quantity * (mrp - outPrice));
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_loose': product.isLoose.toString(),
      'batch_no': product.batchNo.toString(),
      'p_title': productTitle,
      'qty': product.isLoose == '0' ? quantity : int.parse(variation.toString()),
      'p_discount': (calculateMrpSubtotal() - calculateSubtotal()).toString(),
      'product_img': product.pImg.toString(),
      'out_price': calculateSubtotal().toString(),
      'unit': variationUnit.toString(),
      'product': product.toJson(),
      'productTitle': productTitle,
      'variation': variation,
      'variationUnit': product.isLoose == '0' ? variationUnit : variation,
      'quantity': quantity,
    };
  }
}

//class BillingItem {
//   String id;
//   ProductData product;
//   String productTitle;
//   double variation; // Grams for loose items
//   String variationUnit;
//   int quantity; // Quantity for non-loose items
//
//   BillingItem({
//     required this.id,
//     required this.product,
//     required this.productTitle,
//     required this.variation,
//     required this.variationUnit,
//     required this.quantity,
//   });
//
//   /// Calculate Subtotal :
//   double calculateSubtotal() {
//     if (product.isLoose == '1') {
//       // Loose product: variation * pricePerGram (Variation is in gram)
//       return (variation * double.parse(product.pricePerG));
//     } else {
//       // Regular product: price * quantity
//       return (double.parse(product.outPrice.toString()) * quantity);
//     }
//   }
//
//   /// Calculates the discount :
//   double calculateDiscount() {
//     if (product.isLoose == '1') {
//       // For Loose Products:
//       double mrpPerG = double.parse(product.mrp.toString()) / (double.parse(product.pVariation.toString()) * 1000);
//       double outPricePerG = double.parse(product.outPrice.toString()) / (double.parse(product.pVariation.toString()) * 1000);
//
//       return (variation * (mrpPerG - outPricePerG));
//     } else {
//       // For Singular Products:
//       double mrp = double.parse(product.mrp.toString());
//       double outPrice = double.parse(product.outPrice.toString());
//
//       return (quantity * (mrp - outPrice));
//     }
//   }
//
//   /// Convert BillingItem to JSON:
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'product': product.toJson(),
//       'productTitle': productTitle,
//       'variation': variation,
//       'variationUnit': variationUnit,
//       'quantity': quantity,
//     };
//   }
// }

///$product_id = $item['id'];
//         $qty = $item['is_loose']=='0' ? $item['qty'] : 0;
//         $batch_no = $item['batch_no'];
//         $product_title = $item['p_title'];
//         $p_discount = $item['p_discount'];
//         $product_img = $item['product_img'];
//         $out_price = $item['out_price'];
//         $p_type = $item['unit'];
//
//         $o_total = $item['o_total'];
//         $subtotal = $item['subtotal'];
