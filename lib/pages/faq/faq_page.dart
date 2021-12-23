// import 'package:app_2i2i/app/logging.dart';
import 'package:app_2i2i/pages/faq/faq.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FAQPage extends StatefulWidget {
  FAQPage({Key? key}) : super(key: key);

  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  List<FAQData> faqs = [
    FAQData(title: 'What is 2i2i?', description: '''
    2i2i is a market for live video calls.
    Find out the fair value for your time.
    '''),
    FAQData(title: 'What version is it?', description: '''
    2i2i is still in Alpha version, which means testing.
    Just reload the page if it seems stuck.
    Some buttons e.g. work, but seem like they are not working.
    Please click once and have patience.
    Also, the status on the search page is currently always green.
    '''),
    FAQData(title: 'Who needs 2i2i?', description: '''
    Maybe you are a teacher - students can bid for your time.
    Or you are just bored and willing to listen to someone;
    someone will value that and bid for your time
    If you have fans, let your fans outbid each other to see you live.
    Literally anyone with internet can earn coins just by talking
    about whatever.
    '''),
    FAQData(title: 'Is 2i2i only for **live** video calls?', description: '''
    Yes.
    2i2i is about having a chat right now - When you feel like it.
    Going for a walk and would not mind having a chat? Easy extra
    coins.
    '''),
    FAQData(title: 'How does 2i2i work?', description: '''
    Everyone can bid for anyones time.
    Use the **bio** - If people find it interesting, they will bid to talk
    with you. If a bid is attractive, accept it and talk.
    '''),
    FAQData(title: 'What is the meaning of speed?', description: '''
    User A bids for the **speed** of coin transfer from user A
    to user B.
    User B in turn will have a live video call with user A.
    *speed*s are measured in coins/sec.
    '''),
    FAQData(title: 'Is my Algorand my_account safe?', description: '''
    We create an Algorand my_account for you when you create your user.
    This my_account is local to your device. We have no access to it.
    It is encrypted on your device using amongst the highest standards of cryptography: WebCrypto or Keychains.
    '''),
    FAQData(title: 'Can I use other wallets?', description: '''
    Soon. We will add support to use 2i2i with other wallets soon.
    '''),
    FAQData(title: 'Is 2i2i only on the Algorand testnet?', description: '''
    Yes, 2i2i is currently in the alpha version and hence running only on the Algorand testnet.
    '''),
    FAQData(title: 'How does the Algorand system work?', description: '''
    2i2i never gets the users coins. User As coins are locked in a smart contract during the call.
    When the call ends, the smart contract divides the coins amongst user A, user B and the 2i2i fee my_account.
    Unused coins are sent back to user A. The fee is 10% and is used to further improve the system.
    '''),
    FAQData(title: 'Can I use fiat?', description: '''
    Through other services such ChangeNow.io (no aff.), you can exchange your fiat into ALGO.
    '''),
    FAQData(title: 'Are the video calls private?', description: '''
    Yes. All video calls are end-to-end encrypted. All calls are also peer-to-peer.
    This means 2i2i never sees anything from your call. User A and user B connect directly to each other.
    '''),
    FAQData(title: 'How about audio only calls?', description: '''
    We are thinking about that. The issue is that an audio call is usually worth less.
    Audio and video calls are separate markets. Should we combine them?
    '''),
    FAQData(title: 'What is the meaning of energy?', description: '''
    Coins are a form of energy. Arguably, coins are the most efficient storage of energy.
    User A could build a house, losing energy, sell the house and get coins in exchange.
    Years later, user A can exchange the coins to for someone putting energy into making two houses.
    Hence, the coins stored energy over a long time period efficiently.
    '''),
    FAQData(title: 'What is the meaning of info?', description: '''
    User B provides info in exchange for energy/coins. User B has something to say or show
    that convinces other users to bid for.
    '''),
    FAQData(title: 'Does 2i2i have its own coin?', description: '''
    We do not promote any specific coin. User A can bid for user B using any coin they like.
    '''),
    FAQData(title: 'Can I use any coin/token/ASA?', description: '''
    Yes. Anything on Algorand. On Algorand, to use a new coin, accounts have to opt-in.
    If 2i2i is not opted-into your coin yet, you can opt-in the system simply by bidding.
    You would have to provide the ALGOs necessary for 2i2i to opt-in (0.202 ALGO)
    '''),
    FAQData(title: 'Which data of mine do you collect?', description: '''
    Only your basic data for running the app, like your bio, friends list.
    We do not know about your Algorand my_account. It is local on your device.
    We do not see anything of your calls.
    '''),
    FAQData(title: 'Why Algorand?', description: '''
    Using a blockhain, the users coins are never sent to us. Users transact via smart contracts.
    This means 0 credit risk. There is nothing to hack and we cannot steal anything. No risk for the user.
    '''),
    FAQData(title: 'How does bidding work?', description: '''
    Maybe user A bids 5 TACOCOIN/sec. If user B accepts the bid, they are in a video call.
    If the call ends e.g. after 600 seconds, user A will send 3000 TACOCOIN to B. User B will get 2700 TACOCOIN
    and the system will take 300 TACOCOIN.
    '''),
    FAQData(title: 'How does the bio/name work?', description: '''
    Use # to declare your keywords.
    Keywords are used to seach for users.
    '''),
    FAQData(title: 'Does 2i2i have access to the escrow?', description: '''
    2i2i created the escrow my_account (a smart contract) and currently has access to it.
    This means, 2i2i can modify the smart contract and extract funds from the escrow.
    The plan is to remove that access.
    We are keeping access for now until all edge cases are resolved. Until then, we
    will sometimes need to unlock users' coins for them if an unexpected case occurs.
    Once we are confident that nobody's coins are left locked in escrow indefinitely,
    we will remove our access from the smart contract.
    '''),
  ];

  List<FAQ> createFAQWidgets(List<FAQData> faqDataList) {
    List<FAQ> faqList = [];
    for (int i = 0; i < faqDataList.length; i++) {
      Color backgroundColor = i % 2 == 0 ? Color.fromRGBO(223, 239, 223, 1) : Color.fromRGBO(197, 234, 197, 1);
      FAQ faq = FAQ(
          data: faqDataList[i],
          backgroundColor: backgroundColor,
        index: i,
      );
      faqList.add(faq);
    }
    return faqList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('FAQ'),
        ),
        body: Container(
          margin: const EdgeInsets.all(10),
          child: ListView(
            children: [...createFAQWidgets(faqs), contact()],
          ),
        ));
  }

  Widget contact() {
    return ListTile(
        title: RichText(
            text: TextSpan(
      text: 'contact us @2i2i_app',
      style: new TextStyle(color: Colors.blue),
      recognizer: new TapGestureRecognizer()
        ..onTap = () => launch('https://twitter.com/2i2i_app'),
    )));
  }
}
