import 'package:app_2i2i/infrastructure/models/meeting_model.dart';

class HistoryViewModel {
  HistoryViewModel({required this.meetingListA,required this.meetingListB});

  List<Meeting?> meetingListA;
  List<Meeting?> meetingListB;
}
