class Strings {
  static final Strings _singleton = Strings._internal();

  String aboutYou = 'About you';

  String aboutYouDesc = 'Please fill this out';

  String faq = 'FAQ';

  String automatic = 'Automatic';

  String shareQr = 'Share yourself';

  String less = 'less';

  String forever = 'forever';

  Strings._internal();

  factory Strings() {
    return _singleton;
  }

  String appName = '2i2i';

  // Generic strings
  String ok = 'OK';
  String talk = 'Talk';
  String cancel = 'Cancel';
  String copyMessage = 'Copied to Clipboard';

  // Logout
  String logout = 'Logout';
  String logoutAreYouSure = 'Are you sure that you want to logout?';
  String logoutFailed = 'Logout failed';

  // Sign In Page
  String signIn = 'Sign in';
  String signInWithEmailPassword = 'Sign in with email and password';
  String goAnonymous = 'Go anonymous';
  String or = 'or';
  String signInFailed = 'Sign in failed';

  // Home page
  String homePage = 'Home Page';
  String home = 'Home';
  String account = 'Accounts';
  String doneIHaveCopied = 'Done and copied';
  String profile = 'Profile';
  String settings = 'Settings';
  String searchUserHint = 'Search user';

  // Jobs page
  String search = 'Search';

  // Entries page
  String myAccount = 'My Account';

  // Account page
  String bidsIn = 'Bids In';
  String bidsInPage = 'Bids In Page';
  String topAppBarTitle = '2i2i';
  String newCardTitle = 'New Card';

  //User Info page
  String createABid = 'Create a bid';
  String algoSec = 'μAlgo/s';
  String speed = 'Speed';
  String bidAmount = 'Bid Amount';
  String note = 'Note (optional)';
  String bidNote = 'Say something awesome';

  //SetUp User page
  String yourBioHint = 'I love to #talk and #cook\nI can #teach';
  String yourNameHint = 'My cool username';
  String writeYourBio = 'Write your bio';
  String writeYourName = 'Write your name';
  String bioExample = 'Ex: I like #cooking #basketball';
  String save = 'Save';
  String required = 'Required';
  String setUpAccount = 'Setup Account';
  String userName = 'Username';
  String bio = 'Bio';
    String addAccount = 'Add account';
  String walletAccount = 'Wallet account';
  String walletAccountMsg = 'I want to connect a 3rd party wallet';

  String recoverPassphrase = 'Recover with passphrase';
  String recoverPassPhaseMsg = 'I know the 25 secret words';

  String addLocalAccount = 'Add local account';
  String addLocalAccountMsg = 'Create a local account on this device';

  String estMaxDuration = 'Est.max duration';
  String swipeAndChangeAccount = 'Swipe Below Card Left or Right to change account';

  String insufficientBalance = 'Insufficient balance';
  String addBid = 'Add bid';

  String copyAndNext = 'Copy and Next';
  String report = 'Report';
  String block = 'Block';
  String unBlock = 'Unblock';
  String seeMore = 'see more';


   //App Rating
  String appRatingTitle = 'Did you like this meeting?';
  String appRatingMessage = 'Any feedback?';
  String appRatingSubmitButton = 'Submit';

  //App Setting
  String selectNetworkMode = 'Select Network Mode:';
  String themeMode = 'Color Scheme:';

  //My Profile
  String myProfile = 'My Profile';
  String bidIn = 'Bid in';
  String bidOut = 'Bid out';
  String noBidFound = 'No bids found';

  //Meeting History
  String meetingsHistory = 'Meetings History';
  String history = 'History';

  String friendList = 'Friend list';
}
