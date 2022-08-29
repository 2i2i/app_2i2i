import 'package:app_2i2i/ui/commons/custom_profile_image_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/commons/theme.dart';
import '../../../infrastructure/models/faq_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import 'faq.dart';
import 'faq_keywords_list_holder.dart';

class FAQScreenWeb extends ConsumerStatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends ConsumerState<FAQScreenWeb> {
  TextEditingController _searchController = TextEditingController();

  List<FAQDataModel> mainList = [];

  @override
  void initState() {
    super.initState();
    ref.read(faqProvider).initKeywordList();
  }

  @override
  Widget build(BuildContext context) {
    var fagProviderModel = ref.watch(faqProvider);
    if (fagProviderModel.searchFAQList.isNotEmpty || fagProviderModel.keywordList.isNotEmpty) {
      mainList = fagProviderModel.searchFAQList;
    } else {
      mainList = fagProviderModel.faqsList;
    }
    return Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: AppBar(
          centerTitle: false,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: Padding(
            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 33,),
            child: Text(
              Keys.faq.tr(context),
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          actions: [
            Row(
              children: [
                contact(),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 25,
                )
              ],
            ),
          ],
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 35),
            child: Column(
              children: [
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: AppTheme().cardDarkColor),
                        autofocus: false,
                        controller: _searchController,
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            fagProviderModel.addInKeywordList(value);
                            _searchController.text = '';
                            _searchController.clear();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: Keys.searchFaq.tr(context),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.text = '';
                                    _searchController.clear();
                                  },
                                  iconSize: 20,
                                  icon: Icon(
                                    Icons.close,
                                  ),
                                )
                              : IconButton(icon: Container(), onPressed: null),
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          prefixIcon: Icon(Icons.search_rounded),
                          // suffixIcon: Icon(Icons.mic),
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    RectangleBox(
                      radius: 42,
                      icon: Icon(fagProviderModel.isOpenSuggestionView ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 20),
                      curveRadius: 10,
                      onTap: () => fagProviderModel.openCloseSuggestionView(),
                    )
                  ],
                ),
                Expanded(
                  child: ListView(
                    children: [
                      SizedBox(height: 12),
                      FAQKeywordsListHolder(),
                      FaqListWidget(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget FaqListWidget() {
    if (mainList.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: mainList.length,
        itemBuilder: (BuildContext context, int index) {
          Color backgroundColor = index % 2 == 0 ? Color.fromRGBO(223, 239, 223, 1) : Color.fromRGBO(197, 234, 197, 1);
          return FAQWidget(
            data: mainList[index],
            backgroundColor: backgroundColor,
            index: index,
          );
        },
      );
    } else {
      return Container(child: Center(child: Text('No FAQ Found', style: Theme.of(context).textTheme.subtitle1)), height: MediaQuery.of(context).size.width);
    }
  }

  Widget contact() {
    return RichText(
        text: TextSpan(
      text: 'twitter',
      style: new TextStyle(color: Colors.blue),
      recognizer: new TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse('https://twitter.com/2i2i_app')),
    ),
    );
  }
}
