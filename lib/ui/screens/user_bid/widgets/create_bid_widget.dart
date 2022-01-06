import 'dart:developer';

import 'package:app_2i2i/infrastructure/data_access_layer/accounts/abstract_account.dart';
import 'package:app_2i2i/infrastructure/providers/add_bid_provider/add_bid_page_view_model.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:app_2i2i/ui/commons/slide_to_confirm.dart';
import 'package:flutter/cupertino.dart';
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
    if(myAccountPageViewModel is AsyncLoading || myAccountPageViewModel is AsyncError){
      return Center(child: CupertinoActivityIndicator());
    }
    if(myAccountPageViewModel.accounts?.isNotEmpty??false) {
      account ??= myAccountPageViewModel.accounts!.first;
    }
    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
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
                    if(mounted) {
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
              Container(
                constraints: BoxConstraints(
                  minHeight: 150,
                  maxHeight: 200,
                ),
                child: myAccountPageViewModel.isLoading
                    ? Center(child: CupertinoActivityIndicator())
                    : Row(
                        children: [
                          IconButton(
                              iconSize: 10,
                              onPressed: () => controller.previousPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.decelerate),
                              icon: RotatedBox(
                                  quarterTurns: 2,
                                  child: SvgPicture.asset(
                                      'assets/icons/direction.svg'))),
                    Expanded(
                      child: PageView.builder(
                              controller: controller,
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  myAccountPageViewModel.accounts?.length ?? 0,
                              itemBuilder: (_, index) {
                                return AccountInfo(
                                  key: ObjectKey(myAccountPageViewModel
                                      .accounts![index].address),
                                  account:
                                      myAccountPageViewModel.accounts![index],
                                );
                              },
                              onPageChanged: (int val) {
                                account = myAccountPageViewModel.accounts
                                    ?.elementAt(val);
                              },
                            ),
                          ),
                          IconButton(
                            iconSize: 10,
                            onPressed: () => controller.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.decelerate,
                            ),
                            icon: SvgPicture.asset(
                              'assets/icons/direction.svg',
                            ),
                          ),
                        ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              ),
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
    if(isInsufficient(account)){
      return;
    }
    final addBidPageViewModel = ref.read(addBidPageViewModelProvider(widget.uid).state).state;
    if (addBidPageViewModel is AddBidPageViewModel) {
      if(!addBidPageViewModel.submitting ) {
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
    return 'Swipe for bid';
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