import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import '../../../../infrastructure/data_access_layer/services/logging.dart';
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ProfileWidget(
              stringPath: (ratingModel.rating * 5).toStringAsFixed(1).replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '').toString(),
              isRating: true,
              showBorder: true,
              radius: 65,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
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
                            log("$rating");
                          },
                        ),
                      ),
                      SizedBox(width: 6),
                      if ((ratingModel.createdAt ?? 0) > 0)
                        Text(DateFormat().add_yMMMMd().format(DateTime.fromMillisecondsSinceEpoch(ratingModel.createdAt!).toLocal()),
                            style: Theme.of(context).textTheme.caption) //todo created date time <= Done
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      ratingModel.comment ?? "",
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(fontStyle: FontStyle.italic),
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

  String getTime(DateTime? createdAt) {
    String time = "";
    if (createdAt is DateTime) {
      DateTime meetingTime = createdAt.toLocalDateTime();
      DateFormat formatDate = new DateFormat("yyyy-MM-dd\nhh:mm:a");
      time = formatDate.format(meetingTime.toLocal());
    }
    return time;
  }
}
