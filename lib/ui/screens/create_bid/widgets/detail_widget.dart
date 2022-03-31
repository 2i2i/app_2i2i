import 'package:flutter/material.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/models/user_model.dart';
import '../../../commons/custom_text_field.dart';

class DetailWidget extends StatefulWidget {
  final UserModel userB;

  const DetailWidget({Key? key, required this.userB}) : super(key: key);

  @override
  State<DetailWidget> createState() => _DetailWidgetState();
}

class _DetailWidgetState extends State<DetailWidget> {
  int maxDuration = 300;
  int maxMaxDuration = 300;
  int minMaxDuration = 10;

  PageController _controller =
      PageController(initialPage: 0, viewportFraction: 1 / 5, keepPage: true);
  int selectedScoreIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 18),
          RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
                style: Theme.of(context).textTheme.caption?.copyWith(height: 1.5),
                children: [
                  TextSpan(
                      style: Theme.of(context).textTheme.subtitle2,
                      text: 'Max Duration:\n'),
                  TextSpan(text: 'Pick Time Upto '),
                  TextSpan(
                      style: TextStyle(color: Theme.of(context).errorColor),
                      text: '5mins'),
                ]),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TimeBox(
                  text: "10",
                ),
                Text(':', style: Theme.of(context).textTheme.headline6),
                TimeBox(
                  text: "10",
                ),
                Text(':', style: Theme.of(context).textTheme.headline6),
                TimeBox(
                  text: "10",
                ),
                Text('=', style: Theme.of(context).textTheme.headline6),
                TimeBox(
                  text: "10 mints",
                  width: kToolbarHeight * 1.25,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
                style: Theme.of(context).textTheme.caption?.copyWith(height: 1.5),
                children: [
                  TextSpan(
                      style: Theme.of(context).textTheme.subtitle2,
                      text: 'Support:\n'),
                  TextSpan(text: 'Wait time is 5mins. Add support for wait less in queue'),
                ]),
          ),
          SizedBox(height: 4),
          Container(
            height: kToolbarHeight * 2,
            child: PageView.builder(
              itemCount: 106,
              physics: AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              onPageChanged: (index) {
                selectedScoreIndex = index;
                setState(() {});
              },
              controller: _controller,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkResponse(
                      onTap: () {
                        _controller.animateToPage(index,
                            duration: Duration(milliseconds: 400),
                            curve: Curves.linear);
                      },
                      child: TimeBox(
                        hideShadow: selectedScoreIndex != index,
                        text: '${index + 1}',
                        color: selectedScoreIndex == index
                            ? Theme.of(context).colorScheme.secondary
                            : null,
                        height: selectedScoreIndex == index
                            ? (kToolbarHeight + 10)
                            : kToolbarHeight,
                        width: selectedScoreIndex == index
                            ? (kToolbarHeight + 10)
                            : kToolbarHeight,
                        border: selectedScoreIndex != index
                            ? null
                            : Border.all(width: 0.35),
                      ),
                    ),
                  ],
                );
              },
              pageSnapping: false,
            ),
          ),
          SizedBox(height: 18),
          RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
                style: Theme.of(context).textTheme.caption?.copyWith(height: 1.5),
                children: [
                  TextSpan(
                      style: Theme.of(context).textTheme.subtitle2,
                      text: 'Note:\n'),
                  TextSpan(text: 'Add optional text to host'),
                ]),
          ),
          CustomTextField(
            title: '',
            hintText: Keys.bidNote.tr(context),
            onChanged: (String value) {},
          ),
          SizedBox(height: 2),
        ],
      ),
    );
  }
}

class TimeBox extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final Color? color;
  final BoxBorder? border;
  final bool hideShadow;

  const TimeBox(
      {Key? key,
      required this.text,
      this.height = kMinInteractiveDimension,
      this.width = kMinInteractiveDimension,
      this.hideShadow = false,
      this.color,
      this.border})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          boxShadow: (!hideShadow)
              ? [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ]
              : null,
          color: color ?? Theme.of(context).cardColor,
          border: border,
          borderRadius: BorderRadius.circular(8)),
      alignment: Alignment.center,
      child: Text(text, style: Theme.of(context).textTheme.subtitle2),
      height: height,
      width: width,
    );
  }
}
