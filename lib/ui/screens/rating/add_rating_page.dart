import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/routes/named_routes.dart';

class AddRatingPage extends ConsumerStatefulWidget {
  @override
  _AddRatingPageState createState() => _AddRatingPageState();
}

class _AddRatingPageState extends ConsumerState<AddRatingPage> {
  double rating = 1.0;
  TextEditingController feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: NamedRoutes.showRating,
      builder: (BuildContext context, Map<dynamic, dynamic> value, Widget? child) {
        child ??= Container();
        return Visibility(
          visible: value['show'] ?? false,
          child: child,
        );
      },
      child: BottomSheet(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        builder: (BuildContext context) {
          return Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Keys.appRatingTitle.tr(context),
                  style: Theme.of(context).textTheme.headline4,
                ),
                SizedBox(height: 8),
                // Text(
                //   Strings().appRatingMessage,
                //   style: Theme.of(context).textTheme.bodyText2,
                // ),
                Container(
                  margin: EdgeInsets.only(bottom: 20, top: 8),
                  child: RatingBar.builder(
                    initialRating: rating * 5.0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    glowColor: Colors.white,
                    unratedColor: Colors.grey.shade300,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (starRating) {
                      rating = starRating / 5.0;
                    },
                  ),
                ),
                TextFormField(
                  controller: feedbackController,
                  minLines: 5,
                  maxLines: 5,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).iconTheme.color?.withAlpha(10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => {
                        NamedRoutes.showRating.value = {'show': false}
                      },
                      child: Text(
                        Keys.cancel.tr(context),
                      ),
                    ),
                    SizedBox(width: 10),
                    TextButton(
                      onPressed: () async {
                        var otherUid = NamedRoutes.showRating.value['otherUid'];
                        var meetingId = NamedRoutes.showRating.value['meetingId'];

                        if (otherUid is String && meetingId is String) {
                          final database = ref.read(databaseProvider);
                          await database.addRating(
                            otherUid,
                            meetingId,
                            RatingModel(
                              rating: rating,
                              comment: feedbackController.text,
                            ),
                          );
                        }
                        Future.delayed(Duration(milliseconds: 500)).then((value) {
                          NamedRoutes.showRating.value = {'show': false};
                        });
                      },
                      child: Text(
                        Keys.appRatingSubmitButton.tr(context),
                      ),
                      style: TextButton.styleFrom(
                        primary: Theme.of(context).colorScheme.secondary,
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        },
        onClosing: () => {},
      ),
    );
  }
}
