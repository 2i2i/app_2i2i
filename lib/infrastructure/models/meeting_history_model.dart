import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../commons/utils.dart';
import '../data_access_layer/repository/firestore_database.dart';
import 'meeting_model.dart';

class MeetingHistoryModel extends ChangeNotifier {
  FirestoreDatabase database;

  MeetingHistoryModel({required this.database});

  List<Meeting> aMeetingHistoryList = [];
  List<Meeting> bMeetingHistoryList = [];
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
        if (modelData.containsKey('meetingList') && modelData['meetingList'] != null && modelData['meetingList'].isNotEmpty) {
          if (meetingDataModel.userAorB == "A") {
            aMeetingHistoryList.addAll(modelData['meetingList']);
          } else {
            bMeetingHistoryList.addAll(modelData['meetingList']);
          }
        }
      } else {
        if (modelData.containsKey('meetingList') && modelData['meetingList'] != null && modelData['meetingList'].isNotEmpty) {
          if (meetingDataModel.userAorB == "A") {
            aMeetingHistoryList.clear();
          } else {
            bMeetingHistoryList.clear();
          }
          meetingDataModel.lastDocument = null;
          if (meetingDataModel.userAorB == "A") {
            aMeetingHistoryList = modelData['meetingList'];
          } else {
            bMeetingHistoryList = modelData['meetingList'];
          }
        }
      }
      await Future.delayed(Duration(seconds: 1));
    }
    isRequesting = false;
    notifyListeners();
  }

  onDisposeList() {
    aMeetingHistoryList.clear();
    bMeetingHistoryList.clear();
  }
}

class MeetingDataModel {
  int? page;
  String? uid;
  String? userAorB;
  DocumentSnapshot? lastDocument;

  MeetingDataModel({required this.page, required this.userAorB, required this.uid, this.lastDocument});
}
