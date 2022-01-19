import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';

class SuccessData {
  const SuccessData(
      {Key? key,
      required this.title,
      required this.description,
      required this.timestamp});
  final String title;
  final String description;
  final int timestamp;
}

class Success extends StatelessWidget {
  const Success({
    Key? key,
    required this.data,
    required this.backgroundColor,
  }) : super(key: key);
  final SuccessData data;
  final Color backgroundColor;

  // final GlobalKey<ExpansionTileCardState> key = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5),
        child: ExpansionTileCard(
          key: key,
          leading: Icon(Icons.label_important),
          title: Text(data.title),
          subtitle: Text(
            data.timestamp.toString(),
          ),
          baseColor: backgroundColor,
          expandedTextColor: Color.fromRGBO(100, 34, 84, 1),
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
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
            ),
          ],
        ));
  }
}
