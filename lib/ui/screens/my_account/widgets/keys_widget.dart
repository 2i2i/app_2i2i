import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../infrastructure/commons/strings.dart';
import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/data_access_layer/accounts/local_account.dart';
import '../../../commons/custom_dialogs.dart';

class KeysWidget extends StatelessWidget {
  final LocalAccount account;

  const KeysWidget({Key? key, required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).primaryColorLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14.0))),
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      content: Container(
        width: MediaQuery.of(context).size.height * 0.35,
        margin: EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 4),
            Text(
              'Please read carefully',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8),
            RichText(
              text: TextSpan(
                  text:
                      'Write down your recovery passphase(1-25 words). This is the',
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).disabledColor),
                  children: <TextSpan>[
                    TextSpan(
                      text: ' only way to recover your account in future.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2!
                          .copyWith(fontWeight: FontWeight.w500),
                    )
                  ]),
            ),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                  color: AppTheme().warningColor,
                  borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.all(14),
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
                        'Warning',
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme().redColor),
                      )
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Do not share these words with anyone, as it grants full access to your account',
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        fontWeight: FontWeight.normal,
                        color: AppTheme().redColor),
                  )
                ],
              ),
            ),
            SizedBox(height: 10),
            keyListWidget(context),
          ],
        ),
      ),
    );
  }

  Widget keyListWidget(BuildContext context) {
    return FutureBuilder(
      builder:
          (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          List perhaps = snapshot.data;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 5,
                padding: EdgeInsets.all(8),
                children:
                List.generate(perhaps.length, (index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                      Theme.of(context).primaryColor,
                      radius: 10,
                      child: Text(
                        '${index + 1}',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                    minLeadingWidth: 10,
                    title: Text(
                      '${perhaps[index]}',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  );
                }),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if(perhaps.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: perhaps.join(' ')));
                    CustomDialogs.showToastMessage(context, Strings().copyMessage);
                  }
                    Navigator.of(context,rootNavigator: true).pop();
                },
                child: Text('Copy and Done'),
                style: ElevatedButton.styleFrom(primary: Theme.of(context).shadowColor),
              )
            ],
          );
        }
        return WaitPage(
          height: MediaQuery.of(context).size.height / 2,
        );
      },
      future: account.mnemonic(),
    );
  }
}
