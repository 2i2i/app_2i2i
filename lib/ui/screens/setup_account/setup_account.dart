import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/commons/strings.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/providers/my_user_provider/my_user_page_view_model.dart';

class SetupBio extends ConsumerStatefulWidget {
  final bool? isFromDialog;

  SetupBio({this.isFromDialog});

  @override
  _SetupBioState createState() => _SetupBioState();
}

class _SetupBioState extends ConsumerState<SetupBio> {
  TextEditingController userNameEditController = TextEditingController();
  TextEditingController bioEditController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  File? imageFile;
  String imageUrl = "";

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final uid = ref.watch(myUIDProvider)!;
      final user = ref.watch(userProvider(uid));
      bool isLoaded = !(user is AsyncLoading && user is AsyncError);
      if (isLoaded) {
        userNameEditController.text = user.asData!.value.name;
        bioEditController.text = user.asData!.value.bio;
        imageUrl = user.asData!.value.name;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final myUserPageViewModel = ref.watch(myUserPageViewModelProvider);

    if (widget.isFromDialog ?? false) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildMainWidget(context, myUserPageViewModel),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: (widget.isFromDialog ?? false) ? null : AppBar(elevation: 0),
      body: buildMainWidget(context, myUserPageViewModel),
    );
  }

  Padding buildMainWidget(
      BuildContext context, MyUserPageViewModel? myUserPageViewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: kRadialReactionRadius),
            Text(
              Strings().setUpAccount,
              style: Theme.of(context).textTheme.headline4!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).tabBarTheme.unselectedLabelColor),
            ),
            SizedBox(height: kRadialReactionRadius+8),
            Text(Strings().userName,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: Theme.of(context).disabledColor)),
            SizedBox(height: 6),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: userNameEditController,
              textInputAction: TextInputAction.next,
              autofocus: true,
              onChanged: (value) {
                imageUrl = value;
                setState(() {});
              },
              validator: (value) {
                value ??= '';
                if (value.trim().isEmpty) {
                  return Strings().required;
                }
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).primaryColorLight,
                hintText: Strings().yourNameHint,
              ),
            ),
            SizedBox(height: kMinInteractiveDimension),
            Text(Strings().bio,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: Theme.of(context).disabledColor)),
            SizedBox(height: 6),
            TextFormField(
              controller: bioEditController,
              textInputAction: TextInputAction.newline,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              minLines: 6,
              maxLines: 6,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).primaryColorLight,
                border: OutlineInputBorder(),
                hintText: Strings().bioExample,
              ),
            ),
            SizedBox(height: kToolbarHeight),
            ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    myUserPageViewModel?.changeNameAndBio(
                        userNameEditController.text, bioEditController.text);
                    Navigator.of(context).maybePop();
                  }
                },
                child: Text(Strings().save))
          ],
        ),
      ),
    );
  }
}
