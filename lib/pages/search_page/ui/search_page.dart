import 'dart:math';

import 'package:app_2i2i/common/custom_navigation.dart';
import 'package:app_2i2i/common/custom_profile_image_view.dart';
import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/pages/app_settings/ui/app_settings_page.dart';
import 'package:app_2i2i/pages/rating/ui/rating_page.dart';
import 'package:app_2i2i/pages/search_page/ui/widgtes/star_widget.dart';
import 'package:app_2i2i/pages/user_bid/ui/user_page.dart';
import 'package:app_2i2i/repository/firestore_database.dart';
import 'package:app_2i2i/routes/app_routes.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 30, fit: BoxFit.contain),
        leading: IconButton(
          onPressed: () => CustomNavigation.push(
              context, AppSettingPage(), Routes.AppSetting),
          icon: Icon(IconData(58751, fontFamily: 'MaterialIcons')),
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () => CustomNavigation.push(
                context, RatingPage(), Routes.RATING),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StarWidget(
                  value: 25 / 100,
                  height: 40,
                  width: 25,
                ),
                SizedBox(height: 2),
                Text('2.5', style: Theme.of(context).textTheme.overline)
              ],
            ),
          ),
          SizedBox(width: 8)
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              cursorColor: Theme.of(context).primaryColor,
              cursorHeight: 18,
              decoration: InputDecoration(
                filled: true,
                isDense: false,
                // fillColor: Colors.grey.shade300,
                // focusColor: Colors.grey.shade300,
                hintText: 'Search user',
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).disabledColor, width: 1),
                  borderRadius: BorderRadius.circular(3.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).disabledColor, width: 1),
                  borderRadius: BorderRadius.circular(3.0),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).disabledColor, width: 1),
                  borderRadius: BorderRadius.circular(3.0),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onChanged: (value) {
                value = value.trim();
                ref.watch(searchFilterProvider).state =
                    value.isEmpty ? <String>[] : value.split(RegExp(r'\s'));
              },
            ),
          ),
          Divider(),
          Expanded(child: _buildContents(context, ref)),
        ],
      ),
    );
  }

  Widget _buildContents(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(searchFilterProvider).state;
    // log(H + '_SearchPageState - _buildContents - filter=$filter');

    return StreamBuilder(
      stream: FirestoreDatabase().usersStream(tags: filter),
      builder: (BuildContext contextMain, AsyncSnapshot<dynamic> snapshot) {
        // log(H + '_SearchPageState - _buildContents - snapshot=$snapshot');
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (_, ix) {
                // log(H + 'Search - _buildContents - ix=$ix');
                if (snapshot.data[ix] == null) return Container();
                final user = snapshot.data[ix]! as UserModel;
                if (user.name.isEmpty) return Container();
                // log(H +
                //     'Search - _buildContents - !user.name.isEmpty - user=$user');

                final name = user.name;
                final bio = user.bio;
                final shortBioStart = bio.indexOf(RegExp(r'\s')) + 1;
                int aPoint = shortBioStart + 10;
                int bPoint = bio.length;
                final shortBioEnd = min(aPoint, bPoint);
                final shortBio = user.bio.substring(shortBioStart, shortBioEnd);

                var statusColor = AppTheme().green;
                if (user.status == 'OFFLINE') statusColor = AppTheme().gray;
                if (user.locked) statusColor = AppTheme().red;

                return Card(
                  margin: EdgeInsets.all(4),
                  elevation: 4,
                  // decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.6)), borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                      leading: ratingWidget(user.rating, name),
                      title: Text(name),
                      subtitle: Text(shortBio),
                      trailing: Icon(Icons.circle, color: statusColor),
                      onTap: () => CustomNavigation.push(
                          context,
                          UserPage(uid: user.id),
                          Routes
                              .USER)), // UserPage.show(context, users[ix].id),
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

