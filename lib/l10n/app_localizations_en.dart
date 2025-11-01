// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Anniversary App';

  @override
  String get settings => 'Settings';

  @override
  String get anniversaryList => 'Anniversaries';

  @override
  String get anniversaryName => 'Anniversary Name';

  @override
  String get noDateChosen => 'No Date Chosen!';

  @override
  String get pickedDatePrefix => 'Picked Date:';

  @override
  String get chooseDate => 'Choose Date';

  @override
  String get addAnniversary => 'Add Anniversary';

  @override
  String get pleaseLogin => 'Please sign in to see your anniversaries.';

  @override
  String get errorPrefix => 'Error:';

  @override
  String get noAnniversariesPrompt =>
      'No anniversaries yet!\nAdd one using the + button.';

  @override
  String get daysPassed => 'Days passed:';

  @override
  String get days => 'days';

  @override
  String get deleteAnniversaryTooltip => 'Delete Anniversary';

  @override
  String get anniversaryDetailTitle => 'Anniversary Details';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get confirmDeleteTitle => 'Confirm Delete';

  @override
  String get confirmDeleteContent =>
      'Are you sure you want to delete this anniversary?';

  @override
  String get cancel => 'Cancel';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get notificationsOnOff => 'Enable Notifications';

  @override
  String get notificationTiming => 'Notification Timing';

  @override
  String get notificationTime => 'Notification Time';

  @override
  String get onTheDay => 'On the day';

  @override
  String get daysBefore => 'days before';

  @override
  String get editAnniversary => 'Edit Anniversary';

  @override
  String get date => 'Date';

  @override
  String get pickImage => 'Pick Image';

  @override
  String get changeImage => 'Change Image';

  @override
  String get removeImage => 'Remove Image';

  @override
  String get imageUpdated => 'Image updated.';

  @override
  String get imageRemoved => 'Image removed.';

  @override
  String get noImageSelected => 'No image selected.';
}
