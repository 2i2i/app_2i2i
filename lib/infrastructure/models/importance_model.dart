class ImportanceModel {
  int? lurker;
  int? chrony;
  int? highroller;
  int? eccentric;

  ImportanceModel({this.lurker, this.chrony, this.highroller, this.eccentric});

  ImportanceModel.fromJson(Map<String, dynamic> json) {
    lurker = json['lurker'];
    chrony = json['chrony'];
    highroller = json['highroller'];
    eccentric = json['eccentric'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lurker'] = this.lurker;
    data['chrony'] = this.chrony;
    data['highroller'] = this.highroller;
    data['eccentric'] = this.eccentric;
    return data;
  }
}
