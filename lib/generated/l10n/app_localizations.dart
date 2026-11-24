import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Desouq Wasalny'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in as rider'**
  String get loginTitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @loginEmailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or phone number'**
  String get loginEmailOrPhone;

  /// No description provided for @validationLoginIdentifier.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email or phone number'**
  String get validationLoginIdentifier;

  /// No description provided for @loginPhoneNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account is linked to this phone number'**
  String get loginPhoneNotFound;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password'**
  String get loginInvalidCredentials;

  /// No description provided for @loginUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account for this email'**
  String get loginUserNotFound;

  /// No description provided for @loginTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later'**
  String get loginTooManyRequests;

  /// No description provided for @loginRequestTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Check your internet and try again.'**
  String get loginRequestTimeout;

  /// No description provided for @noAccountSignUp.
  ///
  /// In en, this message translates to:
  /// **'No account? Sign up here'**
  String get noAccountSignUp;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpTitle;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get userName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get signUp;

  /// No description provided for @signUpInProgress.
  ///
  /// In en, this message translates to:
  /// **'Signing up...'**
  String get signUpInProgress;

  /// No description provided for @haveAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccountLogin;

  /// No description provided for @validationNameShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 4 characters'**
  String get validationNameShort;

  /// No description provided for @validationPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone must be at least 7 digits'**
  String get validationPhone;

  /// No description provided for @validationEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get validationEmail;

  /// No description provided for @validationPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validationPassword;

  /// No description provided for @registeringAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating account...'**
  String get registeringAccount;

  /// No description provided for @errorSignupGeneric.
  ///
  /// In en, this message translates to:
  /// **'Sign-up error'**
  String get errorSignupGeneric;

  /// No description provided for @errorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'Email is already in use'**
  String get errorEmailInUse;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get errorInvalidEmail;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Weak password (at least 6 characters)'**
  String get errorWeakPassword;

  /// No description provided for @errorNetworkFirebase.
  ///
  /// In en, this message translates to:
  /// **'Could not reach Firebase. Check connection; emulators often fail — try a real device.'**
  String get errorNetworkFirebase;

  /// No description provided for @errorFirebaseEmulatorHint.
  ///
  /// In en, this message translates to:
  /// **'Firebase may fail on emulators even when the browser works. Try a physical phone.'**
  String get errorFirebaseEmulatorHint;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'Trip history'**
  String get history;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @comingSoonShort.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonShort;

  /// No description provided for @resolvingPickupGps.
  ///
  /// In en, this message translates to:
  /// **'Getting pickup location...'**
  String get resolvingPickupGps;

  /// No description provided for @tripRequestDataIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Trip data is incomplete. Set pickup and destination, then try again.'**
  String get tripRequestDataIncomplete;

  /// No description provided for @pickupOutsideServiceArea.
  ///
  /// In en, this message translates to:
  /// **'Pickup or destination is outside the service area (Kafr El Sheikh governorate).'**
  String get pickupOutsideServiceArea;

  /// No description provided for @fcmKeyMissing.
  ///
  /// In en, this message translates to:
  /// **'FCM server key missing. Rebuild with --dart-define=SERVER_KEY_FCM=… (Firebase → Project settings → Cloud Messaging).'**
  String get fcmKeyMissing;

  /// No description provided for @fcmHttp404.
  ///
  /// In en, this message translates to:
  /// **'Push failed (HTTP 404). Enable «Cloud Messaging API (Legacy)» in Google Cloud for this Firebase project, or verify the FCM endpoint.'**
  String get fcmHttp404;

  /// No description provided for @fcmHttp401.
  ///
  /// In en, this message translates to:
  /// **'Push failed (HTTP 401/403). Check SERVER_KEY_FCM — use the Server key from Firebase Console.'**
  String get fcmHttp401;

  /// No description provided for @fcmDownstreamError.
  ///
  /// In en, this message translates to:
  /// **'Push reached FCM but failed: {error}'**
  String fcmDownstreamError(String error);

  /// No description provided for @fcmNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Could not reach FCM. Check internet connection.'**
  String get fcmNetworkError;

  /// No description provided for @tripTabInternal.
  ///
  /// In en, this message translates to:
  /// **'Internal trip'**
  String get tripTabInternal;

  /// No description provided for @tripTabExternal.
  ///
  /// In en, this message translates to:
  /// **'External trip'**
  String get tripTabExternal;

  /// No description provided for @internalTabIntro.
  ///
  /// In en, this message translates to:
  /// **'Your location is set as pickup. Type your destination in Desouk (at least 2 letters) and pick a result. Fixed fare {egp} EGP.'**
  String internalTabIntro(String egp);

  /// No description provided for @internalDestinationHint.
  ///
  /// In en, this message translates to:
  /// **'To — your destination in Desouk'**
  String get internalDestinationHint;

  /// No description provided for @internalDestinationRequired.
  ///
  /// In en, this message translates to:
  /// **'Type your Desouk destination and pick a result, or enter at least 3 clear characters.'**
  String get internalDestinationRequired;

  /// No description provided for @dropoffSetSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Destination set'**
  String get dropoffSetSnackbar;

  /// No description provided for @continueShowPrice.
  ///
  /// In en, this message translates to:
  /// **'Continue — show fare'**
  String get continueShowPrice;

  /// No description provided for @externalTabIntro.
  ///
  /// In en, this message translates to:
  /// **'Set pickup and destination. Fare is based on route distance. Type at least two letters, then tap a result below.'**
  String get externalTabIntro;

  /// No description provided for @fromPickupHint.
  ///
  /// In en, this message translates to:
  /// **'From — pickup address'**
  String get fromPickupHint;

  /// No description provided for @toDestinationHint.
  ///
  /// In en, this message translates to:
  /// **'To — destination'**
  String get toDestinationHint;

  /// No description provided for @planTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan trip'**
  String get planTripTitle;

  /// No description provided for @pickupResults.
  ///
  /// In en, this message translates to:
  /// **'Pickup results'**
  String get pickupResults;

  /// No description provided for @dropoffResults.
  ///
  /// In en, this message translates to:
  /// **'Destination results'**
  String get dropoffResults;

  /// No description provided for @pricingInternalFixed.
  ///
  /// In en, this message translates to:
  /// **'Internal trip — fixed {egp} EGP'**
  String pricingInternalFixed(String egp);

  /// No description provided for @pricingExternalDistance.
  ///
  /// In en, this message translates to:
  /// **'External trip — fare by distance (km)'**
  String get pricingExternalDistance;

  /// No description provided for @estimatedFareLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated fare before you request'**
  String get estimatedFareLabel;

  /// No description provided for @externalFareFormula.
  ///
  /// In en, this message translates to:
  /// **'Base {base} EGP + {perKm} EGP × distance (km)'**
  String externalFareFormula(String base, String perKm);

  /// No description provided for @confirmRequestRide.
  ///
  /// In en, this message translates to:
  /// **'Confirm & request ride'**
  String get confirmRequestRide;

  /// No description provided for @currencyEgp.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get currencyEgp;

  /// No description provided for @payCash.
  ///
  /// In en, this message translates to:
  /// **'Pay cash'**
  String get payCash;

  /// No description provided for @amountDueDriver.
  ///
  /// In en, this message translates to:
  /// **'Amount due: {amount} EGP — pay the driver.'**
  String amountDueDriver(String amount);

  /// No description provided for @loadingFirebase.
  ///
  /// In en, this message translates to:
  /// **'Initializing Firebase...'**
  String get loadingFirebase;

  /// No description provided for @firebaseInitFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not initialize Firebase. Check internet and google-services.json, then retry.'**
  String get firebaseInitFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @locationGpsError.
  ///
  /// In en, this message translates to:
  /// **'Could not get your location. Turn on location services and check your connection, then try again.'**
  String get locationGpsError;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location is off on this device. Turn on location in settings.'**
  String get locationServiceDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow location access for this app when prompted.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionForeverDenied.
  ///
  /// In en, this message translates to:
  /// **'Location access was denied. Enable it for this app in system Settings → Apps.'**
  String get locationPermissionForeverDenied;

  /// No description provided for @blockedMessage.
  ///
  /// In en, this message translates to:
  /// **'You are blocked. Contact admin: {email}'**
  String blockedMessage(String email);

  /// No description provided for @gettingDirection.
  ///
  /// In en, this message translates to:
  /// **'Getting route...'**
  String get gettingDirection;

  /// No description provided for @routeFetchError.
  ///
  /// In en, this message translates to:
  /// **'Could not load route. Check connection or try later.'**
  String get routeFetchError;

  /// No description provided for @internalPickupRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose pickup from results or wait for GPS, then continue.'**
  String get internalPickupRequired;

  /// No description provided for @noDriverTitle.
  ///
  /// In en, this message translates to:
  /// **'No driver available'**
  String get noDriverTitle;

  /// No description provided for @noDriverMessage.
  ///
  /// In en, this message translates to:
  /// **'No driver nearby. Please try again shortly.'**
  String get noDriverMessage;

  /// No description provided for @driverArriving.
  ///
  /// In en, this message translates to:
  /// **'Driver is on the way'**
  String get driverArriving;

  /// No description provided for @driverHasArrived.
  ///
  /// In en, this message translates to:
  /// **'Driver has arrived'**
  String get driverHasArrived;

  /// No description provided for @estimatingDriverEta.
  ///
  /// In en, this message translates to:
  /// **'Calculating arrival time…'**
  String get estimatingDriverEta;

  /// No description provided for @driverArrivedNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Your driver is here'**
  String get driverArrivedNotificationTitle;

  /// No description provided for @driverArrivedNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'The driver has arrived at the pickup point.'**
  String get driverArrivedNotificationBody;

  /// No description provided for @driverComingEta.
  ///
  /// In en, this message translates to:
  /// **'Driver coming — {eta}'**
  String driverComingEta(String eta);

  /// No description provided for @drivingToDropoffEta.
  ///
  /// In en, this message translates to:
  /// **'Heading to destination — {eta}'**
  String drivingToDropoffEta(String eta);

  /// No description provided for @tripsHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'My trips'**
  String get tripsHistoryTitle;

  /// No description provided for @tripFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get tripFrom;

  /// No description provided for @tripTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get tripTo;

  /// No description provided for @noTripsYet.
  ///
  /// In en, this message translates to:
  /// **'No completed trips yet'**
  String get noTripsYet;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorOccurred;

  /// No description provided for @aboutDevelopedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get aboutDevelopedBy;

  /// No description provided for @aboutBlurb.
  ///
  /// In en, this message translates to:
  /// **'This application is built for riders (Waslny Users).'**
  String get aboutBlurb;

  /// No description provided for @aboutContactAdmin.
  ///
  /// In en, this message translates to:
  /// **'For reports contact: {email}'**
  String aboutContactAdmin(String email);

  /// No description provided for @aboutPageTitle.
  ///
  /// In en, this message translates to:
  /// **'About this app'**
  String get aboutPageTitle;

  /// No description provided for @aboutFieldVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutFieldVersionLabel;

  /// No description provided for @aboutSectionWhatIsTitle.
  ///
  /// In en, this message translates to:
  /// **'What is this app?'**
  String get aboutSectionWhatIsTitle;

  /// No description provided for @aboutWhatIsBody.
  ///
  /// In en, this message translates to:
  /// **'Waslny (وصلني) is a rider app to request trips within the supported service area, track trip status, and coordinate with drivers through the platform.'**
  String get aboutWhatIsBody;

  /// No description provided for @aboutSectionServiceAreaTitle.
  ///
  /// In en, this message translates to:
  /// **'Service area'**
  String get aboutSectionServiceAreaTitle;

  /// No description provided for @aboutServiceAreaBody.
  ///
  /// In en, this message translates to:
  /// **'The service is available in Egypt only, within Kafr El Sheikh Governorate and the zones allowed in the app map. Requests outside this area are not accepted.'**
  String get aboutServiceAreaBody;

  /// No description provided for @aboutSectionPublisherTitle.
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get aboutSectionPublisherTitle;

  /// No description provided for @aboutFieldSupportEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Support & reports email'**
  String get aboutFieldSupportEmailLabel;

  /// No description provided for @aboutDeleteAccountHint.
  ///
  /// In en, this message translates to:
  /// **'You can delete your account and related data from the main menu → “Delete my account”.'**
  String get aboutDeleteAccountHint;

  /// No description provided for @aboutSectionDeveloperTitle.
  ///
  /// In en, this message translates to:
  /// **'App developer'**
  String get aboutSectionDeveloperTitle;

  /// No description provided for @aboutFieldDeveloperPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get aboutFieldDeveloperPhoneLabel;

  /// No description provided for @aboutFieldDeveloperFacebookLabel.
  ///
  /// In en, this message translates to:
  /// **'Facebook page'**
  String get aboutFieldDeveloperFacebookLabel;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacySummaryIntro.
  ///
  /// In en, this message translates to:
  /// **'We care about your privacy. This summary explains how we handle your data when you use Waslny. For full legal details, open the web policy when the link is configured.'**
  String get privacySummaryIntro;

  /// No description provided for @privacySectionDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Data we collect'**
  String get privacySectionDataTitle;

  /// No description provided for @privacySectionDataBody.
  ///
  /// In en, this message translates to:
  /// **'Account details (name, email, phone) when you sign up; trip data (pickup/drop-off, status, fare; driver-related details once a driver is assigned); ratings and complaints/suggestions if you submit them.'**
  String get privacySectionDataBody;

  /// No description provided for @privacySectionLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get privacySectionLocationTitle;

  /// No description provided for @privacySectionLocationBody.
  ///
  /// In en, this message translates to:
  /// **'We use your device location in Egypt to show the map, set pickup addresses, and match trip requests with nearby drivers within Kafr El Sheikh Governorate and the allowed zones in the app.'**
  String get privacySectionLocationBody;

  /// No description provided for @privacySectionThirdPartiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Third parties'**
  String get privacySectionThirdPartiesTitle;

  /// No description provided for @privacySectionThirdPartiesBody.
  ///
  /// In en, this message translates to:
  /// **'We may rely on providers such as Google Firebase (authentication, database, storage), map/place services (e.g. OpenStreetMap/Nominatim), and routing (e.g. OSRM) where needed. Those providers have their own policies.'**
  String get privacySectionThirdPartiesBody;

  /// No description provided for @privacySectionRetentionTitle.
  ///
  /// In en, this message translates to:
  /// **'Retention'**
  String get privacySectionRetentionTitle;

  /// No description provided for @privacySectionRetentionBody.
  ///
  /// In en, this message translates to:
  /// **'We keep data as long as needed to run the service, comply with law, or resolve disputes. You can request account deletion in the app to remove data linked to your account subject to technical and security rules.'**
  String get privacySectionRetentionBody;

  /// No description provided for @privacySectionRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your rights'**
  String get privacySectionRightsTitle;

  /// No description provided for @privacySectionRightsBody.
  ///
  /// In en, this message translates to:
  /// **'You may ask to correct contact details or delete your account. For other privacy requests, email us at the address below.'**
  String get privacySectionRightsBody;

  /// No description provided for @privacySectionDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account'**
  String get privacySectionDeleteTitle;

  /// No description provided for @privacySectionDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'From the app menu choose “Delete my account” and confirm with your password. This removes your authentication account and deletes much of your app database data linked to you.'**
  String get privacySectionDeleteBody;

  /// No description provided for @privacyContactFooter.
  ///
  /// In en, this message translates to:
  /// **'Privacy questions: {email}'**
  String privacyContactFooter(String email);

  /// No description provided for @privacyOpenFullPolicyButton.
  ///
  /// In en, this message translates to:
  /// **'Open full privacy policy in browser'**
  String get privacyOpenFullPolicyButton;

  /// No description provided for @privacyUrlNotConfiguredHint.
  ///
  /// In en, this message translates to:
  /// **'The full policy URL is not set yet. Update privacyPolicyUrl in AppConfig after you publish your policy page on your website.'**
  String get privacyUrlNotConfiguredHint;

  /// No description provided for @pickupSetSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Pickup location saved'**
  String get pickupSetSnackbar;

  /// No description provided for @nominatimRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Too many searches. Wait a second and try again.'**
  String get nominatimRateLimit;

  /// No description provided for @nominatimHttpError.
  ///
  /// In en, this message translates to:
  /// **'Places service error ({code}). Check internet.'**
  String nominatimHttpError(String code);

  /// No description provided for @nominatimConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Could not reach places service. Check internet.'**
  String get nominatimConnectionError;

  /// No description provided for @nominatimNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results. A longer name or English may help.'**
  String get nominatimNoResults;

  /// No description provided for @searchMinCharsHint.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters, then tap a result below.'**
  String get searchMinCharsHint;

  /// No description provided for @fixedPriceShort.
  ///
  /// In en, this message translates to:
  /// **'Fixed fare'**
  String get fixedPriceShort;

  /// No description provided for @dash.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get dash;

  /// No description provided for @internalDropLabel.
  ///
  /// In en, this message translates to:
  /// **'Internal trip (destination with driver)'**
  String get internalDropLabel;

  /// No description provided for @internalPickupSelectFirst.
  ///
  /// In en, this message translates to:
  /// **'Set pickup from the internal trip tab, then tap continue.'**
  String get internalPickupSelectFirst;

  /// No description provided for @currentLocationFallback.
  ///
  /// In en, this message translates to:
  /// **'My current location'**
  String get currentLocationFallback;

  /// No description provided for @useMyLocationTooltip.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get useMyLocationTooltip;

  /// No description provided for @pickupAutoDetected.
  ///
  /// In en, this message translates to:
  /// **'Pickup location detected automatically'**
  String get pickupAutoDetected;

  /// No description provided for @homeBottomRequestTrip.
  ///
  /// In en, this message translates to:
  /// **'Request ride'**
  String get homeBottomRequestTrip;

  /// No description provided for @homeBottomMainMap.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeBottomMainMap;

  /// No description provided for @homeBottomSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get homeBottomSubscriptions;

  /// No description provided for @subscriptionTripsMapTooltip.
  ///
  /// In en, this message translates to:
  /// **'Subscription / recurring trips'**
  String get subscriptionTripsMapTooltip;

  /// No description provided for @subscriptionTripsTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription trips'**
  String get subscriptionTripsTitle;

  /// No description provided for @subscriptionFormIntro.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details below. Our team will call you on your phone to agree a subscription price based on distance and days per week.'**
  String get subscriptionFormIntro;

  /// No description provided for @subscriptionFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name (three parts)'**
  String get subscriptionFullNameLabel;

  /// No description provided for @subscriptionFullNameValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name as at least three words and 8+ characters.'**
  String get subscriptionFullNameValidation;

  /// No description provided for @subscriptionPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get subscriptionPhoneLabel;

  /// No description provided for @subscriptionPhoneValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number (at least 10 digits).'**
  String get subscriptionPhoneValidation;

  /// No description provided for @subscriptionPickupLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup / start location'**
  String get subscriptionPickupLabel;

  /// No description provided for @subscriptionPickupValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a clear start location (at least 3 characters).'**
  String get subscriptionPickupValidation;

  /// No description provided for @subscriptionDropoffLabel.
  ///
  /// In en, this message translates to:
  /// **'Drop-off / destination'**
  String get subscriptionDropoffLabel;

  /// No description provided for @subscriptionDropoffValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a clear destination (at least 3 characters).'**
  String get subscriptionDropoffValidation;

  /// No description provided for @subscriptionWaitTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Is there a waiting time?'**
  String get subscriptionWaitTimeLabel;

  /// No description provided for @subscriptionWaitTimeYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get subscriptionWaitTimeYes;

  /// No description provided for @subscriptionWaitTimeNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get subscriptionWaitTimeNo;

  /// No description provided for @subscriptionWaitTimeValidation.
  ///
  /// In en, this message translates to:
  /// **'Please choose whether there is a waiting time.'**
  String get subscriptionWaitTimeValidation;

  /// No description provided for @subscriptionDaysPerWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'How many days per week do you need the ride?'**
  String get subscriptionDaysPerWeekLabel;

  /// No description provided for @subscriptionDaysPerWeekHint.
  ///
  /// In en, this message translates to:
  /// **'Days count'**
  String get subscriptionDaysPerWeekHint;

  /// No description provided for @subscriptionDaysPerWeekOption.
  ///
  /// In en, this message translates to:
  /// **'{count} days per week'**
  String subscriptionDaysPerWeekOption(int count);

  /// No description provided for @subscriptionRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Submit subscription request'**
  String get subscriptionRegisterButton;

  /// No description provided for @subscriptionRegisteredMessage.
  ///
  /// In en, this message translates to:
  /// **'Your subscription has been registered. We will contact you as soon as possible.'**
  String get subscriptionRegisteredMessage;

  /// No description provided for @subscriptionInquiriesCaption.
  ///
  /// In en, this message translates to:
  /// **'For inquiries:'**
  String get subscriptionInquiriesCaption;

  /// No description provided for @subscriptionDoneBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get subscriptionDoneBack;

  /// No description provided for @subscriptionError.
  ///
  /// In en, this message translates to:
  /// **'Could not send. Check connection and try again.'**
  String get subscriptionError;

  /// No description provided for @feedbackMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Complaints & suggestions'**
  String get feedbackMenuTitle;

  /// No description provided for @complaintsAndSuggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Complaints and suggestions'**
  String get complaintsAndSuggestionsTitle;

  /// No description provided for @postTripRatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate your trip'**
  String get postTripRatingTitle;

  /// No description provided for @rateTripLabel.
  ///
  /// In en, this message translates to:
  /// **'Your rating (1–5 stars)'**
  String get rateTripLabel;

  /// No description provided for @rateDriverLabel.
  ///
  /// In en, this message translates to:
  /// **'Your driver'**
  String get rateDriverLabel;

  /// No description provided for @rateServiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Overall service (app & trip)'**
  String get rateServiceLabel;

  /// No description provided for @optionalCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Optional comment'**
  String get optionalCommentHint;

  /// No description provided for @skipRating.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipRating;

  /// No description provided for @submitRating.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitRating;

  /// No description provided for @ratingStarsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the stars (1–5)'**
  String get ratingStarsHint;

  /// No description provided for @ratingPickStarsError.
  ///
  /// In en, this message translates to:
  /// **'Please choose a rating from 1 to 5 stars.'**
  String get ratingPickStarsError;

  /// No description provided for @feedbackIntroBlurb.
  ///
  /// In en, this message translates to:
  /// **'Send us a complaint about a problem, or a suggestion to improve Waslny. Your message is stored securely for the admin team.'**
  String get feedbackIntroBlurb;

  /// No description provided for @feedbackTypeComplaint.
  ///
  /// In en, this message translates to:
  /// **'Complaint'**
  String get feedbackTypeComplaint;

  /// No description provided for @feedbackTypeSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get feedbackTypeSuggestion;

  /// No description provided for @feedbackMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your complaint or suggestion (at least 8 characters)'**
  String get feedbackMessageHint;

  /// No description provided for @feedbackSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get feedbackSubmit;

  /// No description provided for @feedbackSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thank you — your message was sent.'**
  String get feedbackSuccess;

  /// No description provided for @feedbackError.
  ///
  /// In en, this message translates to:
  /// **'Could not send. Check connection and try again.'**
  String get feedbackError;

  /// No description provided for @feedbackMessageTooShort.
  ///
  /// In en, this message translates to:
  /// **'Please write a little more detail (at least 8 characters).'**
  String get feedbackMessageTooShort;

  /// No description provided for @deleteAccountMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteAccountMenuTitle;

  /// No description provided for @deleteAccountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account and data?'**
  String get deleteAccountDialogTitle;

  /// No description provided for @deleteAccountDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your profile, trip history linked to you, ratings, and feedback messages. You will not be able to recover this data. Enter your password to confirm.'**
  String get deleteAccountDialogBody;

  /// No description provided for @deleteAccountPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get deleteAccountPasswordLabel;

  /// No description provided for @deleteAccountConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deleteAccountConfirmButton;

  /// No description provided for @deleteAccountCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deleteAccountCancelButton;

  /// No description provided for @deleteAccountDeleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account…'**
  String get deleteAccountDeleting;

  /// No description provided for @deleteAccountWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Try again.'**
  String get deleteAccountWrongPassword;

  /// No description provided for @deleteAccountRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'Please sign out and sign in again, then delete your account.'**
  String get deleteAccountRequiresRecentLogin;

  /// No description provided for @deleteAccountErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the account. Check your connection and try again.'**
  String get deleteAccountErrorGeneric;

  /// No description provided for @deleteAccountEmptyPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm.'**
  String get deleteAccountEmptyPassword;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
