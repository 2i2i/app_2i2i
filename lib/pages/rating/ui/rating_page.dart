import 'package:app_2i2i/common/custom_profile_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({Key? key}) : super(key: key);

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  @override
  Widget build(BuildContext context) {
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
                      initialRating: 3,
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
                      Text('4.2 out of 5',
                          style: Theme.of(context).textTheme.subtitle2),
                      SizedBox(width: 4),
                      Text('(800 Reviews)',
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
                itemBuilder: (BuildContext context, int index) => Card(
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
                              initialRating: 3,
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
                          'Good meeting with 2i2i Good meeting with 2i2i Good meeting with 2i2i Good meeting with 2i2i Good meeting with 2i2i Good meeting with 2i2i',
                          style: Theme.of(context).textTheme.overline,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
