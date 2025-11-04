// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '記念日アプリ';

  @override
  String get settings => '設定';

  @override
  String get anniversaryList => '記念日リスト';

  @override
  String get anniversaryName => '記念日の名前';

  @override
  String get noDateChosen => '日付が選択されていません';

  @override
  String get pickedDatePrefix => '選択した日付：';

  @override
  String get chooseDate => '日付を選択';

  @override
  String get addAnniversary => '記念日を追加';

  @override
  String get pleaseLogin => '記念日を見るにはログインしてください。';

  @override
  String get errorPrefix => 'エラー：';

  @override
  String get noAnniversariesPrompt => '記念日はまだありません。\n+ボタンで追加してください。';

  @override
  String get daysPassed => '経過日数：';

  @override
  String get days => '日';

  @override
  String get deleteAnniversaryTooltip => '記念日を削除';

  @override
  String get anniversaryDetailTitle => '記念日の詳細';

  @override
  String get edit => '編集';

  @override
  String get delete => '削除';

  @override
  String get save => '保存';

  @override
  String get confirmDeleteTitle => '削除の確認';

  @override
  String get confirmDeleteContent => 'この記念日を本当に削除しますか？';

  @override
  String get cancel => 'キャンセル';

  @override
  String get notificationSettings => '通知設定';

  @override
  String get notificationsOnOff => '通知を有効にする';

  @override
  String get notificationTiming => '通知のタイミング';

  @override
  String get notificationTime => '通知時刻';

  @override
  String get onTheDay => '当日';

  @override
  String get daysBefore => '日前';

  @override
  String get editAnniversary => '記念日を編集';

  @override
  String get date => '日付';

  @override
  String get pickImage => '画像を選ぶ';

  @override
  String get changeImage => '画像を変更';

  @override
  String get removeImage => '画像を削除';

  @override
  String get imageUpdated => '画像を更新しました。';

  @override
  String get imageRemoved => '画像を削除しました。';

  @override
  String get noImageSelected => '画像が選択されていません。';
}
