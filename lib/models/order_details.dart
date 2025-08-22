class OrdersResponse {
  String? responseCode;
  String? message;
  List<OrderData>? ordersList;

  OrdersResponse({
    this.responseCode,
    this.message,
    this.ordersList,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) => OrdersResponse(
        responseCode: json["responseCode"],
        message: json["message"],
        ordersList: json["data"] == null
            ? []
            : List<OrderData>.from(
                json["data"]!.map((x) => OrderData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "responseCode": responseCode,
        "message": message,
        "data": ordersList == null
            ? []
            : List<dynamic>.from(ordersList!.map((x) => x.toJson())),
      };
}

class OrderData {
  String? id;
  String? uId;
  String? invoiceNo;
  String? oDate;
  String? pMethodId;
  String? address;
  String? landmark;
  String? dCharge;
  String? couId;
  String? couAmt;
  String? oTotal;
  String? subtotal;
  String? totSgst;
  String? totCgst;
  String? totIgst;
  String? transId;
  String? paymentActive;
  String? aNote;
  String? salesmanId;
  String? wallAmt;
  String? name;
  String? mobile;
  String? commentReject;
  String? tSlot;
  String? status;
  String? billType;
  String? bankTransId;
  String? upiId;
  String? reconStatus;
  String? createdBy;
  String? createdTs;
  String? productTitles;
  String? productOutPrice;
  String? productMrp;
  String? productQuantity;
  String? receivedAmt;
  String? payBackAmt;
  String? savings;
  String? productUnit;
  String? productLoose;

  OrderData(
      {this.id,
      this.uId,
      this.invoiceNo,
      this.oDate,
      this.pMethodId,
      this.address,
      this.landmark,
      this.dCharge,
      this.couId,
      this.couAmt,
      this.oTotal,
      this.subtotal,
      this.totSgst,
      this.totCgst,
      this.totIgst,
      this.transId,
      this.paymentActive,
      this.aNote,
      this.salesmanId,
      this.wallAmt,
      this.name,
      this.mobile,
      this.commentReject,
      this.tSlot,
      this.status,
      this.billType,
      this.bankTransId,
      this.upiId,
      this.reconStatus,
      this.createdBy,
      this.createdTs,
      this.productTitles,
      this.productOutPrice,
      this.productMrp,
      this.productQuantity,
      this.receivedAmt,
      this.payBackAmt,
      this.savings,
        this.productLoose,
      this.productUnit});

  factory OrderData.fromJson(Map<String, dynamic> json) => OrderData(
        id: json["id"]?.toString(),
        uId: json["u_id"]?.toString(),
        invoiceNo: json["invoice_no"]?.toString(),
        oDate: json["o_date"]?.toString(),
        pMethodId: json["p_method_id"]?.toString(),
        address: json["address"]?.toString(),
        landmark: json["landmark"]?.toString(),
        dCharge: json["d_charge"]?.toString(),
        couId: json["cou_id"]?.toString(),
        couAmt: json["cou_amt"]?.toString(),
        oTotal: json["o_total"]?.toString(),
        subtotal: json["subtotal"]?.toString(),
        totSgst: json["tot_sgst"]?.toString(),
        totCgst: json["tot_cgst"]?.toString(),
        totIgst: json["tot_igst"]?.toString(),
        transId: json["trans_id"]?.toString(),
        paymentActive: json["payment_active"]?.toString(),
        aNote: json["a_note"]?.toString(),
        salesmanId: json["salesman_id"]?.toString(),
        wallAmt: json["wall_amt"]?.toString(),
        name: json["name"]?.toString(),
        mobile: json["mobile"]?.toString(),
        commentReject: json["comment_reject"]?.toString(),
        tSlot: json["t_slot"]?.toString(),
        status: json["status"]?.toString(),
        billType: json["bill_type"]?.toString(),
        bankTransId: json["bank_trans_id"]?.toString(),
        upiId: json["upi_id"]?.toString(),
        reconStatus: json["recon_status"]?.toString(),
        createdBy: json["created_by"]?.toString(),
        createdTs: json["created_ts"]?.toString(),
        productTitles: json["product_titles"]?.toString(),
        productQuantity: json["product_quantity"]?.toString(),
        productMrp: json["product_mrp"]?.toString(),
        productOutPrice: json["product_out_price"]?.toString(),
        receivedAmt: json["received_amt"]?.toString(),
        payBackAmt: json["pay_back_amt"]?.toString(),
        savings: json["savings"]?.toString(),
        productUnit: json["product_unit"]?.toString(),
        productLoose: json["product_loose"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "u_id": uId,
        "invoice_no": invoiceNo,
        "o_date": oDate,
        "p_method_id": pMethodId,
        "address": address,
        "landmark": landmark,
        "d_charge": dCharge,
        "cou_id": couId,
        "cou_amt": couAmt,
        "o_total": oTotal,
        "subtotal": subtotal,
        "tot_sgst": totSgst,
        "tot_cgst": totCgst,
        "tot_igst": totIgst,
        "trans_id": transId,
        "payment_active": paymentActive,
        "a_note": aNote,
        "salesman_id": salesmanId,
        "wall_amt": wallAmt,
        "name": name,
        "mobile": mobile,
        "comment_reject": commentReject,
        "t_slot": tSlot,
        "status": status,
        "bill_type": billType,
        "bank_trans_id": bankTransId,
        "upi_id": upiId,
        "recon_status": reconStatus,
        "created_by": createdBy,
        "created_ts": createdTs,
        "product_titles": productTitles,
        "product_quantity": productQuantity,
        "product_mrp": productMrp,
        "product_out_price": productOutPrice,
        "received_amt": receivedAmt,
        "pay_back_amt": payBackAmt,
        "savings": savings,
        "product_unit": productUnit,
        "product_loose": productLoose
      };
}
