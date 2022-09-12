import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/accounts/local_account.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/infrastructure/routes/app_routes.dart';
import 'package:app_2i2i/ui/commons/custom_app_bar_holder.dart';
import 'package:app_2i2i/ui/screens/app/wait_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../commons/custom_alert_widget.dart';

class CreateLocalAccountWeb extends ConsumerStatefulWidget {
  const CreateLocalAccountWeb({Key? key}) : super(key: key);

  @override
  _CreateLocalAccountState createState() => _CreateLocalAccountState();
}

class _CreateLocalAccountState extends ConsumerState<CreateLocalAccountWeb> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ref.watch(myAccountPageViewModelProvider).addLocalAccount();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final myAccountPageViewModel = ref.watch(myAccountPageViewModelProvider);
    return Scaffold(
      appBar: CustomAppbarHolder(),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                Keys.createLocalAccount.tr(context),
                style: Theme.of(context).textTheme.headline5,
              ),
              SizedBox(height: 10),
              Text(
                Keys.createLocalAccountWarning.tr(context),
                style: Theme.of(context).textTheme.caption,
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 30),
              Expanded(
                child: Row(
                  children: [
                    Spacer(),
                    Expanded(
                      flex: 2,
                      child: Builder(builder: (context) {
                        if (!myAccountPageViewModel.isLoading) {
                          LocalAccount? localAccount = myAccountPageViewModel.localAccount;
                          return FutureBuilder(
                            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                              if (snapshot.hasData) {
                                List<String> perhaps = snapshot.data;
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: GridView.count(
                                        shrinkWrap: true,
                                        crossAxisCount: 4,
                                        childAspectRatio: 3.5,
                                        children: List.generate(perhaps.length, (index) {
                                          return ListTile(
                                            title: Center(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: CircleAvatar(
                                                      backgroundColor: Theme.of(context).primaryColor,
                                                      radius: 10,
                                                      child: Text(
                                                        '${index + 1}',
                                                        textAlign: TextAlign.center,
                                                        style: Theme.of(context).textTheme.caption,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      '${perhaps[index]}',
                                                      style: Theme.of(context).textTheme.bodyText2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:MediaQuery.of(context).size.width/15,
                                          vertical:MediaQuery.of(context).size.height/20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(30),
                                              child: ElevatedButton.icon(
                                                onPressed: () {
                                                  if (perhaps.isNotEmpty) {
                                                    Clipboard.setData(ClipboardData(text: perhaps.join(' ')));
                                                    CustomAlertWidget.showToastMessage(context, Keys.copyMessage.tr(context));
                                                  }
                                                },
                                                label: Text(Keys.copy.tr(context)),
                                                icon: Icon(Icons.copy_all_rounded, size: 16),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: MediaQuery.of(context).size.width / 20),
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(30),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  if (perhaps.isNotEmpty) {
                                                    context.pop();
                                                    context.pushNamed(
                                                      Routes.verifyPerhaps.nameFromPath(),
                                                      extra: {
                                                        'perhaps': perhaps,
                                                        'account': localAccount,
                                                      },
                                                    );
                                                  }
                                                },
                                                child: Text(Keys.next.tr(context)),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: kToolbarHeight,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return WaitPage(
                                height: MediaQuery.of(context).size.height / 2,
                              );
                            },
                            // TODO not use delay
                            future: Future.delayed(Duration(seconds: 1), () => localAccount?.account?.seedPhrase ?? [""]),
                          );
                        }
                        return WaitPage(
                          height: MediaQuery.of(context).size.height / 2,
                        );
                      }),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
