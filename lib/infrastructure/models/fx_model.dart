class FXModel {
  DateTime? ts;
  double? value;

  FXModel({this.ts, this.value});

  FXModel.fromJson(Map<String, dynamic> json) {
    ts = json['ts']?.toDate();
    value = double.tryParse(json['value'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ts'] = this.ts;
    data['value'] = this.value;
    return data;
  }
}
