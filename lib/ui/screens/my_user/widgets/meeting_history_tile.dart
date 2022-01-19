import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/models/meeting_model.dart';
import '../../../../infrastructure/providers/all_providers.dart';

class MeetingHistoryTile extends ConsumerWidget {
  final GestureTapCallback? onTap;
  final String currentUid;
  final Meeting meetingModel;

  const MeetingHistoryTile(
      {Key? key, this.onTap,required this.currentUid,required this.meetingModel})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var statusColor = AppTheme().green;

    bool isBidIn = meetingModel.A != currentUid;

    final userModel = ref.watch(userProvider(isBidIn ? meetingModel.A : meetingModel.B)).value;
    if (userModel is AsyncError || userModel is AsyncLoading) {
      return CupertinoActivityIndicator();
    }

    if (userModel?.status == 'OFFLINE') {
      statusColor = AppTheme().gray;
    }
    if (userModel?.isInMeeting() ?? false) {
      statusColor = AppTheme().red;
    }
    String firstNameChar = userModel?.name ?? "";
    if (firstNameChar.isNotEmpty) {
      firstNameChar = firstNameChar.substring(0, 1);
    }

    return InkResponse(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              SizedBox(width: 4),
              SizedBox(
                height: 55,
                width: 55,
                child: Stack(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 0.3,
                              color: Theme.of(context).disabledColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              spreadRadius: 0.5,
                            )
                          ]),
                      alignment: Alignment.center,
                      child: Text(
                        firstNameChar,
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                            fontWeight: FontWeight.w600, fontSize: 20),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 2)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(userModel!.name,
                        maxLines: 2,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1!
                            .copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(
                      userModel.bio,
                      maxLines: 2,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.caption?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).shadowColor,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${(meetingModel.budget ?? 0)} Algo'.toUpperCase(),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).shadowColor,
                          fontSize: 20),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Settled',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.caption?.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              SvgPicture.asset(
                isBidIn ? 'assets/icons/income.svg' : 'assets/icons/upward.svg',
                height: 28,
                width: 28,
              ),
              SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
