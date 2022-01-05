import 'package:app_2i2i/common/custom_profile_image_view.dart';
import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RatingPage extends ConsumerStatefulWidget {
  final UserModel userModel;

  const RatingPage({Key? key, required this.userModel}) : super(key: key);

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends ConsumerState<RatingPage> {
  @override
  Widget build(BuildContext context) {
    final ratingListAsyncValue =
        ref.watch(ratingListProvider(widget.userModel.id));
    if (ratingListAsyncValue is AsyncLoading ||
        ratingListAsyncValue is AsyncError) {
      return WaitPage();
    }

    final ratingList = ratingListAsyncValue.value!;

    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        width: double.infinity,
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('My Reviews',
                      style: Theme.of(context).textTheme.headline5),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    child: RatingBar.builder(
                      initialRating: (widget.userModel.rating ?? 0) * 5,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      updateOnDrag: false,
                      glowColor: Colors.white,
                      unratedColor: Colors.grey.shade300,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        print(rating);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${(widget.userModel.rating ?? 0) * 5} out of 5',
                          style: Theme.of(context).textTheme.subtitle2),
                      SizedBox(width: 4),
                      Text(
                          '(${(/*widget.userModel?.numRatings*/ ratingList.length)} reviews)',
                          style: Theme.of(context).textTheme.caption),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              flex: 5,
              child: ListView.builder(
                  itemCount: ratingList.length,
                  itemBuilder: (BuildContext context, int index) {
                    RatingModel ratingModel = ratingList[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 12, left: 12, right: 2, top: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CustomImageProfileView(text: "IMI"),
                              title: Text("User Data $index"),
                              subtitle: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: RatingBar.builder(
                                  initialRating: ratingModel.rating * 5,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  itemCount: 5,
                                  itemSize: 30,
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
                              ) /*Text("shortBio\nshortBio")*/,
                            ),
                            Text(
                              ratingModel.comment ?? "",
                              style: Theme.of(context).textTheme.overline,
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
