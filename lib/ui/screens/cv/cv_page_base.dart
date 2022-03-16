import 'package:app_2i2i/infrastructure/models/faq_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/commons/theme.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../faq/faq.dart';
import '../faq/keywords_list.dart';

class CVScreen extends ConsumerStatefulWidget {
  CVScreen({
    Key? key,
    required this.title,
    required this.faqs,
    this.contactText = '',
    this.contactUrl = '',
    this.disclaimer = '',
  }) : super(key: key);
  final String title;
  final List<FAQDataModel> faqs;
  final String contactText;
  final String contactUrl;
  final String disclaimer;

  @override
  _CVScreenState createState() => _CVScreenState();
}

class _CVScreenState extends ConsumerState<CVScreen> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var fagProviderModel = ref.watch(faqProvider);
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: ListView(
            children: [
              Container(
                // color: Colors.amber,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Spacer(),
                    contact(),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  style: TextStyle(color: AppTheme().cardDarkColor),
                  autofocus: false,
                  controller: _searchController,
                  onSubmitted: (value) {
                    fagProviderModel.addInKeywordList(value);
                    _searchController.text = '';
                    _searchController.clear();
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
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    prefixIcon: Icon(Icons.search_rounded),
                    // suffixIcon: Icon(Icons.mic),
                  ),
                ),
              ),
              SizedBox(height: 8),
              KeywordsList(),
              ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: widget.faqs.length,
                itemBuilder: (BuildContext context, int index) {
                  Color backgroundColor = index % 2 == 0
                      ? Color.fromRGBO(223, 239, 223, 1)
                      : Color.fromRGBO(197, 234, 197, 1);
                  return FAQWidget(
                    data: widget.faqs[index],
                    backgroundColor: backgroundColor,
                    index: index,
                  );
                },
              ),
              SizedBox(height: 20),
              Text(widget.disclaimer),
            ],
          ),
        ));
  }

  Widget contact() {
    return RichText(
        text: TextSpan(
          text: widget.contactText,
          style: new TextStyle(color: Colors.blue),
          recognizer: new TapGestureRecognizer()
            ..onTap = () => launch(widget.contactUrl),
        ));
  }
}
