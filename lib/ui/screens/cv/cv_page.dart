import 'package:app_2i2i/ui/screens/cv/cv_page_data.dart';
import 'package:app_2i2i/ui/screens/cv/success.dart';
import 'package:app_2i2i/ui/screens/faq/faq_page_base.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:intl/intl.dart';
import '../faq/faq.dart';

class CVPage extends StatelessWidget {
  CVPage({Key? key, required this.person}) : super(key: key) {
    successes = person == CVPerson.imi
        ? CVPageData.imiSuccesses
        : CVPageData.solliSuccesses;
    successes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  late final List<SuccessData> successes;
  // late final List<FAQData> faqs;
  final CVPerson person;

  @override
  Widget build(BuildContext context) {
    final faqs = successes
        .map((e) => FAQData(
            title: e.title,
            descriptionTextSpan: TextSpan(
              children: [
                TextSpan(
                  text: 'timestamp: ',
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                TextSpan(
                  style: new TextStyle(color: Colors.blue),
                  recognizer: new TapGestureRecognizer()
                    ..onTap = () {
                      final dt = new DateTime.fromMillisecondsSinceEpoch(
                          e.timestamp * 1000);
                      final DateFormat formatter = DateFormat('yyyy-MM-dd');
                      final String formatted = formatter.format(dt);
                      showToast(
                        formatted.toString(),
                        context: context,
                        position: StyledToastPosition.top,
                      );
                    },
                  text: e.timestamp.toString(),
                ),
                TextSpan(
                  text: '\n\n${e.description}',
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ],
            )))
        .toList();

    return FAQPageBase(
      title: person.toStringEnum(),
      faqs: faqs,
      contactText: 'twitter',
      contactUrl: person == CVPerson.imi
          ? 'https://twitter.com/2i2i_app'
          : 'https://twitter.com/2i2i_solli',
      disclaimer:
          'All timestamps above are approximate. All facts above are the persons\' successes, without humility and without exageration. Weaknesses/"failures" are not mentioned.',
    );
  }
}
