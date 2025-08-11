class CustomersResponse {
  final String responseCode;
  final String message;
  final List<Customer> data;

  CustomersResponse({
    required this.responseCode,
    required this.message,
    required this.data,
  });

  factory CustomersResponse.fromJson(Map<String, dynamic> json) {
    return CustomersResponse(
      responseCode: json['responseCode'],
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => Customer.fromJson(item))
          .toList(),
    );
  }
}

class Customer {
  final String? userId;
  final String? name;
  final String? mobile;
  final String? emailId;
  final String? password;
  final String? whatsapp;
  final String? rDate;
  final String? cCode;
  final String? code;
  final String? referCode;
  final String? wallet;
  final List<AddressDetail>? addressDetails;

  Customer({
    this.userId,
    this.name,
    this.mobile,
    this.emailId,
    this.password,
    this.whatsapp,
    this.rDate,
    this.cCode,
    this.code,
    this.referCode,
    this.wallet,
    this.addressDetails,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      userId: json['user_id'],
      name: json['name'],
      mobile: json['mobile'],
      emailId: json['email_id'],
      password: json['password'],
      whatsapp: json['whatsapp'],
      rDate: json['r_date'],
      cCode: json['c_code'],
      code: json['code'],
      referCode: json['refer_code'],
      wallet: json['wallet'],
      addressDetails: (json['address_details'] as List)
          .map((item) => AddressDetail.fromJson(item))
          .toList(),
    );
  }
}

class AddressDetail {
  final String? addressId;
  final String? area;
  final String? pincode;
  final String? addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String? type;
  final String? lat;
  final String? lng;
  final String? name;
  final String? mobile;
  final String? city;
  final String? state;
  final String? country;
  final String? tier;

  AddressDetail({
    this.addressId,
    this.area,
    this.pincode,
    this.addressLine1,
    this.addressLine2,
    this.landmark,
    this.type,
    this.lat,
    this.lng,
    this.name,
    this.mobile,
    this.city,
    this.state,
    this.country,
    this.tier,
  });

  factory AddressDetail.fromJson(Map<String, dynamic> json) {
    return AddressDetail(
      addressId: json['address_id'],
      area: json['area'],
      pincode: json['pincode'],
      addressLine1: json['address_line_1'],
      addressLine2: json['address_line_2'],
      landmark: json['landmark'],
      type: json['type'],
      lat: json['lat'].toString(),
      lng: json['lng'].toString(),
      name: json['name'],
      mobile: json['mobile'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      tier: json['tier'],
    );
  }
}

