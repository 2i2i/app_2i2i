import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

import '../../../../infrastructure/commons/utils.dart';
import '../../../../infrastructure/data_access_layer/accounts/abstract_account.dart';
import '../../../../infrastructure/data_access_layer/accounts/walletconnect_account.dart';
import '../../../../infrastructure/data_access_layer/services/logging.dart';
import '../../../../infrastructure/models/bid_model.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../commons/custom_stepper.dart';
import '../../app/wait_page.dart';
import '../../my_account/widgets/qr_image_widget.dart';

class WalletStatusInfo extends ConsumerStatefulWidget {
  final List<BidIn> bidIns;

  WalletStatusInfo({required this.bidIns});

  @override
  ConsumerState<WalletStatusInfo> createState() => _WalletStatusInfoState();
}

class _WalletStatusInfoState extends ConsumerState<WalletStatusInfo> {
  List<Map<String, dynamic>> titleList = [
    {'title': "Connect Wallet", 'isComplete': true, 'buttonText': 'Talk'},
    {'title': "Talk", 'isComplete': true, 'buttonText': 'Talk'},
  ];

  List<String> descriptionList = [
    "Bid is created now the next step is connect wallet account to pay amount from your wallet.\n\nYou will redirect to wallet application",
    "Bid is created now the next step is connect wallet account to pay amount from your wallet.\n\nYou will redirect to wallet application",
  ];

  String _displayUri = '';

  @override
  void initState() {
    ref.read(myAccountPageViewModelProvider).initMethod();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final walletStatusModel = ref.watch(walletStatusProvider);
    final myHangoutPageViewModel = ref.watch(myUserPageViewModelProvider);
    final myAccountPageViewProvider = ref.watch(myAccountPageViewModelProvider);
    if (haveToWait(myHangoutPageViewModel) || myHangoutPageViewModel?.user == null) {
      return WaitPage();
    }
    return Padding(
      padding: const EdgeInsets.all(20),
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
              isLoading: walletStatusModel.isLoading,
              curStep: walletStatusModel.cuntStep,
            ),
          ),
          SizedBox(height: kRadialReactionRadius),
          if (!(walletStatusModel.isLoading) && walletStatusModel.cuntStep < 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
                SizedBox(width: 8),
                TextButton(
                    onPressed: () async {
                      if (titleList[walletStatusModel.cuntStep]['isComplete']) {
                        walletStatusModel.updateCountStep(walletStatusModel.cuntStep + 1);
                      }
                      switch (walletStatusModel.cuntStep) {
                        case 1:
                          walletStatusModel.updateProgress(true);
                          String? address = await ref.read(myUserPageViewModelProvider)?.setFirst(widget.bidIns.first, context);
                          if (address?.isEmpty ?? true) {
                            String? address = await _createSession(myAccountPageViewProvider.accountService!);
                            titleList[1]['title'] = (address?.isNotEmpty ?? false) ? "Wallet connected" : "Wallet is not connected";
                            descriptionList[1] = (address?.isNotEmpty ?? false)
                                ? "Your Wallet is connected with application now you can talk with this user.\n\nPress Talk button to connect with this bidder."
                                : "Your Wallet is not connected with application now you can talk with this user without wallet";
                            titleList[1]['isComplete'] = address?.isNotEmpty ?? false;
                            walletStatusModel.updateAddress(address!);
                          } else {
                            titleList[1]['isComplete'] = true;
                            descriptionList[1] =
                                "Your Wallet is connected with application now you can talk with this user.\n\nPress Talk button to connect with this bidder.";
                            titleList[1]['title'] = "Wallet connected";
                          }
                          walletStatusModel.updateProgress(false);
                          break;
                        case 2:
                          descriptionList[2] = "Connecting with this user...";
                          titleList[2]['title'] = "Talk";
                          Future.delayed(Duration(seconds: 1)).then((value) {
                            Navigator.of(context).pop();
                          });

                          await myHangoutPageViewModel?.setThird(widget.bidIns, walletStatusModel.addressOfUserB!, context);
                          break;
                        case 3:
                          break;
                      }
                    },
                    child: Text((walletStatusModel.cuntStep > 1)
                        ? 'Talk'
                        : titleList[walletStatusModel.cuntStep]['isComplete']
                            ? titleList[walletStatusModel.cuntStep]['buttonText']
                            : 'Retry')),
              ],
            )
        ],
      ),
    );
  }

  Future<String?> _createSession(AccountService accountService) async {
    final myAccountPageViewModel = ref.read(myAccountPageViewModelProvider);
    String id = DateTime.now().toString();
    final connector = await WalletConnectAccount.newConnector(id);
    final account = WalletConnectAccount.fromNewConnector(
      accountService: accountService,
      connector: connector,
    );

    if (!account.connector.connected) {
      SessionStatus sessionStatus = await account.connector.connect(
        chainId: 4160,
        onDisplayUri: (uri) => _changeDisplayUri(uri),
      );

      if (sessionStatus.accounts.isNotEmpty) {
        log("$sessionStatus");
        await account.save(id);
        if (account.address.isNotEmpty) await myAccountPageViewModel.updateDBWithNewAccount(account.address, type: 'WC');
        await myAccountPageViewModel.updateAccounts();
        await account.setMainAccount();
        await myAccountPageViewModel.getWalletAccount();
        _displayUri = '';
      }
      return account.address;
    } else {
      log('_MyAccountPageState - _createSession - connector already connected');
      return null;
    }
  }

  Future _changeDisplayUri(String url) async {
    bool isAvailable = false;
    _displayUri = url;
    if (mounted) {
      setState(() {});
    }
    if (kIsWeb) {
      await showDialog(
        context: context,
        builder: (context) => QrImagePage(imageUrl: _displayUri),
        barrierDismissible: true,
      );
    } else {
      var launchUri;
      try {
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          final bridge = await getWCBridge();
          launchUri = Uri(
            scheme: 'algorand-wc',
            host: 'wc',
            queryParameters: {'uri': _displayUri, 'bridge': bridge}, //"https://wallet-connect-d.perawallet.app"},
          );
        } else {
          launchUri = Uri.parse(_displayUri);
        }
        isAvailable = await launchUrl(launchUri);
      } on PlatformException catch (err) {
        print(err);
      }
      if (!isAvailable) {
        await launchUrl(
            Uri.parse(Platform.isAndroid
                ? 'https://play.google.com/store/apps/details?id=com.algorand.android'
                : 'https://apps.apple.com/us/app/pera-algo-wallet/id1459898525'),
            mode: LaunchMode.externalApplication);
      }
    }
  }
}
