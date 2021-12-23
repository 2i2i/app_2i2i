import 'dart:io';

import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/constants/strings.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/pages/my_user/ui/widgets/profile_widget.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class SetupBio extends ConsumerStatefulWidget {
  final UserModel user;

  const SetupBio({Key? key, required this.user}) : super(key: key);

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
    userNameEditController.text = widget.user.name;
    bioEditController.text = widget.user.bio;
    imageUrl = widget.user.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final myUserPageViewModel = ref.watch(myUserPageViewModelProvider);

    return WillPopScope(
      onWillPop: (){
        return Future.value(true);
      },
      child: AlertDialog(
        title: Text(Strings().aboutYou),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(Strings().aboutYouDesc),
              SizedBox(height: 20),
              CircleAvatar(
                radius: MediaQuery.of(context).size.height * 0.055,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: ClipOval(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ProfileWidget(
                            imageFile: imageFile, imageUrlString: imageUrl),
                        InkWell(
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            final ImagePicker _picker = ImagePicker();
                            final XFile? image = await _picker.pickImage(
                                source: ImageSource.gallery, imageQuality: 50);
                            imageFile = File(image!.path);
                            setState(() {});
                          },
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              color: Colors.black.withOpacity(0.8),
                              // alignment: Alignment.bottomCenter,
                              width: double.infinity,
                              padding: EdgeInsets.all(4),
                              child: Text('Edit',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .overline!
                                      .copyWith(color: AppTheme().white)),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
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
                  border: OutlineInputBorder(),
                  labelText: Strings().writeYourName,
                  hintText: Strings().yourNameHint,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: bioEditController,
                textInputAction: TextInputAction.newline,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                minLines: 6,
                maxLines: 6,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: Strings().writeYourBio,
                  hintText: Strings().bioExample,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Visibility(
            visible: widget.user.name.isNotEmpty,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).maybePop();
              },
              child: Text('Discard'),
            ),
          ),
          TextButton(
            style:TextButton.styleFrom(
              primary: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              if(formKey.currentState?.validate()??false) {
                myUserPageViewModel?.changeNameAndBio(userNameEditController.text, bioEditController.text);
                Navigator.of(context).maybePop();
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
