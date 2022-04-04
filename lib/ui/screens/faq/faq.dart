import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';

import '../../../infrastructure/models/faq_model.dart';

class FAQWidget extends StatelessWidget {
  const FAQWidget({
    required this.data,
    required this.backgroundColor,
    required this.index,
  });
  final FAQDataModel data;
  final Color backgroundColor;
  final int index;


  @override
  Widget build(BuildContext context) {
    Color bg = index % 2 == 0
        ? Theme.of(context).colorScheme.secondary.withOpacity(0.5)
        : Theme.of(context).colorScheme.secondary.withOpacity(0.2);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 5),
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
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: data.descriptionTextSpan == null
                ? Text(
                    data.description!,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyText2,
                  )
                : RichText(
                    text: data.descriptionTextSpan!,
                    textAlign: TextAlign.left,
                  ),
          ),
          Divider(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 8,vertical: 4),
            child: Row(
              children: List.generate(data.tags?.length ?? 0, (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30)
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                  child: Text(
                    "#${data.tags![index]}",
                    style: Theme.of(context).textTheme.overline?.copyWith(
                        color: Theme.of(context).cardColor
                    ),
                  ),
                  // backgroundColor: Theme.of(context).iconTheme.color,
                ),
              )),
            ),
          )
        ],
      ),
    );
  }
}
