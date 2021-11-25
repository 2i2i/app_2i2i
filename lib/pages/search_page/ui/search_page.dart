import 'dart:math';

import 'package:app_2i2i/pages/ringing/ui/ripples_animation.dart';
import 'package:app_2i2i/repository/firestore_database.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        title: Container(
          child: TextField(
            cursorWidth: 5,
            cursorColor: Color.fromRGBO(60, 84, 68, 1),
            cursorHeight: 20,
            decoration: InputDecoration(hintText: 'type your search here'),
            onSubmitted: (value) {
              value = value.trim();
              ref.watch(searchFilterProvider).state =
                  value.isEmpty ? <String>[] : value.split(RegExp(r'\s'));
            },
          ),
        ),
      ),
      body: _buildContents(context, ref),
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
                final iconColor =
                    0 <= score ? Colors.green : Color.fromRGBO(211, 91, 122, 1);
                final iconBase = IconButton(
                  icon: Icon(Icons.change_history, color: iconColor),
                  onPressed: null,
                  tooltip: scoreString,
                );
                final iconRotated = 0 <= score
                    ? iconBase
                    : Transform.rotate(angle: pi, child: iconBase);

                var statusColor = Colors.green;
                if (user.status == 'OFFLINE') statusColor = Colors.grey;
                if (user.locked) statusColor = Colors.red;

                return ListTile(
                  leading: iconRotated,
                  title: Text(name),
                  subtitle: Text(shortBio),
                  trailing: Icon(Icons.circle, color: statusColor),
                  onTap: () => context.goNamed('user', params: {
                    'uid': user.id,
                  }), // UserPage.show(context, users[ix].id),
                );
              });
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
