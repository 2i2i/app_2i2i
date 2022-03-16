import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/commons/theme.dart';
import 'faq.dart';
import 'keywords_list.dart';

class FAQPageBase extends StatefulWidget {
  FAQPageBase({
    Key? key,
    required this.title,
    required this.faqs,
    this.contactText = '',
    this.contactUrl = '',
    this.disclaimer = '',
  }) : super(key: key);
  final String title;
  final List<FAQData> faqs;
  final String contactText;
  final String contactUrl;
  final String disclaimer;
  @override
  _FAQPageBaseState createState() => _FAQPageBaseState();
}

class _FAQPageBaseState extends State<FAQPageBase> {

  TextEditingController _searchController = TextEditingController();

  List<FAQ> createFAQWidgets(List<FAQData> faqDataList) {
    List<FAQ> faqList = [];
    for (int i = 0; i < faqDataList.length; i++) {
      Color backgroundColor = i % 2 == 0
          ? Color.fromRGBO(223, 239, 223, 1)
          : Color.fromRGBO(197, 234, 197, 1);
      // Color backgroundColor = i % 2 == 0 ? Theme.of(context).colorScheme.secondary : Color.fromRGBO(197, 234, 197, 1);
      FAQ faq = FAQ(
        data: faqDataList[i],
        backgroundColor: backgroundColor,
        index: i,
      );
      faqList.add(faq);
    }
    return faqList;
  }

  @override
  Widget build(BuildContext context) {
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
              SizedBox(height: 8),
              ...createFAQWidgets(widget.faqs),
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
