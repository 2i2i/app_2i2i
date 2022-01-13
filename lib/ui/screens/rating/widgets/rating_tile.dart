import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../infrastructure/models/meeting_model.dart';
import '../../../commons/custom_profile_image_view.dart';

class RatingTile extends StatelessWidget {
  const RatingTile({Key? key, required this.ratingModel}) : super(key: key);

  final RatingModel ratingModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextProfileView(
              text: (ratingModel.rating * 5).toStringAsFixed(0),
              isRating: true,
              radius: 65,
              hideStatus: true,
              style: Theme.of(context)
                  .textTheme
                  .headline5!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IgnorePointer(
                        ignoring: true,
                        child: RatingBar.builder(
                          initialRating: ratingModel.rating * 5,
                          minRating: 1,
                          maxRating: 5,
                          direction: Axis.horizontal,
                          itemCount: 5,
                          itemSize: 22,
                          allowHalfRating: true,
                          glowColor: Colors.white,
                          unratedColor: Colors.grey.shade300,
                          itemBuilder: (context, _) => Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            print(rating);
                          },
                        ),
                      ),
                      SizedBox(width: 6),
                      Text('24 Dec 2021',
                          style: Theme.of(context).textTheme.caption)
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      ratingModel.comment ?? "",
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1!
                          .copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
                Divider()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
