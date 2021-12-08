import 'package:app_2i2i/common/strings.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetupBio extends ConsumerStatefulWidget {
  final UserModel? model;
  const SetupBio({Key? key, this.model}) : super(key: key);

  @override
  _SetupBioState createState() => _SetupBioState();
}

class _SetupBioState extends ConsumerState<SetupBio> {
  TextEditingController userNameEditController = TextEditingController();
  TextEditingController bioEditController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    userNameEditController.text = widget.model?.name??'';
    bioEditController.text = widget.model?.bio??'';
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(Strings().aboutYouDesc),
              SizedBox(height: 40),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: userNameEditController,
                textInputAction: TextInputAction.next,
                validator: (value){
                  value ??='';
                  if(value.trim().isEmpty){
                    return Strings().required;
                  }
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
                ],
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
                validator: (value){
                  value ??='';
                  if(value.trim().isEmpty){
                    return Strings().required;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          Visibility(
            visible: widget.model?.name.isNotEmpty??false,
            child: TextButton(
              style:TextButton.styleFrom(
                  primary: Theme.of(context).hintColor
              ),
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
