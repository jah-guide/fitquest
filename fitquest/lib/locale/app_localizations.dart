// fitquest/lib/locale/app_localizations.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:intl/intl.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'FitQuest',
      'welcome': 'Welcome',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'displayName': 'Display Name',
      'createAccount': 'Create Account',
      'noAccount': "Don't have an account?",
      'hasAccount': 'Already have an account?',
      'signUp': 'Sign Up',
      'signIn': 'Sign In',
      'home': 'Home',
      'exercises': 'Exercises',
      'profile': 'Profile',
      'settings': 'Settings',
      'logout': 'Logout',
      'logoutConfirm': 'Are you sure you want to logout?',
      'cancel': 'Cancel',
      'save': 'Save',
      'editProfile': 'Edit Profile',
      'newPassword': 'New Password',
      'keepPassword': 'leave empty to keep current',
      'profileUpdated': 'Profile updated successfully!',
      'chest': 'Chest',
      'back': 'Back',
      'legs': 'Legs',
      'arms': 'Arms',
      'shoulders': 'Shoulders',
      'core': 'Core',
      'workouts': 'Workouts',
      'minutes': 'Minutes',
      'startWorkout': 'Start Workout',
      'progress': 'Progress',
      'viewExercises': 'View exercises and workouts',
      'readyWorkout': 'Ready for your next workout?',
      'todaySummary': "Today's Summary",
      'quickActions': 'Quick Actions',
      'fitnessJourney': 'Your Fitness Journey Starts Here',
      'startJourney': 'Start your fitness journey today',
      'joinFitQuest': 'Join FitQuest',
      'required': 'is required',
      'enterValid': 'Please enter a valid',
      'minLength': 'must be at least 6 characters',
      'chooseLanguage': 'Choose Language',
      'languageChangedTo': 'Language changed to',
      'passwordMismatch': 'Passwords do not match',
      'fitnessEnthusiast': 'Fitness Enthusiast',
      'noDisplayName': 'No display name',
      'noEmail': 'No email',
      'error': 'Error',
      'language': 'Language',
      'notifications': 'Notifications',
      'notificationsOn': 'Notifications enabled',
      'notificationsOff': 'Notifications disabled',
      'systemDefault': 'System default',
      'light': 'Light',
      'dark': 'Dark',
      'theme': 'Theme',
      'syncData': 'Sync Data',
      'syncDataSubtitle': 'Export or sync workout data',
      'syncStarted': 'Sync started',
      'about': 'About',
      'aboutText': 'FitQuest helps you track workouts and progress.',
      'signOut': 'Sign Out',
    },
    'zu': {
      'appTitle': 'I-FitQuest',
      'welcome': 'Siyakwamukela',
      'login': 'Ngena ngemvume',
      'register': 'Bhalisa',
      'email': 'I-imeyili',
      'password': 'Iphasiwedi',
      'confirmPassword': 'Qinisekisa Iphasiwedi',
      'displayName': 'Igama Lokubonisa',
      'createAccount': 'Yakha i-akhawunti',
      'noAccount': 'Awunawo i-akhawunti?',
      'hasAccount': 'Usenayo i-akhawunti?',
      'signUp': 'Bhalisa',
      'signIn': 'Ngena',
      'home': 'Ikhaya',
      'exercises': 'Imizamo',
      'profile': 'Iphrofayili',
      'settings': 'Izilungiselelo',
      'logout': 'Phuma',
      'logoutConfirm': 'Uqinisekile ukuthi ufuna ukuphuma?',
      'cancel': 'Khansela',
      'save': 'Londoloza',
      'editProfile': 'Hlela Iphrofayili',
      'newPassword': 'Iphasiwedi Entsha',
      'keepPassword': 'shiya kungenalutho ukuze ugcine okwamanje',
      'profileUpdated': 'Iphrofayili ibuyekezwe ngempumelelo!',
      'chest': 'Isifuba',
      'back': 'Umhlane',
      'legs': 'Imilenze',
      'arms': 'Ingalo',
      'shoulders': 'Amahlombe',
      'core': 'Isizinda',
      'workouts': 'Imizamo',
      'minutes': 'Imizuzu',
      'startWorkout': 'Qala Umsebenzi',
      'progress': 'Intuthuko',
      'viewExercises': 'Buka imizamo nemisebenzi',
      'readyWorkout': 'Silungele umsebenzi wakho olandelayo?',
      'todaySummary': 'Isifinyezo Sanamuhla',
      'quickActions': 'Izenzo Ezisheshayo',
      'fitnessJourney': 'Uhambo Lwakho Lokuzivocavoca Luqala Lapha',
      'startJourney': 'Qala uhambo lwakho lokuzivocavoca namuhla',
      'joinFitQuest': 'Joyina i-FitQuest',
      'required': 'iyadingeka',
      'enterValid': 'Sicela ufake',
      'minLength': 'kufanele kube okungenani izinhlamvu eziyisithupha',
      'chooseLanguage': 'Khetha Ulimi',
      'languageChangedTo': 'Ulimi lushintshwe lube',
      'passwordMismatch': 'Amaphasiwedi awafani',
      'fitnessEnthusiast': 'Umthandi Wezokuzivocavoca',
      'noDisplayName': 'Akunalo igama lokubonisa',
      'noEmail': 'Ayikho i-imeyili',
      'error': 'Iphutha',
      'language': 'Ulimi',
      'notifications': 'Izaziso',
      'notificationsOn': 'Izaziso zivuliwe',
      'notificationsOff': 'Izaziso zivaliwe',
      'systemDefault': 'Okuzenzakalelayo kohlelo',
      'light': 'Okukhanyayo',
      'dark': 'Kumnyama',
      'theme': 'Isitayela',
      'syncData': 'Synchronize idatha',
      'syncDataSubtitle': 'Thumela noma uhambise idatha yomsebenzi',
      'syncStarted': 'Ukuhlanganiswa kuqale',
      'about': 'Mayelana',
      'aboutText':
          'I-FitQuest ikusiza ukulandelela imisebenzi kanye nentuthuko.',
      'signOut': 'Phuma',
    },
    'af': {
      'appTitle': 'FitQuest',
      'welcome': 'Welkom',
      'login': 'Teken In',
      'register': 'Registreer',
      'email': 'E-pos',
      'password': 'Wagwoord',
      'confirmPassword': 'Bevestig Wagwoord',
      'displayName': 'Vertoon Naam',
      'createAccount': 'Skep Rekening',
      'noAccount': "Het jy nie 'n rekening nie?",
      'hasAccount': 'Het jy reeds \'n rekening?',
      'signUp': 'Registreer',
      'signIn': 'Teken In',
      'home': 'Tuis',
      'exercises': 'Oefeninge',
      'profile': 'Profiel',
      'settings': 'Instellings',
      'logout': 'Teken Uit',
      'logoutConfirm': 'Is jy seker jy wil uitteken?',
      'cancel': 'Kanselleer',
      'save': 'Stoor',
      'editProfile': 'Wysig Profiel',
      'newPassword': 'Nuwe Wagwoord',
      'keepPassword': 'laat leeg om huidige te behou',
      'profileUpdated': 'Profiel suksesvol opgedateer!',
      'chest': 'Bors',
      'back': 'Rug',
      'legs': 'Bene',
      'arms': 'Arms',
      'shoulders': 'Skouers',
      'core': 'Kern',
      'workouts': 'Oefensessies',
      'minutes': 'Minute',
      'startWorkout': 'Begin Oefensessie',
      'progress': 'Vordering',
      'viewExercises': 'Bekyk oefeninge en oefensessies',
      'readyWorkout': 'Gereed vir jou volgende oefensessie?',
      'todaySummary': 'Vandag se Opsomming',
      'quickActions': 'Vinnige Aksies',
      'fitnessJourney': 'Jou Fiksheidsreis Begin Hier',
      'startJourney': 'Begin jou fiksheidsreis vandag',
      'joinFitQuest': 'Sluit aan by FitQuest',
      'required': 'word vereis',
      'enterValid': 'Voer asb. \'n geldige in',
      'minLength': 'moet ten minste 6 karakters wees',
      'chooseLanguage': 'Kies Taal',
      'languageChangedTo': 'Taal verander na',
      'passwordMismatch': 'Wagwoorde stem nie ooreen nie',
      'fitnessEnthusiast': 'Fiksheidsentoesias',
      'noDisplayName': 'Geen vertoon naam nie',
      'noEmail': 'Geen e-pos nie',
      'error': 'Fout',
      'language': 'Taal',
      'notifications': 'Kennisgewings',
      'notificationsOn': 'Kennisgewings geaktiveer',
      'notificationsOff': 'Kennisgewings gedeaktiveer',
      'systemDefault': 'Stelsel verstek',
      'light': 'Lig',
      'dark': 'Donker',
      'theme': 'Tema',
      'syncData': 'Sinchroniseer Data',
      'syncDataSubtitle': 'voer of sinchroniseer oefeningdata',
      'syncStarted': 'Sinchronisasie begin',
      'about': 'Oor',
      'aboutText': 'FitQuest help jou om oefeninge en vordering na te spoor.',
      'signOut': 'Teken Uit',
    },
  };

  String? translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key]; // fallback to English
  }

  // Helper methods for common translations
  String get appTitle => translate('appTitle')!;
  String get welcome => translate('welcome')!;
  String get login => translate('login')!;
  String get register => translate('register')!;
  String get email => translate('email')!;
  String get password => translate('password')!;
  String get confirmPassword => translate('confirmPassword')!;
  String get displayName => translate('displayName')!;
  String get createAccount => translate('createAccount')!;
  String get noAccount => translate('noAccount')!;
  String get hasAccount => translate('hasAccount')!;
  String get signUp => translate('signUp')!;
  String get signIn => translate('signIn')!;
  String get home => translate('home')!;
  String get exercises => translate('exercises')!;
  String get profile => translate('profile')!;
  String get settings => translate('settings')!;
  String get logout => translate('logout')!;
  String get logoutConfirm => translate('logoutConfirm')!;
  String get cancel => translate('cancel')!;
  String get save => translate('save')!;
  String get editProfile => translate('editProfile')!;
  String get newPassword => translate('newPassword')!;
  String get keepPassword => translate('keepPassword')!;
  String get profileUpdated => translate('profileUpdated')!;
  String get chest => translate('chest')!;
  String get back => translate('back')!;
  String get legs => translate('legs')!;
  String get arms => translate('arms')!;
  String get shoulders => translate('shoulders')!;
  String get core => translate('core')!;
  String get workouts => translate('workouts')!;
  String get minutes => translate('minutes')!;
  String get startWorkout => translate('startWorkout')!;
  String get progress => translate('progress')!;
  String get viewExercises => translate('viewExercises')!;
  String get readyWorkout => translate('readyWorkout')!;
  String get todaySummary => translate('todaySummary')!;
  String get quickActions => translate('quickActions')!;
  String get fitnessJourney => translate('fitnessJourney')!;
  String get startJourney => translate('startJourney')!;
  String get joinFitQuest => translate('joinFitQuest')!;
  String get required => translate('required')!;
  String get enterValid => translate('enterValid')!;
  String get minLength => translate('minLength')!;
  String get chooseLanguage => translate('chooseLanguage')!;
  String get languageChangedTo => translate('languageChangedTo')!;
  String get passwordMismatch => translate('passwordMismatch')!;
  String get fitnessEnthusiast => translate('fitnessEnthusiast')!;
  String get noDisplayName => translate('noDisplayName')!;
  String get noEmail => translate('noEmail')!;
  String get error => translate('error')!;
  String get language => translate('language')!;

  String get notifications => translate('notifications')!;
  String get notificationsOn => translate('notificationsOn')!;
  String get notificationsOff => translate('notificationsOff')!;
  String get systemDefault => translate('systemDefault')!;
  String get light => translate('light')!;
  String get dark => translate('dark')!;
  String get theme => translate('theme')!;
  String get syncData => translate('syncData')!;
  String get syncDataSubtitle => translate('syncDataSubtitle')!;
  String get syncStarted => translate('syncStarted')!;
  String get about => translate('about')!;
  String get aboutText => translate('aboutText')!;
  String get signOut => translate('signOut')!;

  String get currentLanguage => translate(
    'chooseLanguage',
  )!; //dont really know about using this translate method here
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'zu', 'af'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate,
    DefaultWidgetsLocalizations.delegate,
    DefaultMaterialLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('zu'),
    Locale('af'),
  ];
}

// Add static properties for MaterialApp localization support
extension on AppLocalizations {
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate,
    DefaultWidgetsLocalizations.delegate,
    DefaultMaterialLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('zu'),
    Locale('af'),
  ];
}
