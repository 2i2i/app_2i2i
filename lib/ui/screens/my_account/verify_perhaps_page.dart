import 'dart:math';
import 'package:app_2i2i/infrastructure/data_access_layer/accounts/local_account.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/infrastructure/routes/app_routes.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class VerifyPerhapsPage extends ConsumerStatefulWidget {
  final List perhaps;
  final LocalAccount account;

  const VerifyPerhapsPage(this.perhaps, this.account, {Key? key})
      : super(key: key);

  @override
  _VerifyPerhapsPageState createState() => _VerifyPerhapsPageState();
}

class _VerifyPerhapsPageState extends ConsumerState<VerifyPerhapsPage> {
  int currentIndex = 0;
  Random random = new Random();

  List allOptions = [];

  List<Question> data = [];

  @override
  void initState() {
    generateFive();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Verify recovery passphrase backup',
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
                    title: Text('Select word #${question.index + 1}'),
                    subtitle: Row(
                      children: List.generate(options.length, (index) {
                        String text = options[index];
                        return Expanded(
                          child: InkResponse(
                            onTap: (){
                              question.selected = text;
                              setState(() {});
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(left: 5, right: 5, top: 20),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: question.selected == text
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).cardColor,
                              ),
                              child: Text(
                                text,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1,
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
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        child: ElevatedButton(
          onPressed: isValid()
              ? () async {
                  CustomDialogs.loader(true, context);
                  try {
                    final myAccountPageViewModel =
                        ref.read(myAccountPageViewModelProvider);
                    await myAccountPageViewModel
                        .saveLocalAccount(widget.account);
                    await widget.account.setMainAccount();
                  } catch (e) {
                    print(e);
                  }
                  CustomDialogs.loader(false, context);
                  Navigator.of(context).pop();
                  // Navigator.of(context).pop();
                }
              : null,
          child: Text('Complete'),
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
    return !(data
        .map((e) => e.validData == e.selected)
        .toSet()
        .toList()
        .contains(false));
  }
}

class Question {
  int index;
  List<String> options = [];
  String validData = '';
  String? selected;

  Question(this.index);
}
