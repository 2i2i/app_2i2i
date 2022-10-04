import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';

import '../../data_access_layer/repository/algorand_service.dart';
import '../../data_access_layer/services/logging.dart';
import '../../models/meeting_model.dart';
import '../../models/user_model.dart';

class RingingPageViewModel {
  RingingPageViewModel(
      {required this.user,
      required this.otherUser,
      required this.meeting,
      required this.algorand,
      required this.functions,
      required this.meetingChanger,
      required this.userChanger});

  final MeetingChanger meetingChanger;
  final UserModelChanger userChanger;
  final FirebaseFunctions functions;
  final AlgorandService algorand;
  final UserModel user;
  final UserModel otherUser;
  final Meeting meeting;

  bool amA() {
    final x = meeting.A == user.id;
    log('RingingPageViewModel - amA - x=$x');
    return x;
  }

  Future endMeeting(MeetingStatus reason) {
    log(J + 'RingingPageViewModel - endMeeting - reason=$reason');
    return meetingChanger.endMeeting(meeting, reason);
  }

  Future acceptMeeting() {
    if (meeting.status != MeetingStatus.ACCEPTED_B) return Future.value();
    return meetingChanger.acceptMeeting(meeting.id);
  }
}
