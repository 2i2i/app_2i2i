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
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: ExpansionTileCard(
          elevation: 0,
          key: key,
          baseColor: Theme.of(context).primaryColorLight,
          title: Text(data.title,style: Theme.of(context).textTheme.subtitle1,),
          expandedTextColor: Theme.of(context).colorScheme.secondary,
          children: <Widget>[
            Divider(
              thickness: 1.0,
              height: 1.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
              child: Text(
                data.description,
                textAlign: TextAlign.justify,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
