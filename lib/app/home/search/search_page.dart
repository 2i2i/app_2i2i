import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:go_router/go_router.dart';

class SearchPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: TextField(
            cursorWidth: 5,
            cursorColor: Color.fromRGBO(60, 84, 68, 1),
            cursorHeight: 20,
            decoration: InputDecoration(hintText: '<type your search here>'),
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
}

Widget _buildContents(BuildContext context, WidgetRef ref) {
  log('SearchPage - _buildContents');
  final usersAsyncValue = ref.watch(searchUsersStreamProvider);
  log('SearchPage - _buildContents - usersAsyncValue=$usersAsyncValue');
  return usersAsyncValue.when(
      // TODO add sorting
      data: (users) => ListView.builder(
          itemCount: users.length,
          itemBuilder: (_, ix) {
            if (users[ix] == null) return Container();
            final user = users[ix]!;

            final name = user.name;
            final bio = user.bio;
            final shortBioStart = bio.indexOf(RegExp(r'\s')) + 1;
            final shortBioEnd = min(shortBioStart + 10, bio.length);
            final shortBio =
                user.bio.substring(shortBioStart, shortBioEnd);
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

            return ListTile(
              leading: iconRotated,
              title: Text(name),
              subtitle: Text(shortBio),
              trailing: Icon(Icons.circle, color: statusColor),
              onTap: () => context.goNamed('user', params: {
                'uid': user.id,
              }), // UserPage.show(context, users[ix].id),
            );
          }),
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('error'));
}
