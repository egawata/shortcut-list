
import uuid
from dataclasses import dataclass, field
from typing import List, Optional


@dataclass
class Shortcut:
    """ショートカットを表すデータクラス"""
    application_name: str
    feature_description: str
    shortcut_key: str
    id: str = field(default_factory=lambda: str(uuid.uuid4()))
    
    def matches(self, query: str) -> bool:
        """検索クエリに一致するかどうかを判定"""
        query = query.lower()
        return (
            query in self.application_name.lower() or
            query in self.feature_description.lower() or
            query in self.shortcut_key.lower()
        )
    
    def to_dict(self) -> dict:
        """辞書形式に変換"""
        return {
            "id": self.id,
            "application_name": self.application_name,
            "feature_description": self.feature_description,
            "shortcut_key": self.shortcut_key
        }
    
    @classmethod
    def from_dict(cls, data: dict) -> 'Shortcut':
        """辞書からインスタンスを生成"""
        return cls(
            id=data.get("id", str(uuid.uuid4())),
            application_name=data["application_name"],
            feature_description=data["feature_description"],
            shortcut_key=data["shortcut_key"]
        )


class ShortcutStore:
    """ショートカットのコレクションを管理するクラス"""
    def __init__(self):
        self.shortcuts: List[Shortcut] = []
    
    def add_shortcut(self, shortcut: Shortcut) -> None:
        """ショートカットを追加"""
        self.shortcuts.append(shortcut)
    
    def remove_shortcut(self, shortcut_id: str) -> None:
        """ショートカットを削除"""
        self.shortcuts = [s for s in self.shortcuts if s.id != shortcut_id]
    
    def get_all_shortcuts(self) -> List[Shortcut]:
        """すべてのショートカットを取得"""
        return self.shortcuts
    
    def filter_by_application(self, name: str) -> List[Shortcut]:
        """アプリケーション名でフィルタリング"""
        if not name:
            return self.shortcuts
        return [s for s in self.shortcuts if name.lower() in s.application_name.lower()]
    
    def filter_by_feature(self, description: str) -> List[Shortcut]:
        """機能説明でフィルタリング"""
        if not description:
            return self.shortcuts
        return [s for s in self.shortcuts if description.lower() in s.feature_description.lower()]
    
    def search(self, query: str) -> List[Shortcut]:
        """検索クエリに一致するショートカットを取得"""
        if not query:
            return self.shortcuts
        return [s for s in self.shortcuts if s.matches(query)]
    
    def to_dict_list(self) -> List[dict]:
        """辞書のリストに変換"""
        return [s.to_dict() for s in self.shortcuts]
    
    @classmethod
    def from_dict_list(cls, data: List[dict]) -> 'ShortcutStore':
        """辞書のリストからインスタンスを生成"""
        store = cls()
        for item in data:
            store.add_shortcut(Shortcut.from_dict(item))
        return store
