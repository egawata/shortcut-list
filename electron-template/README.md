# Shortcut List - Electron Template

Electron を使用したショートカットリストアプリケーションのテンプレートです。

## プロジェクト構造

```
electron-template/
├── package.json           # プロジェクト設定
├── main.js                # メインプロセス
├── preload.js             # プリロードスクリプト
├── renderer/              # レンダラープロセス
│   ├── index.html         # メインウィンドウのHTML
│   ├── styles.css         # スタイルシート
│   └── renderer.js        # レンダラープロセスのJavaScript
└── src/
    ├── models/            # データモデル
    │   └── shortcut.js    # ショートカットモデル
    ├── storage/           # データ保存
    │   └── storage.js     # ファイル保存・読み込み機能
    └── views/             # ビュー関連
        ├── list.js        # ショートカット一覧
        └── form.js        # ショートカット登録フォーム
```

## セットアップ手順

1. Node.jsとnpmをインストール
2. 依存関係をインストール: `npm install`
3. アプリケーションを実行: `npm start`

## ビルド手順

1. macOS用にビルド: `npm run build:mac`
