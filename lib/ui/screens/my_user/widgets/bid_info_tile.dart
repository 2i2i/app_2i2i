import 'package:flutter/material.dart';

import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/models/user_model.dart';

class BidInfoTile extends StatelessWidget {
  final GestureTapCallback? onTap;
  final UserModel? userModel;
  final String? bidSpeed;

  const BidInfoTile({Key? key, this.onTap, this.userModel, this.bidSpeed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var statusColor = AppTheme().green;
    if (userModel?.status == 'OFFLINE') {
      statusColor = AppTheme().gray;
    }
    if (userModel!.isInMeeting()) {
      statusColor = AppTheme().red;
    }
    String firstNameChar = userModel!.name;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      userModel!.name,
                      maxLines: 2,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      userModel!.bio,
                      maxLines: 2,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.caption?.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: bidSpeed,
                  children: [
                    TextSpan(
                      text: ' μAlgo/s',
                      children: [],
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1!
                          .copyWith(color: Theme.of(context).shadowColor),
                    )
                  ],
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                      color: Theme.of(context).shadowColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
              // Text(bid.speed.num.toString() + ' μAlgo/s'),
              SizedBox(width: 8),
              Image.asset(
                'assets/algo_logo.png',
                height: 34,
                width: 34,
              ),
              SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
