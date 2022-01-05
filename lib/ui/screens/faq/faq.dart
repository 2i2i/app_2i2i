import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';

class FAQData {
  const FAQData(
      {Key? key,
      required this.title,
      required this.description,});
  final String title;
  final String description;
}

class FAQ extends StatelessWidget {
  const FAQ({
    Key? key,
    required this.data,
    required this.backgroundColor, required this.index,
  }) : super(key: key);
  final FAQData data;
  final Color backgroundColor;
  final int index;

  // final GlobalKey<ExpansionTileCardState> key = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    Color bg = index % 2 == 0
        ? Theme.of(context).colorScheme.secondary.withOpacity(0.5)
        : Theme.of(context).colorScheme.secondary.withOpacity(0.2);
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5),
        child: ExpansionTileCard(
          elevation: 4,
          key: key,
          leading: Icon(Icons.label_important),
          title: Text(data.title),
          baseColor: bg,
          expandedTextColor: Theme.of(context).colorScheme.secondary,
          children: <Widget>[
            Divider(
              thickness: 1.0,
              height: 1.0,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  data.description,
                  textAlign: TextAlign.left,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .copyWith(fontSize: 16),
                ),
              ),
            ),
          ],
        ));
  }
}