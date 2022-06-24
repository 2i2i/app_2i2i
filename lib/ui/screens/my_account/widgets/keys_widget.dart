import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/data_access_layer/accounts/local_account.dart';
import '../../../commons/custom_dialogs.dart';

class KeysWidget extends StatelessWidget {
  final LocalAccount account;

  const KeysWidget({Key? key, required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14.0))),
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      content: Container(
        width: MediaQuery.of(context).size.height * 0.35,
        height: MediaQuery.of(context).size.width * 1.25,
        margin: EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            titleMessage(context),
            keyListWidget(context),
          ],
        ),
      ),
    );
  }

  Widget titleMessage(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 4),
        Text(
          Keys.pleaseReadCarefully.tr(context),
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 8),
        RichText(
          text: TextSpan(
              text: Keys.writeDownRecovery.tr(context),
              style: Theme.of(context).textTheme.bodyText2?.copyWith(
                    color: AppTheme().lightSecondaryTextColor,
                  ),
              children: <TextSpan>[
                TextSpan(
                  text: ' ${Keys.recoverAccount.tr(context)}',
                  style: Theme.of(context).textTheme.bodyText2,
                )
              ]),
        ),
        SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(color: AppTheme().warningColor, borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SvgPicture.asset(
                    'assets/icons/warning_red.svg',
                    color: AppTheme().redColor,
                    height: 18,
                    width: 18,
                  ),
                  SizedBox(width: 4),
                  Text(
                    Keys.warning.tr(context),
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                          color: AppTheme().redColor,
                        ),
                  )
                ],
              ),
              SizedBox(height: 8),
              Text(
                Keys.doNotShare.tr(context),
                style: Theme.of(context).textTheme.bodyText2?.copyWith(
                      color: AppTheme().redColor,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget keyListWidget(BuildContext context) {
    return Expanded(
      child: FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            List perhaps = snapshot.data;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 8),
                Expanded(
                  child: GridView.count(
                    shrinkWrap: true,
                    primary: false,
                    crossAxisCount: 2,
                    childAspectRatio: 4,
                    padding: EdgeInsets.all(8),
                    children: List.generate(perhaps.length, (index) {
                      return Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            radius: 10,
                            child: Text(
                              '${index + 1}',
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${perhaps[index]}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          )
                        ],
                      );
                    }),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                        child: Text(Keys.close.tr(context)),
                        style: ElevatedButton.styleFrom(primary: AppTheme().redColor),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (perhaps.isNotEmpty) {
                            Clipboard.setData(ClipboardData(text: perhaps.join(' ')));
                            CustomDialogs.showToastMessage(context, Keys.copyMessage.tr(context));
                          }
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: Text(Keys.copy.tr(context)),
                        style: ElevatedButton.styleFrom(primary: Theme.of(context).shadowColor),
                      ),
                    ),
                  ],
                )
              ],
            );
          }
          return WaitPage(
            height: MediaQuery.of(context).size.height / 2,
          );
        },
        future: account.mnemonic(),
      ),
    );
  }
}
