import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/commons/utils.dart';
import '../../../../infrastructure/models/bid_model.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../commons/custom_stepper.dart';
import '../../app/wait_page.dart';

class WalletStatusInfo extends ConsumerStatefulWidget {
  final List<BidIn> bidIns;

  WalletStatusInfo({required this.bidIns});

  @override
  ConsumerState<WalletStatusInfo> createState() => _WalletStatusInfoState();
}

class _WalletStatusInfoState extends ConsumerState<WalletStatusInfo> {
  List<String> titleList = [
    "Bid Created",
    "Connect Wallet",
    "Talk",
  ];

  List<String> descriptionList = [
    "Bid is created now the next step is connect wallet account to pay amount from your wallet.\n\nYou will redirect to wallet application",
    "Bid is created now the next step is connect wallet account to pay amount from your wallet.\n\nYou will redirect to wallet application",
    "Bid is created now the next step is connect wallet account to pay amount from your wallet.\n\nYou will redirect to wallet application",
  ];

  int curStep = 0;

  @override
  Widget build(BuildContext context) {
    final myHangoutPageViewModel = ref.watch(myUserPageViewModelProvider);
    if (haveToWait(myHangoutPageViewModel) || myHangoutPageViewModel?.user == null) {
      return WaitPage();
    }
    return Center(
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 26),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 80,
                height: 80,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: StepProgressView(
                  titles: titleList,
                  descriptionList: descriptionList,
                  curStep: curStep,
                ),
              ),
              SizedBox(height: kRadialReactionRadius),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
                  SizedBox(width: 8),
                  TextButton(
                      onPressed: () {
                        String? addressOfUserB;
                        this.setState(
                          () async {
                            if (curStep == 0) {
                              addressOfUserB = await myHangoutPageViewModel?.setFirst(widget.bidIns.first, context);
                              if (addressOfUserB?.isEmpty ?? true) {
                                addressOfUserB = await myHangoutPageViewModel?.setSecond(context);
                              }
                            } else if (curStep == 1) {
                              await myHangoutPageViewModel?.setThird(widget.bidIns, addressOfUserB!, context);
                            }
                            curStep++;
                          },
                        );
                      },
                      child: Text('Next')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
