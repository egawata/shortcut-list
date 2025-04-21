
import json
import os
from pathlib import Path
from typing import List, Dict, Any, Optional

from models.shortcut import ShortcutStore, Shortcut


class FileManager:
    """ショートカットデータのファイル操作を管理するクラス"""
    
    def __init__(self, file_path: Optional[str] = None):
        """
        初期化
        
        Args:
            file_path: ファイルパス。指定しない場合はデフォルトのパスを使用
        """
        if file_path:
            self.file_path = Path(file_path)
        else:
            app_dir = Path.home() / "ShortcutList"
            app_dir.mkdir(exist_ok=True)
            self.file_path = app_dir / "shortcuts.json"
    
    def save_shortcuts(self, store: ShortcutStore) -> bool:
        """
        ショートカットをファイルに保存
        
        Args:
            store: 保存するショートカットストア
            
        Returns:
            bool: 保存に成功したかどうか
        """
        try:
            data = store.to_dict_list()
            with open(self.file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            return True
        except Exception as e:
            print(f"保存エラー: {e}")
            return False
    
    def load_shortcuts(self) -> ShortcutStore:
        """
        ファイルからショートカットを読み込み
        
        Returns:
            ShortcutStore: 読み込んだショートカットストア
        """
        store = ShortcutStore()
        
        if not self.file_path.exists():
            return store
        
        try:
            with open(self.file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            return ShortcutStore.from_dict_list(data)
        except Exception as e:
            print(f"読み込みエラー: {e}")
            return store
    
    def change_file_path(self, new_path: str) -> None:
        """
        ファイルパスを変更
        
        Args:
            new_path: 新しいファイルパス
        """
        self.file_path = Path(new_path)
