import 'dart:math';

import 'package:app_2i2i/infrastructure/data_access_layer/accounts/local_account.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/ui/commons/custom_app_bar_holder.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/data_access_layer/services/logging.dart';

class VerifyPerhapsPageWeb extends ConsumerStatefulWidget {
  final List perhaps;
  final LocalAccount account;

  const VerifyPerhapsPageWeb({
    Key? key,
    required this.perhaps,
    required this.account,
  }) : super(key: key);

  @override
  _VerifyPerhapsPageState createState() => _VerifyPerhapsPageState();
}

class _VerifyPerhapsPageState extends ConsumerState<VerifyPerhapsPageWeb> {
  int currentIndex = 0;
  Random random = new Random();

  List allOptions = [];

  List<Question> data = [];

  @override
  void initState() {
    super.initState();
    generateFive();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbarHolder(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Keys.verifyRecovery.tr(context),
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(height: 30),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  Question question = data[index];
                  List options = question.options;
                  return ListTile(
                    title: Text('${Keys.selectWord.tr(context)} #${question.index + 1}'),
                    subtitle: Row(
                      children: List.generate(options.length, (index) {
                        String text = options[index];
                        return Expanded(
                          child: InkResponse(
                            onTap: () {
                              question.selected = text;
                              setState(() {});
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(left: 5, right: 15, top: 20),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: question.selected == text ? Theme.of(context).colorScheme.secondary : Theme.of(context).cardColor,
                              ),
                              child: Text(
                                text,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Divider(
                      color: Colors.transparent,
                    ),
                  );
                },
                itemCount: data.length,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height / 12,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: ElevatedButton(
                  onPressed: isValid()
                      ? () async {
                          CustomDialogs.loader(true, context);
                          try {
                            final myAccountPageViewModel = ref.read(myAccountPageViewModelProvider);
                            await myAccountPageViewModel.saveLocalAccount(widget.account);
                            await widget.account.setMainAccount();
                          } catch (e) {
                            log("$e");
                          }
                          CustomDialogs.loader(false, context);
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: Text(Keys.complete.tr(context)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void generateFive() {
    data.clear();
    allOptions.clear();
    List questions = [];
    int min = 0, max = 24;

    for (int i = 0; questions.length < 4; i++) {
      int num = min + random.nextInt(max - min);
      if (!questions.contains(num)) {
        questions.add(num);
        allOptions.add(widget.perhaps[num]);
      }
    }

    for (int i = 0; i < questions.length; i++) {
      int validIndex = questions[i];
      String valid = widget.perhaps[validIndex];
      List<String> options = [
        valid,
      ];

      for (int k = 0; options.length < 3; k++) {
        int n = 0 + random.nextInt(25 - 0);
        bool contains = checkContains(allOptions, n);
        if (!contains) {
          allOptions.add(widget.perhaps[n]);
          options.add(widget.perhaps[n]);
        }
      }
      options.shuffle();
      Question question = Question(questions[i]);
      question.validData = valid;
      question.options = options;
      data.add(question);
    }
    if (mounted) {
      setState(() {});
    }
  }

  bool checkContains(List<dynamic> options, int n) {
    return options.contains(widget.perhaps[n]);
  }

  bool isValid() {
    return !(data.map((e) => e.validData == e.selected).toSet().toList().contains(false));
  }
}

class Question {
  int index;
  List<String> options = [];
  String validData = '';
  String? selected;

  Question(this.index);
}
