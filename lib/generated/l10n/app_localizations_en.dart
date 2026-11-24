// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Desouq Wasalny';

  @override
  String get loginTitle => 'Sign in as rider';

  @override
  String get email => 'Email';

  @override
  String get loginEmailOrPhone => 'Email or phone number';

  @override
  String get validationLoginIdentifier => 'Enter a valid email or phone number';

  @override
  String get loginPhoneNotFound => 'No account is linked to this phone number';

  @override
  String get password => 'Password';

  @override
  String get login => 'Sign in';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get loginInvalidCredentials => 'Wrong email or password';

  @override
  String get loginUserNotFound => 'No account for this email';

  @override
  String get loginTooManyRequests => 'Too many attempts. Try again later';

  @override
  String get loginRequestTimeout =>
      'Connection timed out. Check your internet and try again.';

  @override
  String get noAccountSignUp => 'No account? Sign up here';

  @override
  String get signUpTitle => 'Create account';

  @override
  String get userName => 'Username';

  @override
  String get phone => 'Phone';

  @override
  String get signUp => 'Register';

  @override
  String get signUpInProgress => 'Signing up...';

  @override
  String get haveAccountLogin => 'Already have an account? Sign in';

  @override
  String get validationNameShort => 'Name must be at least 4 characters';

  @override
  String get validationPhone => 'Phone must be at least 7 digits';

  @override
  String get validationEmail => 'Enter a valid email';

  @override
  String get validationPassword => 'Password must be at least 6 characters';

  @override
  String get registeringAccount => 'Creating account...';

  @override
  String get errorSignupGeneric => 'Sign-up error';

  @override
  String get errorEmailInUse => 'Email is already in use';

  @override
  String get errorInvalidEmail => 'Invalid email';

  @override
  String get errorWeakPassword => 'Weak password (at least 6 characters)';

  @override
  String get errorNetworkFirebase =>
      'Could not reach Firebase. Check connection; emulators often fail — try a real device.';

  @override
  String get errorFirebaseEmulatorHint =>
      'Firebase may fail on emulators even when the browser works. Try a physical phone.';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get profile => 'Profile';

  @override
  String get history => 'Trip history';

  @override
  String get about => 'About';

  @override
  String get logout => 'Log out';

  @override
  String get language => 'Language';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSystem => 'System default';

  @override
  String get comingSoonShort => 'Coming soon';

  @override
  String get resolvingPickupGps => 'Getting pickup location...';

  @override
  String get tripRequestDataIncomplete =>
      'Trip data is incomplete. Set pickup and destination, then try again.';

  @override
  String get pickupOutsideServiceArea =>
      'Pickup or destination is outside the service area (Kafr El Sheikh governorate).';

  @override
  String get fcmKeyMissing =>
      'FCM server key missing. Rebuild with --dart-define=SERVER_KEY_FCM=… (Firebase → Project settings → Cloud Messaging).';

  @override
  String get fcmHttp404 =>
      'Push failed (HTTP 404). Enable «Cloud Messaging API (Legacy)» in Google Cloud for this Firebase project, or verify the FCM endpoint.';

  @override
  String get fcmHttp401 =>
      'Push failed (HTTP 401/403). Check SERVER_KEY_FCM — use the Server key from Firebase Console.';

  @override
  String fcmDownstreamError(String error) {
    return 'Push reached FCM but failed: $error';
  }

  @override
  String get fcmNetworkError =>
      'Could not reach FCM. Check internet connection.';

  @override
  String get tripTabInternal => 'Internal trip';

  @override
  String get tripTabExternal => 'External trip';

  @override
  String internalTabIntro(String egp) {
    return 'Your location is set as pickup. Type your destination in Desouk (at least 2 letters) and pick a result. Fixed fare $egp EGP.';
  }

  @override
  String get internalDestinationHint => 'To — your destination in Desouk';

  @override
  String get internalDestinationRequired =>
      'Type your Desouk destination and pick a result, or enter at least 3 clear characters.';

  @override
  String get dropoffSetSnackbar => 'Destination set';

  @override
  String get continueShowPrice => 'Continue — show fare';

  @override
  String get externalTabIntro =>
      'Set pickup and destination. Fare is based on route distance. Type at least two letters, then tap a result below.';

  @override
  String get fromPickupHint => 'From — pickup address';

  @override
  String get toDestinationHint => 'To — destination';

  @override
  String get planTripTitle => 'Plan trip';

  @override
  String get pickupResults => 'Pickup results';

  @override
  String get dropoffResults => 'Destination results';

  @override
  String pricingInternalFixed(String egp) {
    return 'Internal trip — fixed $egp EGP';
  }

  @override
  String get pricingExternalDistance => 'External trip — fare by distance (km)';

  @override
  String get estimatedFareLabel => 'Estimated fare before you request';

  @override
  String externalFareFormula(String base, String perKm) {
    return 'Base $base EGP + $perKm EGP × distance (km)';
  }

  @override
  String get confirmRequestRide => 'Confirm & request ride';

  @override
  String get currencyEgp => 'EGP';

  @override
  String get payCash => 'Pay cash';

  @override
  String amountDueDriver(String amount) {
    return 'Amount due: $amount EGP — pay the driver.';
  }

  @override
  String get loadingFirebase => 'Initializing Firebase...';

  @override
  String get firebaseInitFailed =>
      'Could not initialize Firebase. Check internet and google-services.json, then retry.';

  @override
  String get retry => 'Retry';

  @override
  String get locationGpsError =>
      'Could not get your location. Turn on location services and check your connection, then try again.';

  @override
  String get locationServiceDisabled =>
      'Location is off on this device. Turn on location in settings.';

  @override
  String get locationPermissionDenied =>
      'Allow location access for this app when prompted.';

  @override
  String get locationPermissionForeverDenied =>
      'Location access was denied. Enable it for this app in system Settings → Apps.';

  @override
  String blockedMessage(String email) {
    return 'You are blocked. Contact admin: $email';
  }

  @override
  String get gettingDirection => 'Getting route...';

  @override
  String get routeFetchError =>
      'Could not load route. Check connection or try later.';

  @override
  String get internalPickupRequired =>
      'Choose pickup from results or wait for GPS, then continue.';

  @override
  String get noDriverTitle => 'No driver available';

  @override
  String get noDriverMessage => 'No driver nearby. Please try again shortly.';

  @override
  String get driverArriving => 'Driver is on the way';

  @override
  String get driverHasArrived => 'Driver has arrived';

  @override
  String get estimatingDriverEta => 'Calculating arrival time…';

  @override
  String get driverArrivedNotificationTitle => 'Your driver is here';

  @override
  String get driverArrivedNotificationBody =>
      'The driver has arrived at the pickup point.';

  @override
  String driverComingEta(String eta) {
    return 'Driver coming — $eta';
  }

  @override
  String drivingToDropoffEta(String eta) {
    return 'Heading to destination — $eta';
  }

  @override
  String get tripsHistoryTitle => 'My trips';

  @override
  String get tripFrom => 'From';

  @override
  String get tripTo => 'To';

  @override
  String get noTripsYet => 'No completed trips yet';

  @override
  String get errorOccurred => 'Something went wrong';

  @override
  String get aboutDevelopedBy => 'Developed by';

  @override
  String get aboutBlurb =>
      'This application is built for riders (Waslny Users).';

  @override
  String aboutContactAdmin(String email) {
    return 'For reports contact: $email';
  }

  @override
  String get aboutPageTitle => 'About this app';

  @override
  String get aboutFieldVersionLabel => 'Version';

  @override
  String get aboutSectionWhatIsTitle => 'What is this app?';

  @override
  String get aboutWhatIsBody =>
      'Waslny (وصلني) is a rider app to request trips within the supported service area, track trip status, and coordinate with drivers through the platform.';

  @override
  String get aboutSectionServiceAreaTitle => 'Service area';

  @override
  String get aboutServiceAreaBody =>
      'The service is available in Egypt only, within Kafr El Sheikh Governorate and the zones allowed in the app map. Requests outside this area are not accepted.';

  @override
  String get aboutSectionPublisherTitle => 'Publisher';

  @override
  String get aboutFieldSupportEmailLabel => 'Support & reports email';

  @override
  String get aboutDeleteAccountHint =>
      'You can delete your account and related data from the main menu → “Delete my account”.';

  @override
  String get aboutSectionDeveloperTitle => 'App developer';

  @override
  String get aboutFieldDeveloperPhoneLabel => 'Phone';

  @override
  String get aboutFieldDeveloperFacebookLabel => 'Facebook page';

  @override
  String get privacyPolicyTitle => 'Privacy policy';

  @override
  String get privacySummaryIntro =>
      'We care about your privacy. This summary explains how we handle your data when you use Waslny. For full legal details, open the web policy when the link is configured.';

  @override
  String get privacySectionDataTitle => 'Data we collect';

  @override
  String get privacySectionDataBody =>
      'Account details (name, email, phone) when you sign up; trip data (pickup/drop-off, status, fare; driver-related details once a driver is assigned); ratings and complaints/suggestions if you submit them.';

  @override
  String get privacySectionLocationTitle => 'Location';

  @override
  String get privacySectionLocationBody =>
      'We use your device location in Egypt to show the map, set pickup addresses, and match trip requests with nearby drivers within Kafr El Sheikh Governorate and the allowed zones in the app.';

  @override
  String get privacySectionThirdPartiesTitle => 'Third parties';

  @override
  String get privacySectionThirdPartiesBody =>
      'We may rely on providers such as Google Firebase (authentication, database, storage), map/place services (e.g. OpenStreetMap/Nominatim), and routing (e.g. OSRM) where needed. Those providers have their own policies.';

  @override
  String get privacySectionRetentionTitle => 'Retention';

  @override
  String get privacySectionRetentionBody =>
      'We keep data as long as needed to run the service, comply with law, or resolve disputes. You can request account deletion in the app to remove data linked to your account subject to technical and security rules.';

  @override
  String get privacySectionRightsTitle => 'Your rights';

  @override
  String get privacySectionRightsBody =>
      'You may ask to correct contact details or delete your account. For other privacy requests, email us at the address below.';

  @override
  String get privacySectionDeleteTitle => 'Deleting your account';

  @override
  String get privacySectionDeleteBody =>
      'From the app menu choose “Delete my account” and confirm with your password. This removes your authentication account and deletes much of your app database data linked to you.';

  @override
  String privacyContactFooter(String email) {
    return 'Privacy questions: $email';
  }

  @override
  String get privacyOpenFullPolicyButton =>
      'Open full privacy policy in browser';

  @override
  String get privacyUrlNotConfiguredHint =>
      'The full policy URL is not set yet. Update privacyPolicyUrl in AppConfig after you publish your policy page on your website.';

  @override
  String get pickupSetSnackbar => 'Pickup location saved';

  @override
  String get nominatimRateLimit =>
      'Too many searches. Wait a second and try again.';

  @override
  String nominatimHttpError(String code) {
    return 'Places service error ($code). Check internet.';
  }

  @override
  String get nominatimConnectionError =>
      'Could not reach places service. Check internet.';

  @override
  String get nominatimNoResults =>
      'No results. A longer name or English may help.';

  @override
  String get searchMinCharsHint =>
      'Type at least 2 characters, then tap a result below.';

  @override
  String get fixedPriceShort => 'Fixed fare';

  @override
  String get dash => '—';

  @override
  String get internalDropLabel => 'Internal trip (destination with driver)';

  @override
  String get internalPickupSelectFirst =>
      'Set pickup from the internal trip tab, then tap continue.';

  @override
  String get currentLocationFallback => 'My current location';

  @override
  String get useMyLocationTooltip => 'Use my current location';

  @override
  String get pickupAutoDetected => 'Pickup location detected automatically';

  @override
  String get homeBottomRequestTrip => 'Request ride';

  @override
  String get homeBottomMainMap => 'Home';

  @override
  String get homeBottomSubscriptions => 'Subscriptions';

  @override
  String get subscriptionTripsMapTooltip => 'Subscription / recurring trips';

  @override
  String get subscriptionTripsTitle => 'Subscription trips';

  @override
  String get subscriptionFormIntro =>
      'Fill in the details below. Our team will call you on your phone to agree a subscription price based on distance and days per week.';

  @override
  String get subscriptionFullNameLabel => 'Full name (three parts)';

  @override
  String get subscriptionFullNameValidation =>
      'Enter your full name as at least three words and 8+ characters.';

  @override
  String get subscriptionPhoneLabel => 'Phone number';

  @override
  String get subscriptionPhoneValidation =>
      'Enter a valid phone number (at least 10 digits).';

  @override
  String get subscriptionPickupLabel => 'Pickup / start location';

  @override
  String get subscriptionPickupValidation =>
      'Enter a clear start location (at least 3 characters).';

  @override
  String get subscriptionDropoffLabel => 'Drop-off / destination';

  @override
  String get subscriptionDropoffValidation =>
      'Enter a clear destination (at least 3 characters).';

  @override
  String get subscriptionWaitTimeLabel => 'Is there a waiting time?';

  @override
  String get subscriptionWaitTimeYes => 'Yes';

  @override
  String get subscriptionWaitTimeNo => 'No';

  @override
  String get subscriptionWaitTimeValidation =>
      'Please choose whether there is a waiting time.';

  @override
  String get subscriptionDaysPerWeekLabel =>
      'How many days per week do you need the ride?';

  @override
  String get subscriptionDaysPerWeekHint => 'Days count';

  @override
  String subscriptionDaysPerWeekOption(int count) {
    return '$count days per week';
  }

  @override
  String get subscriptionRegisterButton => 'Submit subscription request';

  @override
  String get subscriptionRegisteredMessage =>
      'Your subscription has been registered. We will contact you as soon as possible.';

  @override
  String get subscriptionInquiriesCaption => 'For inquiries:';

  @override
  String get subscriptionDoneBack => 'Back';

  @override
  String get subscriptionError =>
      'Could not send. Check connection and try again.';

  @override
  String get feedbackMenuTitle => 'Complaints & suggestions';

  @override
  String get complaintsAndSuggestionsTitle => 'Complaints and suggestions';

  @override
  String get postTripRatingTitle => 'Rate your trip';

  @override
  String get rateTripLabel => 'Your rating (1–5 stars)';

  @override
  String get rateDriverLabel => 'Your driver';

  @override
  String get rateServiceLabel => 'Overall service (app & trip)';

  @override
  String get optionalCommentHint => 'Optional comment';

  @override
  String get skipRating => 'Skip';

  @override
  String get submitRating => 'Submit';

  @override
  String get ratingStarsHint => 'Tap the stars (1–5)';

  @override
  String get ratingPickStarsError =>
      'Please choose a rating from 1 to 5 stars.';

  @override
  String get feedbackIntroBlurb =>
      'Send us a complaint about a problem, or a suggestion to improve Waslny. Your message is stored securely for the admin team.';

  @override
  String get feedbackTypeComplaint => 'Complaint';

  @override
  String get feedbackTypeSuggestion => 'Suggestion';

  @override
  String get feedbackMessageHint =>
      'Describe your complaint or suggestion (at least 8 characters)';

  @override
  String get feedbackSubmit => 'Send';

  @override
  String get feedbackSuccess => 'Thank you — your message was sent.';

  @override
  String get feedbackError => 'Could not send. Check connection and try again.';

  @override
  String get feedbackMessageTooShort =>
      'Please write a little more detail (at least 8 characters).';

  @override
  String get deleteAccountMenuTitle => 'Delete my account';

  @override
  String get deleteAccountDialogTitle => 'Delete account and data?';

  @override
  String get deleteAccountDialogBody =>
      'This permanently deletes your profile, trip history linked to you, ratings, and feedback messages. You will not be able to recover this data. Enter your password to confirm.';

  @override
  String get deleteAccountPasswordLabel => 'Current password';

  @override
  String get deleteAccountConfirmButton => 'Delete permanently';

  @override
  String get deleteAccountCancelButton => 'Cancel';

  @override
  String get deleteAccountDeleting => 'Deleting your account…';

  @override
  String get deleteAccountWrongPassword => 'Incorrect password. Try again.';

  @override
  String get deleteAccountRequiresRecentLogin =>
      'Please sign out and sign in again, then delete your account.';

  @override
  String get deleteAccountErrorGeneric =>
      'Could not delete the account. Check your connection and try again.';

  @override
  String get deleteAccountEmptyPassword => 'Enter your password to confirm.';
}
