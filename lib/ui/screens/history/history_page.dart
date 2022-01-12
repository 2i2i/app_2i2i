import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/commons/strings.dart';
import '../../../infrastructure/data_access_layer/repository/firestore_database.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../home/wait_page.dart';

class HistoryPage extends ConsumerStatefulWidget {
  final String uid;

  HistoryPage({required this.uid});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {


  @override
  Widget build(BuildContext context) {
    // final meetingList = ref.read(meetingHistoryProvider);
    // if (meetingList == null) {
    //   return WaitPage();
    // }
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings().meetingsHistory),
      ),
      body: StreamBuilder(
          stream: FirestoreDatabase().meetingHistoryA(widget.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data);
              List<Meeting?> meetingList = snapshot.data as List<Meeting?>;
              return ListView.builder(
                itemCount: meetingList.length,
                itemBuilder: (BuildContext context, int index) {
                  Meeting? meetingModel = meetingList[index];
                  final user = ref.watch(userProvider(meetingModel!.B));
                  if (user is AsyncError || user is AsyncLoading) {
                    return CircularProgressIndicator();
                  }
                  return Card(
                    child: ListTile(
                      leading: getCallTypeIcon(user.asData!.value),
                      title: Text(user.asData!.value.name),
                    ),
                  );
                },
              );
            }
            return WaitPage();
          }),
    );
  }

  Widget getCallTypeIcon(UserModel userModel) {
    if (userModel.id == widget.uid) {
      return Icon(Icons.call_received_rounded, color: AppTheme().red);
    }
    return Icon(Icons.call_made_rounded, color: AppTheme().green);
  }
}
