# 明星大学 3Dキャンパスマップ & 時間割アプリ

明星大学（日野キャンパス）の3Dキャンパスマップと時間割を連携させたクロスプラットフォームアプリです。

## 主な機能

- **3Dキャンパスマップ**: Project PLATEAU の3D都市モデル（日野市）を Cesium.js でリアルタイム描画
- **時間割連携**: 授業を選択すると3Dマップ上で該当建物をハイライト表示
- **次の授業案内**: 現在時刻から次の授業までの時間を上部バナーで表示
- **アカウント同期**: Firebase Auth + Firestore により iPhone・Android・Windows でデータを同期
- **オフライン対応**: Hive によるローカルキャッシュで通信不安定時も利用可能

## 対応プラットフォーム

| Platform | 状態 |
|----------|------|
| iOS (iPhone) | ✅ |
| Android | ✅ |
| Windows | ✅ |

## 技術スタック

| 項目 | 技術 |
|------|------|
| フレームワーク | Flutter 3.x |
| 状態管理 | Riverpod 2.x |
| ナビゲーション | go_router |
| 認証 | Firebase Auth |
| データ同期 | Cloud Firestore |
| ローカルキャッシュ | Hive |
| 3Dマップ | Cesium.js (WebView経由) |
| 3D都市モデル | Project PLATEAU (国土交通省) |

## セットアップ

### 1. Firebase プロジェクトの作成

```bash
# flutterfire CLI をインストール
dart pub global activate flutterfire_cli

# Firebase プロジェクトに接続 (firebase-tools が必要)
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

`lib/firebase_options.dart` が自動生成されます。  
現在のファイルはスタブです。本番利用前に必ず差し替えてください。

### 2. Cesium Ion トークンの設定

`assets/html/campus_map.html` の以下の行を実際のトークンに差し替えてください。

```javascript
Cesium.Ion.defaultAccessToken = 'YOUR_CESIUM_ION_TOKEN';
```

無料トークンは https://ion.cesium.com/ で取得できます。

### 3. PLATEAU 3D Tiles

本アプリは日野市の PLATEAU 3D Tiles を使用します。

```
https://plateau.geospatial.jp/main/data/3d-tiles/bldg/13201_hino/low_resolution/tileset.json
```

利用条件: [Project PLATEAU 利用規約](https://www.mlit.go.jp/plateau/use-policy/)

### 4. アプリのビルド・実行

```bash
# 依存パッケージのインストール
flutter pub get

# iOS
flutter run -d ios

# Android
flutter run -d android

# Windows
flutter run -d windows
```

## プロジェクト構成

```
lib/
├── main.dart               # エントリポイント
├── app.dart                # アプリルート
├── firebase_options.dart   # Firebase設定（要差替）
├── core/
│   ├── theme/              # テーマ定義
│   ├── models/             # データモデル (Building, Room, Course, etc.)
│   └── services/           # サービス (Auth, Firestore, LocalCache)
├── features/
│   ├── auth/               # 認証 (ログイン・登録)
│   ├── map/                # 3Dマップ画面
│   ├── timetable/          # 時間割画面
│   └── settings/           # 設定画面
└── router/                 # ルーティング
assets/
├── data/
│   ├── buildings.json      # 建物マスタ
│   └── rooms.json          # 教室マスタ
└── html/
    └── campus_map.html     # Cesium.js 3Dマップページ
```

## データモデル

### Building (建物)
| フィールド | 型 | 説明 |
|-----------|-----|------|
| id | String | 建物ID (A, B, C...) |
| name | String | 建物名 |
| lat/lng | double | 緯度経度 |
| plateauBuildingId | String | PLATEAU建物ID |

### Course (授業)
| フィールド | 型 | 説明 |
|-----------|-----|------|
| id | String | UUID |
| name | String | 科目名 |
| dayOfWeek | int | 曜日 (1=月...6=土) |
| period | int | 時限 (1〜6) |
| roomId | String | 教室ID |
| buildingId | String | 建物ID |

## 時限設定（明星大学）

| 時限 | 開始 | 終了 |
|------|------|------|
| 1限 | 08:50 | 10:20 |
| 2限 | 10:30 | 12:00 |
| 3限 | 13:00 | 14:30 |
| 4限 | 14:40 | 16:10 |
| 5限 | 16:20 | 17:50 |
| 6限 | 18:00 | 19:30 |

## ライセンス

MIT License

3D都市モデルデータ: Project PLATEAU (国土交通省) - CC BY 4.0
