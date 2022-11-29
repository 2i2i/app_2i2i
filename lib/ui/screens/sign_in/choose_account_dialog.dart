import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_network/image_network.dart';

class ChooseAccountDialog extends ConsumerStatefulWidget {
  final List userIds;
  final ValueChanged<String> onSelectId;

  ChooseAccountDialog({required this.userIds, required this.onSelectId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return ChooseAccountState();
  }
}

class ChooseAccountState extends ConsumerState<ChooseAccountDialog> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Multiple accounts'),
      contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 20),
      children: List.generate(widget.userIds.length + 1, (index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24),
            child: Text('Choose any account using which you want to sing in.'),
          );
        }
        index = index - 1;
        String uid = widget.userIds.elementAt(index);
        var user = ref.watch(userProvider(uid));
        if (user.value is! UserModel) {
          return LinearProgressIndicator();
        }
        UserModel userModel = user.value!;
        return ListTile(
          onTap: () => widget.onSelectId.call(uid),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: ImageNetwork(
              image: userModel.imageUrl ?? '',
              imageCache: NetworkImage(userModel.imageUrl ?? ''),
              width: 35,
              height: 35,
              onLoading: const CupertinoActivityIndicator(),
              onError: const Icon(Icons.error),
              fitWeb: BoxFitWeb.cover,
              fitAndroidIos: BoxFit.cover,
            ),
          ),
          title: Text(userModel.name),
        );
      }),
    );
  }
}
