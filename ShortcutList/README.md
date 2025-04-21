# ShortcutList - macOS アプリケーション

macOS Sequoia 15.4 上で動作するショートカットリスト管理アプリケーションです。

## 機能

- アプリケーションごとのショートカット一覧を保持
- 記録する情報: アプリケーション名、機能の説明、ショートカットキー
- ショートカット情報はファイルに保存（デフォルトはアプリケーションのサポートディレクトリ）
- ショートカット登録画面
- フィルタリング機能付きのショートカット一覧画面

## 技術スタック

- Swift 5
- SwiftUI
- macOS Sequoia 15.4 以上

## プロジェクト構造

```
ShortcutList/
├── ShortcutList/
│   ├── Models/
│   │   └── Shortcut.swift        # ショートカットデータモデル
│   ├── Views/
│   │   ├── ContentView.swift     # メインビュー
│   │   ├── ShortcutFormView.swift # ショートカット登録フォーム
│   │   └── ShortcutListView.swift # ショートカット一覧
│   ├── Utilities/
│   │   └── FileManager.swift     # ファイル操作ユーティリティ
│   ├── ShortcutListApp.swift     # アプリケーションエントリーポイント
│   ├── Assets.xcassets/          # アセット
│   └── Info.plist                # アプリケーション情報
└── ShortcutList.xcodeproj/       # Xcodeプロジェクトファイル
```

## 使い方

1. Xcodeでプロジェクトを開く
2. ビルドして実行
3. 「追加」ボタンからショートカットを登録
4. 検索バーと検索範囲セグメントを使ってショートカットをフィルタリング
5. 「保存先を変更」ボタンからショートカットの保存先を変更可能

## ビルド方法

1. Xcode 15以上をインストール
2. プロジェクトを開く: `open ShortcutList.xcodeproj`
3. ビルド: ⌘+B
4. 実行: ⌘+R
