import 'package:flutter/material.dart';

import '../../models/faq_model.dart';

class FAQProviderModel extends ChangeNotifier {
  List<String> keywordList = [];
  List<String> keywords = [];

  bool isOpenSuggestionView = false;

  final List<FAQDataModel> faqsList = [
    FAQDataModel(
        title: 'What is 2i2i?',
        tags: [
          '2i2i',
          'Guest',
          'hang out',
          'Host',
        ],
        description:
            '2i2i is a market for your time. it is provably the fairest market. it is infinitely dimensional and infinitely inclusive. infinitely dimensional means users can offer any type of coin in exchange for talking with you. infinitely inclusive means that the range of value that you receive in exchange for your time is unlimited. every user on 2i2i can be a Guest and a Host. 2i2i provides a safe and private space for Guests and Hosts to meet via live video calls.'),
    FAQDataModel(
        title: 'What is a Guest?',
        tags: [
          'Guest',
          'support',
        ],
        description: 'Guests join the room of a Host. By offering coins to the Host, the Guest can have a 1-on-1 meeting with the Host.'),
    FAQDataModel(
        title: 'What is a Host?',
        tags: [
          'Host',
        ],
        description: 'Hosts shared their time with Guests and receive energy. The Host sets the minimum coins they require in exchange for its time. the Host also set the max duration per meeting. the Host also sets the importance of Chrony vs HighRoller vs Eccentric'),
    FAQDataModel(
        title: 'What is a Crony?',
        tags: [
          'Crony',
          'Guest',
        ],
        description: 'A Guest that offers exactly the minimum coins to their Host. Cronies wait in chronological order.'),
    FAQDataModel(
        title: 'What is a HighRoller?',
        tags: [
          'Guest',
          'HighRoller',
        ],
        description: 'A Guest that offers higher than the minimum coins to their Host. HighRollers wait in the order of their support.'),
    FAQDataModel(
        title: 'What is an Eccentric*?',
        tags: [
          'Guest',
          'Eccentric',
        ],
        description:
            'A Guest that offers support using coins of subjective value. E.g. a Guest might offer art or tickets in exchange for a live meeting with the Host.'),
    FAQDataModel(
        title: 'What is a Lurker*?',
        tags: [
          'Guest',
          'Lurker',
        ],
        description:
            'A Guest who just wants to see what is going on. Lurkers do not get to meet the Host. Lurkers can still signal their support by offering less than the minimum set by the Host.'),
    FAQDataModel(
        title: 'What is Importance?',
        tags: [
          'importance',
        ],
        description: 'The Host chooses the relative importance between Chronies (c), HighRollers (h) and Eccentrics (e). 2i2i allows everyone to get their turn. on average, per n=c+h+e Guests, there will be c/n Chrony, h/n HighRoller, e/n Eccentric'),
    FAQDataModel(
        title: 'How does the queuing work?',
        tags: [
          'fairest',
          'queue',
          'importance',
        ],
        description: '2i2i forms the fairest queue using the Importance set by the Host, the recent meeting history and the current queue.'),
    FAQDataModel(
        title: 'Why did someone overtake me in the queue?',
        tags: [],
        description:
            '2i2i balances Guests into a fair queue according to the settings chosen by the Host.\nE.g. HighRollers can overtake each other by offering higher support.\nE.g. if the Host prefers HighRollers over Cronies, then HighRollers can overtake Cronies.\nE.g. if the Host prefers Cronies over HighRollers, then Cronies can overtake HighRollers.\nE.g. if the Host recently only met one type of Guest, then a different type could be moved ahead; to keep balance.'),
    FAQDataModel(
        title: 'What version is it?',
        tags: [
          'version',
        ],
        description: '2i2i is live on mainnet. Please let us know of any errors: https://twitter.com/2i2i_app'),
    FAQDataModel(
        title: 'Who needs 2i2i?',
        tags: [
          'fans',
          'coins',
          'earn',
          'talking',
          'student',
          'teacher',
        ],
        description:
            'If you have fans, let your fans out-support each other to see you live. Literally anyone with internet can receive energy just by talking about whatever. Maybe you are a teacher - students can offer support for your time. Or you are just bored and willing to listen to someone; someone will value that and offer support for your time.\nOn the other hand, if you need to talk with someone right now: once we have lots of users on 2i2i, you will find them. Whatever you need, right now.'),
    FAQDataModel(
        title: 'Is 2i2i only for **live** video calls?',
        tags: [
          'now',
        ],
        description:
            "Yes. 2i2i is about having a chat right now - When you feel like it. Going for a walk and would not mind having a chat? Receive extra coins."),
    FAQDataModel(
        title: 'How does 2i2i work?',
        tags: [
          'system',
        ],
        description:
            "A Guest locks up their coins to join the queue of a certain Host. the Host can meet one Guest after another. Once a meeting ends, the locked coins are distributed:\n - to the Host according to the meeting duration\n - to the SYSTEM, 10% of what the Host would have gotten\n - to the Guest, the rest"),
    FAQDataModel(
        title: 'How is the level of support measured?',
        tags: [],
        description: "The Guest offers support as coins per second. The Guest only pays for as many seconds as it meets the Host."),
    FAQDataModel(
        title: 'Is this safe?',
        tags: [
          'Algorand',
          'safe',
        ],
        description:
            "we do not store any private keys. all your accounts are connected using WalletConnect to your own wallet app"),
    FAQDataModel(
        title: 'Can I use other wallets?',
        tags: [
          'Algorand',
          'wallet',
          'WalletConnect',
        ],
        description: "Yes, you can use any wallet that connects with WalletConnect. E.g. Pera."),
    FAQDataModel(
        title: 'How does the Algorand system work?',
        tags: [
          'smart contract',
          'system',
          'decentralizing',
        ],
        description:
            "2i2i never gets the users' coins. The Guests' coins are locked in a smart contract during the meeting. When the meeting ends, the smart contract divides the coins amongst the Guest, the Host and the SYSTEM. Unused coins are sent back to the Guest.\nWe plan on decentralizing the design further to reduce reliance on the SYSTEM."),
    FAQDataModel(
        title: 'Can I use fiat?',
        tags: [
          'ChangeNow',
          'ALGO',
          'exchange',
        ],
        description: "Through other services such ChangeNow.io (no aff.), you can exchange your fiat into ALGO."),
    FAQDataModel(
        title: 'Are the video calls private?',
        tags: [
          'video',
          'encrypted',
          'private',
          '2i2i',
        ],
        description:
            "Yes. All video calls are end-to-end encrypted. All calls are also peer-to-peer. This means 2i2i never sees anything from your call. The Guest and the Host connect directly to each other."),
    FAQDataModel(
        title: 'How about audio only calls?',
        tags: ['audio', 'roadmap'],
        description:
            "you can mute video or audio during the call"),
    FAQDataModel(
        title: 'What is the meaning of energy?',
        tags: [
          'energy',
          'efficient',
          'storage',
        ],
        description:
            "Coins are a form of energy. Arguably, coins are the most efficient storage of energy. Any person could build a house, losing energy, sell the house and get coins in exchange. Years later, this person can exchange the coins to for someone putting energy into making another house. Hence, the coins stored energy over a long time period efficiently."),
    FAQDataModel(
        title: 'What is the meaning of info?',
        tags: [
          'Host',
        ],
        description:
            "The Host provides info in exchange for energy/coins. The Host has something to say or show that convinces other Guests to offer support for."),
    FAQDataModel(
        title: 'Is 2i2i a market?',
        tags: [
          'energy/coins',
          'HighRoller',
          'Lurker',
          'Eccentric',
        ],
        description:
            "Yes, 2i2i is an efficient market to exchange energy and info. Each Host has their own market and represents the entire supply of that market. Guests for that Host represent the demand. Chronies offer a fixed price set by the Host (supplier). HighRollers allow the Host to see demand above the fixed price. Lurkers* help the Host see the demand below the fixed price. Lastly, Eccentrics offer demand using coins with subjective value."),
    FAQDataModel(
        title: 'Does 2i2i have its own coin?',
        tags: [
          'ALGO',
          'ASA',
        ],
        description:
            "yes, there is a 2i2i coin. after each meeting, you get some 2i2i coins. these coins represent ownership in the project. e.g. decisions about changes and such will be governed via the 2i2i coin."),
    FAQDataModel(
        title: 'Can I use any coin/token/ASA?',
        tags: [
          'ASA',
          'Algorand',
          'support',
        ],
        description:
            "Yes. Anything on Algorand. currently, only objective value coins are supported. subjective value coins support is coming/"),
    FAQDataModel(
        title: 'Why Algorand?',
        tags: [
          'ASA',
          'Algorand',
        ],
        description:
            "Using a blockhain, the users coins are never sent to us. Users transact via smart contracts. This means 0 credit risk. There is nothing to hack and we cannot steal anything. No risk for the user."),
    FAQDataModel(
        title: 'How does offering coins work?',
        tags: [
          'Guest',
        ],
        description:
            "The Guest only needs to choose the maximum duration of their meeting. The level of coins is set by the Host. The Guest can see how many coins they would lock up and the estimated waiting time. A Guest can choose to offer more coins, which might allow the Guest to skip parts of the queue."),
    FAQDataModel(
        title: 'How does the bio/name work?',
        tags: [
          'keywords',
          'Host',
        ],
        description: "Use # to declare your keywords. Keywords are used to search for Hosts."),
    FAQDataModel(
        title: 'Does 2i2i have access to the smart contract?',
        tags: [
          'smart contract',
          'coins',
          'unlock',
        ],
        description:
            "2i2i created the smart contract and currently has access to it. This means, 2i2i can modify the smart contract and extract funds from the account. The plan is to remove that access. We are keeping access for now until all it is \"battle tested\". Until then, We will sometimes need to unlock users' coins for them if an unexpected case occurs. Once we are confident that nobody's coins are left locked in the smart contract indefinitely, We will remove our access from the smart contract."),
    FAQDataModel(
        tags: ['account', 'Algorand', 'minimum balance'],
        title: 'Why did I not get my coins (as a Host)?',
        description:
            'in your redeem page, you might see coins that the smart contract was not able to send to your account. reasons can be that your account is not opted-into that coin or that it is empty. just add some ALGO to your account or opt it into the coin and redeem.'),
  ];

  List<FAQDataModel> searchFAQList = [];

  initKeywordList() {
    faqsList.forEach((element) {
      element.tags?.forEach((tagElement) {
        if (!keywordList.contains(tagElement.toLowerCase())) {
          keywords.add(tagElement.toLowerCase());
        }
      });
    });
    keywords.toSet().toList();
  }

  addInKeywordList(value) {
    keywordList.add(value.toString().toLowerCase());
    refreshList();
    notifyListeners();
  }

  openCloseSuggestionView() {
    isOpenSuggestionView = !isOpenSuggestionView;
    notifyListeners();
  }

  removeInKeywordList(value) {
    keywordList.removeWhere((element) => element == value);
    refreshList();
    notifyListeners();
  }

  refreshList() {
    searchFAQList = faqsList.where((element) => element.tags!.any((searchKeyword) => keywordList.contains(searchKeyword.toLowerCase()))).toList();
  }
}
