import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/providers/all_providers.dart';

class LanguagePage extends ConsumerStatefulWidget {
  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends ConsumerState<LanguagePage> {
  List languageList = [
    {'title': 'English', 'languageCode': 'en', 'countryCode': ''},
    {'title': 'Chinese', 'languageCode': 'zh', 'countryCode': ''},
    {'title': 'Spanish', 'languageCode': 'es', 'countryCode': ''},
    {'title': 'Arabic', 'languageCode': 'ar', 'countryCode': ''},
    {'title': 'German', 'languageCode': 'de', 'countryCode': ''},
    {'title': 'Korean', 'languageCode': 'ko', 'countryCode': ''},
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appSettingModel = ref.watch(appSettingProvider);

    selectedIndex = languageList.indexWhere(
        (element) => Locale(element['languageCode']) == appSettingModel.locale);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: ListView(
          primary: false,
          shrinkWrap: true,
          children: [
            Text(
              Keys.language.tr(context),
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(height: 20),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                  languageList.length,
                  (index) => Card(
                        child: ListTile(
                          onTap: () {
                            selectedIndex = index;
                            appSettingModel
                                .setLocal(languageList[index]['languageCode']);
                            setState(() {});
                          },
                          title: Text(languageList[index]['title']),
                          trailing: IconButton(
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
                      )),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
