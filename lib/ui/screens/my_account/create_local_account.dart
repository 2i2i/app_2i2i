import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/accounts/local_account.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/infrastructure/routes/app_routes.dart';
import 'package:app_2i2i/ui/screens/app/wait_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../commons/custom_alert_widget.dart';

class CreateLocalAccount extends ConsumerStatefulWidget {
  const CreateLocalAccount({Key? key}) : super(key: key);

  @override
  _CreateLocalAccountState createState() => _CreateLocalAccountState();
}

class _CreateLocalAccountState extends ConsumerState<CreateLocalAccount> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.watch(myAccountPageViewModelProvider).addLocalAccount();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final myAccountPageViewModel = ref.watch(myAccountPageViewModelProvider);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              Keys.createLocalAccount.tr(context),
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(height: 5),
            Text(
              Keys.createLocalAccountWarning.tr(context),
              style: Theme.of(context).textTheme.caption,
            ),
            SizedBox(height: 6),
            Expanded(
              child: Builder(builder: (context) {
                if (!myAccountPageViewModel.isLoading) {
                  LocalAccount? localAccount = myAccountPageViewModel.localAccount;
                  return FutureBuilder(
                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        List<String> perhaps = snapshot.data;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GridView.count(
                                  shrinkWrap: true,
                                  crossAxisCount: 2,
                                  childAspectRatio: 5,
                                  padding: EdgeInsets.all(8),
                                  children: List.generate(perhaps.length, (index) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Theme.of(context).primaryColor,
                                        radius: 10,
                                        child: Text(
                                          '${index + 1}',
                                          style: Theme.of(context).textTheme.caption,
                                        ),
                                      ),
                                      minLeadingWidth: 10,
                                      title: Text(
                                        '${perhaps[index]}',
                                        style: Theme.of(context).textTheme.bodyText2,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
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
                                SizedBox(width: 8),
                                Expanded(
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
                              ],
                            ),
                          ],
                        );
                      }
                      return WaitPage(
                        height: MediaQuery.of(context).size.height / 2,
                      );
                    },
                    // TODO not use delay: ==> done
                    future: Future.value(localAccount?.account?.seedPhrase ?? [""]),
                  );
                }
                return WaitPage(
                  height: MediaQuery.of(context).size.height / 2,
                );
              }),
            ),
            SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
