import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../infrastructure/commons/keys.dart';
import '../../infrastructure/providers/all_providers.dart';

class CustomAlertWidget {
  static showBidAlert(BuildContext context, Widget child,
      {bool isDismissible = true, Color? backgroundColor}) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: backgroundColor ?? Theme.of(context).canvasColor,
      builder: (BuildContext context) => child,
      isDismissible: isDismissible,
    );
  }

  static Future showErrorDialog(BuildContext context,String errorMessage,{String? title, String? errorStacktrace}) async{
    Widget messageWidget = Text(errorMessage,textAlign: TextAlign.justify,);
    if(errorStacktrace?.isNotEmpty??false){
      messageWidget = Column(
        children: [
          SizedBox(height: 8),
          Text(errorMessage,textAlign: TextAlign.justify,),
          Container(
            decoration: BoxDecoration(
              color: Colors.red.shade200,
              borderRadius: BorderRadius.circular(12)
            ),
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.all(8),
              child: Text(errorStacktrace!,textAlign: TextAlign.justify,maxLines: 2,)
          ),
          SizedBox(height: 8),
        ],
      );
    }
    var dialog = CupertinoAlertDialog(
      title: Text(title??Keys.error.tr(context),style: TextStyle(
        color: Theme.of(context).errorColor,
      ),),
      content: messageWidget,
      actions: [
        TextButton(
          style: TextButton.styleFrom(
              primary: Theme.of(context).colorScheme.secondary),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          child: Text('Okay'),
        ),
      ],
    );
    return Future.delayed(Duration.zero).then((value) =>
        showCupertinoDialog(context: context, builder: (context) => dialog));
  }

  static void showHintWidget(
      BuildContext context, WidgetRef ref, List<GlobalObjectKey> keys) {
    Future.delayed(Duration(milliseconds: 500)).then((value) async {
      List<GlobalObjectKey> stringKey = [];
      for (var element in keys) {
        String id = element.value as String;
        bool showOnKey =
            await ref.read(appSettingProvider).checkIfHintShowed(id);
        if (showOnKey) {
          stringKey.add(element);
        }
      }
      if (stringKey.isNotEmpty) {
        ShowCaseWidget.of(context)!.startShowCase(stringKey);
      }
    });
  }
}
