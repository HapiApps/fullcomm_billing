

class StateObj {
  int id;
  String name;
  String short;
  String code;

  StateObj({
    required this.id,
    required this.name,
    required this.short,
    required this.code,
  });

  factory StateObj.fromJson(Map<String, dynamic> json) => StateObj(
    id: json["id"],
    name: json["name"],
    short: json["short"],
    code: json["code"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "short": short,
    "code": code,
  };
}
