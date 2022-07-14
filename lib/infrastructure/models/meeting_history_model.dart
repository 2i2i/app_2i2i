import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../commons/utils.dart';
import '../data_access_layer/repository/firestore_database.dart';
import 'meeting_model.dart';

class MeetingHistoryModel extends ChangeNotifier {
  FirestoreDatabase database;

  MeetingHistoryModel({required this.database});

  List<Meeting> meetingHistoryList = [];
  DocumentSnapshot? lastDocument;

  bool? isRequesting;

  Future<void> getMeetingHistoryList(MeetingDataModel meetingDataModel) async {
    isRequesting = true;
    notifyListeners();

    var meetingHistoryData = database.meetingHistory(meetingDataModel: meetingDataModel);
    if (!haveToWait(meetingHistoryData)) {
      Map modelData = await meetingHistoryData.first;
      if (modelData.containsKey('docList') && modelData['docList'] != null) {
        List<DocumentSnapshot> docList = modelData['docList'];
        if (docList.isNotEmpty) lastDocument = docList[docList.length - 1];
      }
      if (meetingDataModel.lastDocument != null) {
        if (modelData.containsKey('meetingList') && modelData['meetingList'] != null && modelData['meetingList'].isNotEmpty)
          meetingHistoryList.addAll(modelData['meetingList']);
      } else {
        if (modelData.containsKey('meetingList') && modelData['meetingList'] != null && modelData['meetingList'].isNotEmpty) {
          meetingHistoryList.clear();
          meetingDataModel.lastDocument = null;
          meetingHistoryList = modelData['meetingList'];
        }
      }
      await Future.delayed(Duration(seconds: 1));
    }
    isRequesting = false;
    notifyListeners();
  }

  onDisposeList() {
    meetingHistoryList.clear();
  }
}

class MeetingDataModel {
  int? page;
  String? uId;
  String? userAorB;
  DocumentSnapshot? lastDocument;

  MeetingDataModel({required this.page, required this.userAorB, required this.uId, this.lastDocument});

  MeetingDataModel.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    uId = json['uId'];
    userAorB = json['userAorB'];
    lastDocument = json['lastDocument'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['page'] = this.page;
    data['uId'] = this.uId;
    data['userAorB'] = this.userAorB;
    data['lastDocument'] = this.lastDocument;
    return data;
  }
}
