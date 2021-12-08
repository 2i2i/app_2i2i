import 'dart:math';

import 'package:app_2i2i/common/custom_app_bar.dart';
import 'package:app_2i2i/common/custom_navigation.dart';
import 'package:app_2i2i/common/text_utils.dart';
import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/pages/app_settings/ui/app_settings_page.dart';
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
      backgroundColor: Colors.grey[50],
      appBar: CustomAppbar(
          leading: IconButton(
            onPressed: () => CustomNavigation.push(context, AppSettingPage(),Routes.AppSetting),
            icon: Icon(IconData(58751, fontFamily: 'MaterialIcons')),
          )),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              cursorColor: AppTheme().gray,
              decoration: InputDecoration(
                  filled: true,
                  isDense: false,
                  fillColor: Colors.grey.shade300,
                  focusColor: Colors.grey.shade300,
                  hintText: 'Search user',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.6), width: 1),
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.6), width: 1),
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.6), width: 1),
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  prefixIcon: Icon(Icons.search)),
              onSubmitted: (value) {
                value = value.trim();
                ref.watch(searchFilterProvider).state =
                    value.isEmpty ? <String>[] : value.split(RegExp(r'\s'));
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
            child: Row(
              children: [
                Center(
                    child: CaptionText(
                      textColor: AppTheme().gray,
                        title: "RATING", fontWeight: FontWeight.w400)),
                SizedBox(width: 4),
                Expanded(
                  flex: 3,
                  child: Center(
                      child: CaptionText(
                          textColor: AppTheme().gray,
                          title: "USER", fontWeight: FontWeight.w400)),
                ),
                SizedBox(width: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CaptionText(
                        textColor: AppTheme().gray,
                        title: "ONLINE", fontWeight: FontWeight.w400),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.circle, color: AppTheme().green,size: 15),
                    ),
                    CaptionText(
                        textColor: AppTheme().gray,
                        title: "OFFLINE", fontWeight: FontWeight.w400),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.circle, color: AppTheme().gray,size: 15),
                    ),
                    CaptionText(
                        textColor: AppTheme().gray,
                        title: "ONCALL", fontWeight: FontWeight.w400),
                    Icon(Icons.circle, color: AppTheme().red,size: 15),
                  ],
                ),
              ],
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
    return StreamBuilder(
      stream: FirestoreDatabase().usersStream(tags: filter),
      builder: (BuildContext contextMain, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (_, ix) {
                if (snapshot.data[ix] == null) return Container();
                final user = snapshot.data[ix]!;

                final name = user.name;
                final bio = user.bio;
                final shortBioStart = bio.indexOf(RegExp(r'\s')) + 1;
                int aPoint = shortBioStart + 10;
                int bPoint = bio.length;
                final shortBioEnd = min(aPoint, bPoint);
                final shortBio = user.bio.substring(shortBioStart, shortBioEnd);
                final score = user.upVotes - user.downVotes;
                final scoreString = (0 <= score ? '+' : '-') + score.toString();
                final iconColor = 0 <= score ? Colors.green : Color.fromRGBO(211, 91, 122, 1);
                final iconBase = IconButton(
                  icon: Icon(Icons.change_history, color: iconColor),
                  onPressed: null,
                  tooltip: scoreString,
                );

                var statusColor = AppTheme().green;
                if (user.status == 'OFFLINE') statusColor = AppTheme().gray;
                if (user.locked) statusColor = AppTheme().red;

                return Card(
                  margin: EdgeInsets.all(4),
                  elevation: 4,
                  // decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.6)), borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                      leading: ratingWidget(score, name),
                      title: TitleText(title: name),
                      subtitle: Text(shortBio),
                      trailing: Icon(Icons.circle, color: statusColor),
                      onTap: () => CustomNavigation.push(context, UserPage(uid: user.id),Routes.USER)), // UserPage.show(context, users[ix].id),
                );
              });
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget ratingWidget(score, name) {
    final scoreString = (0 <= score ? '+' : '-') + score.toString();

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
            Text(scoreString, style: Theme.of(context).textTheme.caption)
          ],
        ),
        SizedBox(width: 10),
        Container(
          height: 40,
          width: 40,
          child: Center(
              child: Text("${name.toString().isNotEmpty ? name : "X"}"
                  .substring(0, 1)
                  .toUpperCase())),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromRGBO(214, 219, 134, 1),
          ),
        )
      ],
    );
  }
}
