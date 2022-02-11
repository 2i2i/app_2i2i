class Routes {
  static const root = '/';

  static const search = '/search';
  static const myHangout = '/myHangout';
  static const setting = '/setting';
  static const bidOut = '/bidOut';

  static const account = '/account';
  static const faq = '/faq';
  static const language = '/language';
  static const login = '/login';
  static const lock = '/lock';
  static const top = '/top';
  static const blocks = '/blocks';
  static const favorites = '/favorites';
  static const hangoutSetting = '/hangoutSetting';
  static const recover = '/recover';
  static const createLocalAccount = '/createLocalAccount';

  static const user = '/user/:uid';
  static const createBid = '/addBid';
  static const ratings = '/rating/:uid';

  static const verifyPerhaps = '/verifyPerhaps';

  static const meetingHistory = '/meetingHistory';
}

extension name on String{
  String nameFromPath(){
    switch (this) {
      case Routes.root:
        return 'root';
      case Routes.search:
        return 'search';
      case Routes.myHangout:
        return 'myHangout';
      case Routes.bidOut:
        return 'bidOut';
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
      case Routes.hangoutSetting:
        return 'hangoutSetting';
      case Routes.recover:
        return 'recover';
      case Routes.user:
        return 'user';
      case Routes.createBid:
        return 'addBid';
      case Routes.ratings:
        return 'rating';
      case Routes.createLocalAccount:
        return 'createLocalAccount';
      case Routes.account:
        return 'account';
      case Routes.faq:
        return 'faq';
      case Routes.language:
        return 'language';
      case Routes.meetingHistory:
        return 'meetingHistory';
      default:
        return this;
    }
  }
}