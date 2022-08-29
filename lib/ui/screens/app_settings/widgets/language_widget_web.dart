import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/providers/all_providers.dart';

class LanguagePageWeb extends ConsumerStatefulWidget {
  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends ConsumerState<LanguagePageWeb> {
  List languageList = [
    {'title': 'English', 'languageCode': 'en', 'countryCode': ''},
    {'title': '汉语', 'languageCode': 'zh', 'countryCode': ''},
    {'title': 'Español', 'languageCode': 'es', 'countryCode': ''},
    {'title': 'عَرَبِيّ', 'languageCode': 'ar', 'countryCode': ''},
    {'title': 'Deutsch', 'languageCode': 'de', 'countryCode': ''},
    {'title': '日本語', 'languageCode': 'ja', 'countryCode': ''},
    {'title': '한국어', 'languageCode': 'ko', 'countryCode': ''},
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appSettingModel = ref.watch(appSettingProvider);

    selectedIndex = languageList.indexWhere(
        (element) => Locale(element['languageCode']) == appSettingModel.locale);

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, ),
        child: ListView(
          primary: false,
          shrinkWrap: true,
          children: [
            Text(
              Keys.language.tr(context),
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(height: 30),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                  languageList.length,
                  (index) => Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: kToolbarHeight*2,),
                      Expanded(
                        child: Card(

                              child: ListTile(
                                onTap: () {
                                  selectedIndex = index;
                                  appSettingModel
                                      .setLocal(languageList[index]['languageCode']);
                                  setState(() {});
                                },
                                title: Text(languageList[index]['title']),
                                leading: IconButton(
                                    icon: (selectedIndex == index)
                                        ? Icon(
                                            Icons.done,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          )
                                        : Container(),
                                    onPressed: null),
                              ),
                            ),
                      ),
                      SizedBox(width: kToolbarHeight*2,),
                    ],
                  ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
