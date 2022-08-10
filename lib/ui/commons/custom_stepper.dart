import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StepProgressView extends StatelessWidget {
  final List<Map<String, dynamic>> titles;
  final List<String> descriptionList;
  final int curStep;
  final bool isLoading;

  StepProgressView({Key? key, required this.titles, required this.descriptionList, required this.curStep, this.isLoading = false}) : super(key: key);

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _iconViews(context),
          ),
        ),
        SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              text: "Step $curStep:",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              children: [
                if (curStep < titles.length)
                  TextSpan(
                    text: " ${titles[curStep]['title']}",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
            alignment: Alignment.center,
            child: isLoading
                ? Center(child: CupertinoActivityIndicator())
                : Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.amberAccent.shade100, borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      "${descriptionList[curStep]}",
                      maxLines: 5,
                    ),
                  ),
            height: MediaQuery.of(context).size.width / 4),
      ],
    );
  }

  List<Widget> _iconViews(BuildContext context) {
    var list = <Widget>[];
    titles.asMap().forEach(
          (i, icon) {
        var circleColor = (i == 0 || curStep > (i - 1) || curStep == 2)
            ? titles[i]['isComplete']
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).errorColor
            : Color(0xFFE6EEF3);
        var lineColor = curStep > i ? Theme.of(context).colorScheme.secondary : Color(0xFFE6EEF3);
        IconData icon = titles[i]['isComplete'] ? Icons.done : Icons.close;

        list.add(
          CircleAvatar(
            backgroundColor: circleColor,
            radius: 12,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(icon, color: Colors.white, size: 16),
              color: Colors.white,
              onPressed: null,
            ),
          ),
        );

        if (i != titles.length - 1) {
          list.add(
            Expanded(
              child: Container(
                alignment: Alignment.center,
                height: 3.0,
                color: lineColor,
              ),
            ),
          );
        }
      },
    );

    return list;
  }
}
