import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'meeting_history.dart';
import 'meeting_history_web.dart';

class MeetingHistoryHolder extends ConsumerStatefulWidget {
  @override
  _MeetingHistoryHolderState createState() => _MeetingHistoryHolderState();
}

class _MeetingHistoryHolderState extends ConsumerState<MeetingHistoryHolder> {

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => MeetingHistory(),
      tablet: (BuildContext context) => MeetingHistory(),
      desktop: (BuildContext context) => MeetingHistoryWeb(),
    );
  }
}
