
from PyQt6.QtWidgets import (
    QDialog, QVBoxLayout, QHBoxLayout, QFormLayout,
    QLabel, QLineEdit, QPushButton, QDialogButtonBox
)
from PyQt6.QtCore import Qt

from models.shortcut import Shortcut


class ShortcutForm(QDialog):
    """ショートカット追加・編集用のフォームダイアログ"""
    
    def __init__(self, parent=None, shortcut=None):
        """
        初期化
        
        Args:
            parent: 親ウィジェット
            shortcut: 編集する場合は既存のショートカット
        """
        super().__init__(parent)
        
        self.shortcut = shortcut
        self.init_ui()
        
        if shortcut:
            self.setWindowTitle("ショートカットを編集")
            self.populate_form(shortcut)
        else:
            self.setWindowTitle("ショートカットを追加")
    
    def init_ui(self):
        """UIの初期化"""
        self.setMinimumWidth(400)
        
        layout = QVBoxLayout(self)
        
        form_layout = QFormLayout()
        
        self.app_name_input = QLineEdit()
        form_layout.addRow("アプリケーション名:", self.app_name_input)
        
        self.feature_desc_input = QLineEdit()
        form_layout.addRow("機能の説明:", self.feature_desc_input)
        
        self.shortcut_key_input = QLineEdit()
        self.shortcut_key_input.setPlaceholderText("例: ⌘ + C")
        form_layout.addRow("ショートカットキー:", self.shortcut_key_input)
        
        layout.addLayout(form_layout)
        
        button_box = QDialogButtonBox(
            QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel
        )
        button_box.accepted.connect(self.accept)
        button_box.rejected.connect(self.reject)
        
        layout.addWidget(button_box)
    
    def populate_form(self, shortcut):
        """
        フォームに既存のショートカット情報を入力
        
        Args:
            shortcut: 既存のショートカット
        """
        self.app_name_input.setText(shortcut.application_name)
        self.feature_desc_input.setText(shortcut.feature_description)
        self.shortcut_key_input.setText(shortcut.shortcut_key)
    
    def accept(self):
        """OKボタンが押されたときの処理"""
        if not self.app_name_input.text() or not self.feature_desc_input.text() or not self.shortcut_key_input.text():
            return
        
        super().accept()
    
    def get_shortcut(self) -> Shortcut:
        """
        入力されたショートカット情報を取得
        
        Returns:
            Shortcut: 新しいショートカットオブジェクト
        """
        if self.shortcut:
            self.shortcut.application_name = self.app_name_input.text()
            self.shortcut.feature_description = self.feature_desc_input.text()
            self.shortcut.shortcut_key = self.shortcut_key_input.text()
            return self.shortcut
        else:
            return Shortcut(
                application_name=self.app_name_input.text(),
                feature_description=self.feature_desc_input.text(),
                shortcut_key=self.shortcut_key_input.text()
            )
