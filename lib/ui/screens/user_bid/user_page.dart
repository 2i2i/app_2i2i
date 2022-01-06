import 'dart:math';

import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/ui/commons/custom_profile_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/providers/all_providers.dart';
import '../../commons/custom_alert_widget.dart';
import '../home/wait_page.dart';
import 'other_bid_list.dart';
import 'widgets/create_bid_widget.dart';

class UserPage extends ConsumerStatefulWidget {
  UserPage({required this.uid});

  final String uid;

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends ConsumerState<UserPage> {


  @override
  Widget build(BuildContext context) {
    final userPageViewModel = ref.watch(userPageViewModelProvider(widget.uid));
    if (userPageViewModel == null ||
        userPageViewModel is AsyncError ||
        userPageViewModel is AsyncLoading) {
      return WaitPage();
    }

    var user = userPageViewModel.user;

    final shortBioStart = user.bio.indexOf(RegExp(r'\s')) + 1;
    int aPoint = shortBioStart + 10;
    int bPoint = user.bio.length;
    final shortBioEnd = min(aPoint, bPoint);
    final shortBio = user.bio.substring(shortBioStart, shortBioEnd);
    var statusColor = AppTheme().green;
    if (user.status == 'OFFLINE') {
      statusColor = AppTheme().gray;
    } else if (user.locked) {
      statusColor = AppTheme().red;
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz_rounded)),
          SizedBox(width: 6)
        ],
      ),
      floatingActionButton: InkResponse(
        onTap: () {
          CustomAlertWidget.showBidAlert(
            context,
            CreateBidWidget(
              uid: user.id,
            ),
          );
        },
        child: Container(
          width: kToolbarHeight * 1.15,
          height: kToolbarHeight * 1.15,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  offset: Offset(2, 2),
                  blurRadius: 8,
                  color: Theme.of(context)
                      .colorScheme
                      .secondary // changes position of shadow
              ),
            ],
          ),
          child: Icon(
            Icons.add_rounded,
            size: 30,
            color: Theme.of(context).primaryColorLight,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                TextProfileView(
                  text: "Ravi",
                  statusColor: Colors.green,
                  radius: 70,
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                      user.name,
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).disabledColor,
                          ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        shortBio.toString().trim(),
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
                              fontWeight: FontWeight.normal,
                              color: Theme.of(context).disabledColor,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: OtherBidInList(
                B: user,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ratingWidget(score, name, context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            0 <= score
                ? Icon(Icons.change_history, color: Colors.green)
                : Transform.rotate(
                    angle: pi,
                    child: Icon(Icons.change_history,
                        color: Color.fromRGBO(211, 91, 122, 1))),
            SizedBox(height: 4),
            Text(score.toString(), style: Theme.of(context).textTheme.caption)
          ],
        ),
        SizedBox(width: 10),
        Container(
          height: 40,
          width: 40,
          child: Center(
            child: Text(
              "${name.toString().isNotEmpty ? name : "X"}"
                  .substring(0, 1)
                  .toUpperCase(),
            ),
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromRGBO(214, 219, 134, 1),
          ),
        )
      ],
    );
  }
}
