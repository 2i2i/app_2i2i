import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/ui/screens/faq/faq_page_base.dart';
import 'package:flutter/material.dart';
import 'faq.dart';

class FAQPage extends StatelessWidget {
  FAQPage({Key? key}) : super(key: key);

  final List<FAQData> faqs = [
    FAQData(
        title: 'What is 2i2i?',
        description:
            '2i2i is the place for you to hang out. Every user on 2i2i can be a Guest and a Host. 2i2i provides a safe and private space for Guests and Hosts to meet via live video calls.'),
    FAQData(
        title: 'What is a Guest?',
        description:
            'Guests join the room of a Host. By offering coins (called support) to the Host, the Guest can have a 1-on-1 meeting with the Host.'),
    FAQData(
        title: 'What is a Host?',
        description:
            'Hosts shared their time with Guests and earn coins (called support). The Host sets the minimum support they require.'),
    FAQData(
        title: 'What is a Chrony?',
        description:
            'A Guest that offers exactly the minimum support to their Host. Chronies wait in chronological order.'),
    FAQData(
        title: 'What is a HighRoller?',
        description:
            'A Guest that offers higher than the minimum support to their Host. HighRollers wait in the order of their support.'),
    FAQData(
        title: 'What is an Eccentric*?',
        description:
            'A Guest that offers support using coins of subjective value. E.g. a Guest might offer art or tickets in exchange for a live meeting with the Host.'),
    FAQData(
        title: 'What is a Lurker*?',
        description:
            'A Guest who juist wants to see what is going on. Lurkers do not get to meet the Host. Lurkers can still signal their support by offering less than the minimum set by the Host.'),
    FAQData(
        title: 'What is Importance?',
        description:
            'The Host chooses the relative importance between Chronies and HighRollers. '),
    FAQData(
        title: 'How does the queuing work?',
        description:
            '2i2i forms the fairest queue using the Importance set by the Host, the recent meeting history and the current queue.'),
    FAQData(
        title: 'Why did someone overtake me in the queue?',
        description:
            '2i2i balances Guests into a fair queue according to the settings chosen by the Host.\nE.g. HighRollers can overtake each other by offering higher support.\nE.g. if the Host prefers HighRollers over Chronies, then HighRollers can overtake Chronies.\nE.g. if the Host prefers Chronies over HighRollers, then Chronies can overtake HighRollers.\nE.g. if the Host recently only met one type of Guest, then a differnt type could be moved ahead; to keep balance.'),
    FAQData(
        title: 'What version is it?',
        description:
            '2i2i is still in beta version, which means testing. Please let us know of any erros: https://twitter.com/2i2i_app'),
    FAQData(
        title: 'Who needs 2i2i?',
        description:
            'If you have fans, let your fans out-support each other to see you live. Literally anyone with internet can earn coins just by talking about whatever. Maybe you are a teacher - students can offer support for your time. Or you are just bored and willing to listen to someone; someone will value that and offer support for your time.\nOn the other hand, if you need to talk with someone right now: once we have lots of users on 2i2i, you will find them. Whatever you need, right now.'),
    FAQData(
        title: 'Is 2i2i only for **live** video calls?',
        description:
            "Yes. 2i2i is about having a chat right now - When you feel like it. Going for a walk and would not mind having a chat? Earn extra coins."),
    FAQData(
        title: 'How does 2i2i work?',
        description:
            "A Guest locks up their coins to join the queue of a certain Host. As long as the Host is online, the Host can meet one Guest after another. Once a meeting ends, the locked coins are distributed:\n - to the Host according to the meeting duration\n - to the SYSTEM, 10% of what the Host would have gotten\n - to the Guest, the rest"),
    FAQData(
        title: 'How is the level of support measured?',
        description:
            "The Guest offers support as coins per second. The Guest only pays for as many seconds as it meets the Host."),
    FAQData(
        title: 'Is my Algorand account safe?',
        description:
            "We create an Algorand account for you when you create your user. This account is local to your device. We have no access to it. It is encrypted on your device using amongst the highest standards of cryptography: WebCrypto or Keychains."),
    FAQData(
        title: 'Can I use other wallets?',
        description:
            "Yes, you can use any wallet that connects with WalletConnect. E.g. the official Algorand Wallet."),
    FAQData(
        title: 'Is 2i2i available on Algorand testnet?',
        description: "Yes, 2i2i.app runs mainnet and test.2i2i.app on testnet"),
    FAQData(
        title: 'How does the Algorand system work?',
        description:
            "2i2i never gets the users' coins. The Guests' coins are locked in a smart contract during the meeting. When the meeting ends, the smart contract divides the coins amongst the Guest, the Host and the SYSTEM. Unused coins are sent back to the Guest.\nWe plan on decentralizing the design further to reduce reliance on the SYSTEM."),
    FAQData(
        title: 'Can I use fiat?',
        description:
            "Through other services such ChangeNow.io (no aff.), you can exchange your fiat into ALGO."),
    FAQData(
        title: 'Are the video calls private?',
        description:
            "Yes. All video calls are end-to-end encrypted. All calls are also peer-to-peer. This means 2i2i never sees anything from your call. The Guest and the Host connect directly to each other."),
    FAQData(
        title: 'How about audio only calls?',
        description:
            "We are thinking about that. The issue is that an audio call is usually worth less. Audio and video calls are separate markets. Should we combine them?"),
    FAQData(
        title: 'What is the meaning of energy?',
        description:
            "Coins are a form of energy. Arguably, coins are the most efficient storage of energy. Any person could build a house, losing energy, sell the house and get coins in exchange. Years later, this person can exchange the coins to for someone putting energy into making another house. Hence, the coins stored energy over a long time period efficiently."),
    FAQData(
        title: 'What is the meaning of info?',
        description:
            "The Host provides info in exchange for energy/coins. The Host has something to say or show that convinces other Guests to offer support for."),
    FAQData(
        title: 'Is 2i2i a market?',
        description:
            "Yes, 2i2i is an efficient market to exchange energy and info. Each Host has their own market and represents the entire supply of that market. Guests for that Host represent the demand. Chronies offer a fixed price set by the Host (supplier). HighRollers allow the Host to see demand above the fixed price. Lurkers* help the Host see the demand below the fixed price. Lastly, Eccentrics offer demand using coins with subjective value."),
    FAQData(
        title: 'Does 2i2i have its own coin?',
        description:
            "We do not promote any specific coin. The Guest can bid for the Host using any coin (ASA) they like. Although the technology is all set up for this, we believe that starting only with ALGO and then adding coins over time will solve the problem of liquidity better."),
    FAQData(
        title: 'Can I use any coin/token/ASA?',
        description:
            "Yes. Anything on Algorand. On Algorand, to use a new coin, accounts have to opt-in. If 2i2i is not opted-into your coin yet, you can opt-in the system simply by offering support. You would have to provide the ALGOs necessary for 2i2i to opt-in (0.202 ALGO). Although the technology is all set up for this, we believe that starting only with ALGO and then adding coins over time will solve the problem of liquidity better."),
    FAQData(
        title: 'Why Algorand?',
        description:
            "Using a blockhain, the users coins are never sent to us. Users transact via smart contracts. This means 0 credit risk. There is nothing to hack and we cannot steal anything. No risk for the user."),
    FAQData(
        title: 'How does offering support work?',
        description:
            "The Guest only needs to choose the maximum duration of their meeting. The level of support is set by the Host. The Guest can see how many coins they would lock up and the estimated waiting time. A Guest can choose to offer higher support, which might allow the Guest to skip parts of the queue."),
    FAQData(
        title: 'How does the bio/name work?',
        description:
            "Use # to declare your keywords. Keywords are used to search for Hosts."),
    FAQData(
        title: 'Does 2i2i have access to the smart contract?',
        description:
            "2i2i created the smart contract and currently has access to it. This means, 2i2i can modify the smart contract and extract funds from the account. The plan is to remove that access. We are keeping access for now until all it is \"battle tested\". Until then, We will sometimes need to unlock users' coins for them if an unexpected case occurs. Once we are confident that nobody's coins are left locked in the smart contract indefinitely, We will remove our access from the smart contract."),
    FAQData(
        title: 'Why did I not get my coins (as a Host)?',
        description:
            'If the account where you should have received coins is empty, you cannot receive less than 0.1 ALGO. This is an Algorand restriction. Once your "left-over" coins accumulate to at least 0.1 ALGO, we will initiate the transfer for you. This process will soon be automated.'),
    FAQData(
        title: 'Is it ok to have an empty account as a Host?',
        description:
            'No. If the account where you should have received coins is empty, you cannot receive less than 0.1 ALGO. This is an Algorand restriction. Once your "left-over" coins accumulate to at least 0.1 ALGO, we will initiate the transfer for you. This process will soon be automated.'),
    FAQData(
        title: 'Why is my camera not released after the meeting ends?',
        description: 'It\'s a bug. The app is not using your camera anymore, but it still has a lock on it. We hope to fix it soon.'),
  ];

  @override
  Widget build(BuildContext context) {
    return FAQPageBase(
      title: Keys.faq.tr(context),
      faqs: faqs,
      contactText: 'twitter',
      contactUrl: 'https://twitter.com/2i2i_app',
    );
  }
}
