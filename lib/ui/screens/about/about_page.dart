import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  Widget paragraph(BuildContext context, String header, List<String> lines) {
    return Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Column(children: [
          SizedBox(
            height: 30,
          ),
          Align(
            child: Text(
              header,
              style: Theme.of(context).textTheme.headline5,
            ),
            alignment: Alignment.centerLeft,
          ),
          ...lines
              .map((l) => Align(
                    child: Text(
                      l,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    alignment: Alignment.centerLeft,
                  ))
              .toList(),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Image.asset(
            'assets/logo.png',
            scale: 4,
          ),
          padding: const EdgeInsets.only(left: 10),
        ),
      ),
      body: ListView(
        children: [
          paragraph(context, 'What is 2i2i', [
            '• 2i2i is a blockchain based market for live video calls.',
            '• Each user can bid to have a live video call with another user.',
            '• If the bid is accepted by the user, a smart contract keeps and distributes the coins at the end of the call, according to the call duration.'
          ]),
          paragraph(context, 'Target audience', [
            '• Anyone with an internet connection can earn coins by talking.',
            '• Examples include: tutors, people with fans, somone with an ear to listen, etc.'
          ]),
          paragraph(
              context, 'Zero credit risk', ['• 2i2i never gets your coins.', '• The coins are transfered from one user to another via a smart contract.']),
          paragraph(context, 'Full privacy',
              ['• The live video calls are end-to-end encrypted and peer-to-peer.', '• Meaning we never see data, plus its encrypted.']),
          paragraph(context, 'Coin agnostic', [
            '• Use any coin on the Algorand blockchain.',
          ]),
          paragraph(context, 'App', [
            '• 2i2i is currently available as a web app (beta version) on the Algorand testnet and mainnet.',
            '• Android and iOS versions are also implemented and will be available soon.',
          ]),
          paragraph(context, 'Security', [
            '• Algorand is arguably the safest blockchain (e.g. fork-free, post quantum crypto).',
            '• 2i2i creates an Algorand accounts for you and keeps them locally (non-custodial).',
            '• The account private keys are stored encrypted and in private storage (WebCrypto, Keychain).',
            '• In the future, 2i2i will allow the use of other wallets (WalletConnect).',
          ]),
          paragraph(context, 'Vision', [
            '• Release beta version with quasi full functionality.',
            '• Improve UI and UX to make app simple to use for "all" kinds of users.',
            '• Market 2i2i to add value to anyone with internet.',
            '• Release 1.0  2022-02-02 together with ICO.',
          ]),
          paragraph(context, 'Join US', [
            '• UI: Can you help us design a beautiful UI?',
            '• UX: Can you help us make a super simple UX?',
            '• App: Can you help us with flutter?',
            '• Community: Can you help us create and maintain a community?',
          ]),
          ListTile(
              title: RichText(
                  text: TextSpan(
            text: 'contact us @2i2i_app',
            style: new TextStyle(color: Colors.blue),
            recognizer: new TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse('https://twitter.com/2i2i_app')),
          ))),
        ],
      ),
    );
  }
}
