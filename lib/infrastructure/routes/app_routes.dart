/*class Routes {
  *//*static const ROOT = '/';
  static const LOGIN = '/login';
  static const LOCK = '/lock';
  static const HOME = '/home';
  static const USER = '/user/:uid';
  static const RATING = '/rating';
  static const MY_USER = '/my_user_provider';
  static const SETUP_ACCOUNT = '/setup_account_provider';
  static const TOPPAGE = '/top_page';
  static const BIDPAGE = '/user/:uid/addbidpage';
  static const IMI = '/imi';
  static const SOLLI = '/solli';
  static const ABOUT = '/about';
  static const QRPAGE = '/qr_page';
  static const HISTORY = '/history_provider';
  static const AppSetting = '/app_setting';
  static const CallPage = '/call_page';
  static const FRIENDS = '/friend_page';
  static const CreateBid = '/create_bid';*//*

  static const root = '/';
  static const login = '/login';
  static const lock = '/lock';
  static const top = '/top';
  static const blocks = '/blocks';
  static const favorites = '/favorites';
  static const hangoutSetting = '/hangoutSetting';
  static const recover ='/recover';
  static const createLocalAccount = '/createLocalAccount';
  static const user = '/user';
  static const createBid = '/addBid';
  static const ratings = '/rating';
  static const verifyPerhaps = '/verifyPerhaps';

}*/
class Routes {
  /*static const ROOT = '/';
  static const LOGIN = '/login';
  static const LOCK = '/lock';
  static const HOME = '/home';
  static const USER = '/user/:uid';
  static const RATING = '/rating';
  static const MY_USER = '/my_user_provider';
  static const SETUP_ACCOUNT = '/setup_account_provider';
  static const TOPPAGE = '/top_page';
  static const BIDPAGE = '/user/:uid/addbidpage';
  static const IMI = '/imi';
  static const SOLLI = '/solli';
  static const ABOUT = '/about';
  static const QRPAGE = '/qr_page';
  static const HISTORY = '/history_provider';
  static const AppSetting = '/app_setting';
  static const CallPage = '/call_page';
  static const FRIENDS = '/friend_page';
  static const CreateBid = '/create_bid';*/

  static const root = '/';
  static const login = '/login';
  static const lock = '/lock';
  static const top = '/top';
  static const blocks = '/blocks';
  static const favorites = '/favorites';
  static const hangoutSetting = '/hangoutSetting';
  static const recover ='/recover';
  static const createLocalAccount = '/createLocalAccount';

  static const user = '/user';
  static const createBid = '/addBid';
  static const ratings = '/rating';

  static const verifyPerhaps = '/verifyPerhaps';

}

extension name on String{
  String nameFromPath(){
    switch (this){
      case Routes.root:
        return 'root';
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
      default:
        return this;
    }
  }
}