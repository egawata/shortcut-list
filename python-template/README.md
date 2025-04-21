# Shortcut List - Python Template

Python と PyQt を使用したショートカットリストアプリケーションのテンプレートです。

## プロジェクト構造

```
python-template/
├── requirements.txt       # 依存関係
├── main.py                # アプリケーションのエントリーポイント
├── models/                # データモデル
│   └── shortcut.py        # ショートカットモデル
├── views/                 # ビュー
│   ├── main_window.py     # メインウィンドウ
│   ├── shortcut_form.py   # ショートカット登録フォーム
│   └── shortcut_list.py   # ショートカット一覧
└── utils/                 # ユーティリティ
    └── file_manager.py    # ファイル保存・読み込み機能
```

## セットアップ手順

1. Python 3.8以上をインストール
2. 依存関係をインストール: `pip install -r requirements.txt`
3. アプリケーションを実行: `python main.py`

## ビルド手順

1. PyInstallerをインストール: `pip install pyinstaller`
2. macOS用にビルド: `pyinstaller --onefile --windowed main.py`
