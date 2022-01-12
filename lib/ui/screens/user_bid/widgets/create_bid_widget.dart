import 'dart:developer';

import 'package:app_2i2i/infrastructure/data_access_layer/accounts/abstract_account.dart';
import 'package:app_2i2i/infrastructure/providers/add_bid_provider/add_bid_page_view_model.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../infrastructure/commons/strings.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../commons/custom_text_field.dart';
import '../../my_account/widgets/account_info.dart';

class CreateBidWidget extends ConsumerStatefulWidget {
  final String uid;

  const CreateBidWidget({Key? key, required this.uid}) : super(key: key);

  @override
  _CreateBidWidgetState createState() => _CreateBidWidgetState();
}

class _CreateBidWidgetState extends ConsumerState<CreateBidWidget>
    with SingleTickerProviderStateMixin {
  AbstractAccount? account;
  int speedNum = 0;
  String note = '';

  final controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    final myAccountPageViewModel = ref.watch(myAccountPageViewModelProvider);
    if (myAccountPageViewModel is AsyncLoading ||
        myAccountPageViewModel is AsyncError) {
      return WaitPage(isCupertino: true);
    }
    final addBidPageViewModel =
        ref.watch(addBidPageViewModelProvider(widget.uid).state).state;
    if (addBidPageViewModel == null) return WaitPage(isCupertino: true);
    if (addBidPageViewModel.submitting) return WaitPage(isCupertino: true);
    if (myAccountPageViewModel.accounts?.isNotEmpty ?? false) {
      account ??= myAccountPageViewModel.accounts!.first;
    }
    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      Strings().createABid,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).disabledColor,
                          ),
                    ),
                  ),
                  IconButton(
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close),
                    iconSize: 18,
                  )
                ],
              ),
              Divider(thickness: 1),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: CustomTextField(
                  title: Strings().bidAmount,
                  hintText: "0",
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          '${Strings().algoSec}',
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(
                                  color: Theme.of(context).shadowColor,
                                  fontWeight: FontWeight.normal),
                        ),
                      ),
                      SizedBox(width: 8)
                    ],
                  ),
                  onChanged: (String? val) {
                    val ??= '';
                    speedNum = (num.tryParse(val) ?? 0).toInt();
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: CustomTextField(
                  title: Strings().note,
                  hintText: Strings().bidNote,
                  onChanged: (String? val) {
                    val ??= '';
                    note = val;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  tileColor: Colors.white,
                  leading: SvgPicture.asset(
                    'assets/icons/hour_glass.svg',
                    height: 20,
                    width: 20,
                  ),
                  // leading: Container(color: Colors.grey,height: 30,width: 30,),
                  title: Text('Est. max duration'),
                  trailing: Builder(builder: (context) {
                    if (account != null && account!.balances.isNotEmpty) {
                      return Text(
                        addBidPageViewModel.duration(
                            account!, speedNum, account!.balances.first),
                      );
                    }
                    return Container();
                  }),
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  minHeight: 150,
                  maxHeight: 200,
                ),
                child: PageView.builder(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  itemCount: myAccountPageViewModel.accounts?.length ?? 0,
                  itemBuilder: (_, index) {
                    return AccountInfo(
                      false,
                      key: ObjectKey(
                          myAccountPageViewModel.accounts![index].address),
                      account: myAccountPageViewModel.accounts![index],
                    );
                  },
                  onPageChanged: (int val) {
                    account = myAccountPageViewModel.accounts?.elementAt(val);
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
              ),
              Visibility(
                visible: (myAccountPageViewModel.accounts?.length ?? 0) > 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: null,
                      icon: Icon(Icons.arrow_back_outlined),
                    ),
                    Expanded(
                      child: Text(
                        'Swipe Below Card Left or Right to change account',
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                    IconButton(
                      onPressed: null,
                      icon: Icon(Icons.arrow_forward_outlined),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                child: ElevatedButton(
                  onPressed: isInsufficient(account)
                      ? null
                      : () {
                          onAddBid();
                        },
                  child: Text(getConfirmSliderText()),
                ),
              ),
              /*Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ConfirmationSlider(
                  onConfirmation: () {
                    onAddBid();
                  },
                  height: 50,
                  width: getWidthForSlider(context),
                  backgroundShape: BorderRadius.circular(12),
                  backgroundColor: Color(0xffD2D2DF),
                  thumbColor: isInsufficient(account)?Theme.of(context).errorColor:Theme.of(context).primaryColorDark,
                  shadow: BoxShadow(
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                  text: getConfirmSliderText(),
                  textStyle: isInsufficient(account)
                      ? Theme.of(context)
                          .textTheme
                          .bodyText2
                          ?.copyWith(color: Theme.of(context).errorColor)
                      : null,
                ),
              ),*/
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  int getBalanceOfAccount(AbstractAccount? account) {
    if (account?.balances.isNotEmpty ?? false) {
      return account!.balances.first.assetHolding.amount;
    }
    return 0;
  }

  onAddBid() async {
    if (isInsufficient(account)) {
      return;
    }
    final addBidPageViewModel =
        ref.read(addBidPageViewModelProvider(widget.uid).state).state;
    if (addBidPageViewModel is AddBidPageViewModel) {
      if (!addBidPageViewModel.submitting) {
        await connectCall(addBidPageViewModel: addBidPageViewModel);
        Navigator.of(context).maybePop();
      }
    }
  }

  double getWidthForSlider(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 200;
    if (width <= 250) {
      return 250;
    }
    return width;
  }

  String getConfirmSliderText() {
    if (account is AbstractAccount) {
      if (isInsufficient(account)) {
        return 'Insufficient balance';
      }
    }
    // return 'Swipe for bid';
    return 'Add bid';
  }

  isInsufficient(AbstractAccount? account) {
    return getBalanceOfAccount(account) < speedNum;
  }

  Future connectCall({required AddBidPageViewModel addBidPageViewModel}) async {
    CustomDialogs.loader(true, context);
    var value = await addBidPageViewModel.addBid(
      account: account,
      balance: account?.balances.first,
      speedNum: speedNum,
      note: note,
    );
    log('$value');
    CustomDialogs.loader(false, context);
  }
}
