import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/constants/strings.dart';
import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryPage extends ConsumerStatefulWidget {
  final String uid;

  HistoryPage({required this.uid});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    final meetingList = ref.read(meetingHistoryProvider);
    if (meetingList == null) {
      return WaitPage();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings().meetingsHistory),
      ),
      body: ListView.builder(
        itemCount: meetingList.meetingList.length,
        itemBuilder: (BuildContext context, int index) {
          Meeting? meetingModel = meetingList.meetingList[index];
          final user = ref.watch(userProvider(meetingModel!.B));
          if (user is AsyncError || user is AsyncLoading) {
            return CircularProgressIndicator();
          }
          return Card(
            child: ListTile(
              leading: getCallTypeIcon(user as UserModel),
              title: Text(user.data!.value.name),
            ),
          );
        },
      ),
    );
  }

  Widget getCallTypeIcon(UserModel userModel) {
    if (userModel.id == widget.uid) {
      return Icon(Icons.call_received_rounded, color: AppTheme().red);
    }
    return Icon(Icons.call_made_rounded, color: AppTheme().green);
  }
}
