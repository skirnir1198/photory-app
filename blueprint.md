# 記念日アプリ 設計書

## 概要

このアプリは、ユーザーが個人的な記念日を記録し、その日からの経過日数を追跡できるFlutterアプリケーションです。Firebase Authenticationによるユーザー認証、Firestoreによるデータ永続化、Firebase Storageによる画像保存を特徴とします。

## 機能一覧

### 1. ユーザー認証
- メールアドレスとパスワードによるサインアップおよびログイン機能。
- 認証状態に応じて、ホーム画面またはログイン画面に自動的にリダイレクト。

### 2. 記念日の管理 (CRUD)

#### **記念日の追加 (Create)**
- ホーム画面のAppBarにある「+」ボタンをタップすると、画面右側から入力用のドロワーが表示されます。
- ドロワーには以下の要素が含まれます:
    - 記念日名を入力するテキストフィールド
    - 記念日の日付を選択するカレンダーピッカー
    - 記念日の画像を選択するボタン
    - 「記念日を追加」ボタン
- 追加された記念日と画像はFirestoreとFirebase Storageに保存されます。

#### **記念日の表示 (Read)**
- ホーム画面の下部に、登録されている記念日がリスト形式で表示されます。
- 各リストアイテムには、記念日の名称と、その日から今日までの経過日数が表示されます。
- 記念日データはFirestoreからリアルタイムでストリーミングされます。

#### **記念日の詳細・編集 (Update)**
- リスト内の記念日をタップすると、その記念日の詳細画面に遷移します。
- 詳細画面には、登録された画像、記念日名、経過日数が表示されます。
- 詳細画面の右上に「編集」ボタンが配置されます。
- 「編集」ボタンをタップすると編集ページに遷移し、記念日名、日付、画像を更新できます。
- 更新された情報はFirestoreとFirebase Storageに保存されます。

#### **記念日の削除 (Delete)**
- 編集ページに「削除」ボタンが配置されます。
- 削除ボタンをタップすると、確認ダイアログが表示された後、記念日と関連画像がFirestoreとFirebase Storageから削除されます。

## 画面設計

1.  **認証画面 (`auth_wrapper.dart`, `login_screen.dart`など)**
    *   ログインフォームと新規登録フォームを提供します。

2.  **ホーム画面 (`anniversary_screen.dart`)**
    *   **AppBar**:
        *   タイトル: `記念日一覧`
        *   アクション:
            *   ログアウトボタン
            *   記念日追加用の「+」アイコンボタン
    *   **EndDrawer (記念日追加用)**:
        *   記念日名入力フィールド
        *   日付選択ボタン
        *   画像選択ボタン
        *   追加実行ボタン
    *   **Body**:
        *   登録済み記念日のリストを`ListView`で表示。
        *   各アイテムには経過日数と記念日名を表示。

3.  **記念日詳細画面 (`anniversary_detail_screen.dart`)**
    *   **AppBar**:
        *   タイトル: 記念日名
        *   アクション: 編集ボタン
    *   **Body**:
        *   記念日の画像、詳細情報（日付など）を表示。

4.  **記念日編集画面 (`edit_anniversary_screen.dart`)**
    *   **AppBar**:
        *   タイトル: `記念日の編集`
        *   アクション: 削除ボタン
    *   **Body**:
        *   記念日名、日付、画像を編集するためのフォーム。
        *   「更新」ボタンを配置。

## データモデル (`milestone.dart`)

Firestoreに保存される記念日（Milestone）のデータ構造は以下の通りです。

```dart
@freezed
class Milestone with _$Milestone {
  const factory Milestone({
    String? id,
    required String title,
    required DateTime date,
    required String userId,
    String? imageUrl,
  }) = _Milestone;

  factory Milestone.fromJson(Map<String, dynamic> json) => _$MilestoneFromJson(json);
}
```

## 使用する主要パッケージ

- `firebase_auth`: ユーザー認証
- `cloud_firestore`: データベース
- `firebase_storage`: 画像ストレージ
- `flutter_riverpod` / `provider`: 状態管理
- `intl`: 日付フォーマット
- `image_picker`: 画像選択
- `freezed`: モデルクラスの生成
- `build_runner`: コード生成

