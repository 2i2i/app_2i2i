import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';

class RedeemCoinModel {
  String asaId;
  String? value;
  String? asaName;
  String? refDocumentId;

  RedeemCoinModel({required this.asaId, this.value, this.asaName, this.refDocumentId});

  RedeemCoinModel.fromJson({Map? json, String? documentId}) : asaId = '' {
    refDocumentId = documentId;
    if (json != null) {
      if (json['asaId'] != null) {
        asaId = json['asaId'];
      }
      if (json['value'] != null) {
        value = json['value'];
      }
    }
    log('RedeemCoinModel.fromMap - data == null');
    throw StateError('missing data for id: $documentId');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['asaId'] = this.asaId;
    data['value'] = this.value;
    data['asaName'] = this.asaName;
    return data;
  }
}
