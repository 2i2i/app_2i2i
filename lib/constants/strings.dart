class Strings {
  static final Strings _singleton = Strings._internal();

  String aboutYou = 'About you';

  String aboutYouDesc = 'Fill below form to communicate with cool people';

  Strings._internal();

  factory Strings() {
    return _singleton;
  }

  String appName = '2i2i';

  // Generic strings
  String ok = 'OK';
  String talk = 'Talk';
  String cancel = 'Cancel';

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
  String account = 'Account';
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

   //App Rating
  String appRatingTitle = 'Did you like this meeting?';
  String appRatingMessage = 'Write your feedback to this meeting.';
  String appRatingSubmitButton = 'Submit';

  //App Setting
  String selectNetworkMode = 'Select Network Mode:';
  String themeMode = 'Color Scheme:';

  //My Profile
  String myProfile = 'My Profile';
  String bidIn = 'Bid in';
  String bidOut = 'Bid out';
  String noBidFound = 'No bid found';

  //Meeting History
  String meetingsHistory = 'Meetings History';
}
