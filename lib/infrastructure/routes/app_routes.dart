class Routes {
  static const root = '/';

  static const search = '/search';
  static const myUser = '/myUser';
  static const setting = '/setting';
  static const bidOut = '/bidOut';

  static const account = '/account';
  static const redeemCoin = '/redeemCoin';
  static const faq = '/faq';
  static const imi = '/imi';
  static const solli = '/solli';
  static const language = '/language';
  static const login = '/login';
  static const lock = '/lock';
  static const top = '/top';
  static const blocks = '/blocks';
  static const favorites = '/favorites';
  static const userSetting = '/userSetting';
  static const webView = '/webView/:walletAddress';
  static const test = '/test';

  static const user = '/user/:uid';
  static const createBid = '/addBid';
  static const ratings = '/rating/:uid';

  static const meetingHistory = '/meetingHistory';
}

extension name on String {
  String nameFromPath() {
    switch (this) {
      case Routes.root:
        return 'root';
      case Routes.search:
        return 'search';
      case Routes.myUser:
        return 'my_user';
      case Routes.bidOut:
        return 'bid_out';
      case Routes.login:
        return 'login';
      case Routes.lock:
        return 'lock';
      case Routes.top:
        return 'top';
      case Routes.blocks:
        return 'blocks';
      case Routes.favorites:
        return 'favorites';
      case Routes.setting:
        return 'setting';
      case Routes.userSetting:
        return 'user_setting';
      case Routes.user:
        return 'user';
      case Routes.createBid:
        return 'add_bid';
      case Routes.ratings:
        return 'rating';
      case Routes.account:
        return 'account';
      case Routes.faq:
        return 'faq';
      case Routes.imi:
        return 'imi';
      case Routes.solli:
        return 'solli';
      case Routes.language:
        return 'language';
      case Routes.meetingHistory:
        return 'meeting_history';
      case Routes.redeemCoin:
        return 'redeemCoin';
      case Routes.webView:
        return 'web_view';
      default:
        return '';
    }
  }
}
