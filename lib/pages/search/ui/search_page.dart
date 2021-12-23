import 'dart:math';

import 'package:app_2i2i/common/custom_navigation.dart';
import 'package:app_2i2i/common/custom_profile_image_view.dart';
import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/pages/user_bid/ui/user_page.dart';
import 'package:app_2i2i/repository/firestore_database.dart';
import 'package:app_2i2i/routes/app_routes.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../common/custom_app_bar.dart';
import '../../../constants/strings.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppbar(
        /*actions: [
          UserRatingWidget(),
        ],*/
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: Strings().searchUserHint,
                filled: true,
                contentPadding:
                EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                prefixIcon: Icon(Icons.search),
                suffixIcon: Icon(Icons.mic),
              ),
              onChanged: (value) {
                value = value.trim();
                ref
                    .watch(searchFilterProvider)
                    .state =
                value.isEmpty ? <String>[] : value.split(RegExp(r'\s'));
              },
            ),
            SizedBox(height: 10),
            Expanded(child: _buildContents(context, ref)),
          ],
        ),
      ),
    );
  }

  Widget _buildContents(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(searchFilterProvider).state;
    final mainUserID = ref.watch(myUIDProvider)!;
    // log(H + '_SearchPageState - _buildContents - filter=$filter');

    return StreamBuilder(
      stream: FirestoreDatabase().usersStream(tags: filter),
      builder: (BuildContext contextMain, AsyncSnapshot<dynamic> snapshot) {
        // log(H + '_SearchPageState - _buildContents - snapshot=$snapshot');
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (_, ix) {
                // log(H + 'Search - _buildContents - ix=$ix');
                if (snapshot.data[ix] == null) return Container();
                final user = snapshot.data[ix]! as UserModel;
                if (user.name.isEmpty) return Container();
                // log(H +
                //     'Search - _buildContents - !user.name.isEmpty - user=$user');

                final name = user.name;
                final bio = user.bio;
                /*  final shortBioStart = bio.indexOf(RegExp(r'\s')) + 1;
                int aPoint = shortBioStart + 10;
                int bPoint = bio.length;
                final shortBioEnd = min(aPoint, bPoint);
                final shortBio = user.bio.substring(shortBioStart, shortBioEnd);*/

                var statusColor = AppTheme().green;
                if (user.status == 'OFFLINE') statusColor = AppTheme().gray;
                if (user.locked) statusColor = AppTheme().red;

                return Visibility(
                  visible: user.id != mainUserID,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextProfileView(
                        text: name,
                        statusColor: /*statusColor*/ Colors.green,
                        radius: kToolbarHeight + 6,
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          children: [
                            Theme(
                              data: ThemeData(
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent
                              ),
                              child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 0),
                                  title: Padding(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      name,
                                      style:
                                      TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  subtitle: Text(
                                    bio,
                                    maxLines: 2,
                                  ),
                                  trailing: Container(
                                    height: kToolbarHeight,
                                    width: kToolbarHeight,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: IconButton(
                                              iconSize: 20,
                                              onPressed: null,
                                              icon: Icon(
                                                  Icons.favorite_border)),
                                        ),
                                        Expanded(
                                          child: Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(user.rating.toString(),
                                                  style: Theme
                                                      .of(context)
                                                      .textTheme
                                                      .bodyText1),
                                              SizedBox(width: 4),
                                              SvgPicture.asset(
                                                'assets/icons/rating_star.svg',
                                                width: 12,
                                                height: 12,
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () =>
                                      CustomNavigation.push(context,
                                          UserPage(uid: user.id), Routes.USER)),
                            ),
                            Divider()
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              });
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget ratingWidget(score, name) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            0 <= score
                ? Icon(Icons.change_history, color: Colors.green)
                : Transform.rotate(
                    angle: pi,
                    child: Icon(Icons.change_history,
                        color: Color.fromRGBO(211, 91, 122, 1))),
            SizedBox(height: 4),
            Text(score.toString(), style: Theme.of(context).textTheme.caption)
          ],
        ),
        SizedBox(width: 10),
        CustomImageProfileView(text: name)
      ],
    );
  }
}

