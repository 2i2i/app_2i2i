import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppSettingPage extends ConsumerStatefulWidget {
  @override
  _AppSettingPageState createState() => _AppSettingPageState();
}

class _AppSettingPageState extends ConsumerState<AppSettingPage> {
  int _value = 1;

  List<String> networkList = ["Main", "Test", "Both"];

  @override
  void initState() {
    getMode();
    super.initState();
  }

  Future<void> getMode() async {
    String? mode =
        await ref.read(algorandProvider).getNetworkMode();
    int itemIndex = networkList.indexWhere((element) => element == mode);
    if (itemIndex < 0) {
      itemIndex = 0;
    }
    setState(() {
      _value = itemIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    var algorand = ref.watch(algorandProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('App Settings'),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.navigate_before,
              size: 40,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15),
            Text('Select Network Mode:',
                style: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                  child: DropdownButton(
                    isExpanded: true,
                    focusColor: Colors.transparent,
                    underline: Container(),
                    value: _value,
                    borderRadius: BorderRadius.circular(10),
                    items: List.generate(
                        networkList.length,
                        (index) => DropdownMenuItem(
                              child: Text(networkList[index]),
                              value: index,
                            )),
                    onChanged: (int? value) async {
                      setState(() {
                        _value = value!;
                      });
                      await algorand.setNetworkMode(networkList[_value].toString());
                    },
                  ),
                ),
              ),
            ),
            Divider()
          ],
        ),
      ),
    );
  }
}
