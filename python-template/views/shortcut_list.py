
from PyQt6.QtWidgets import (
    QWidget, QVBoxLayout, QTableWidget, QTableWidgetItem,
    QPushButton, QHBoxLayout, QHeaderView
)
from PyQt6.QtCore import Qt, pyqtSignal
from typing import List

from models.shortcut import Shortcut


class ShortcutListWidget(QWidget):
    """ショートカット一覧を表示するウィジェット"""
    
    shortcut_deleted = pyqtSignal(str)  # ショートカットIDを送信
    
    def __init__(self, parent=None):
        super().__init__(parent)
        
        self.shortcuts = []
        self.init_ui()
    
    def init_ui(self):
        """UIの初期化"""
        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        
        self.table = QTableWidget()
        self.table.setColumnCount(4)
        self.table.setHorizontalHeaderLabels(["アプリケーション", "機能", "ショートカット", "操作"])
        
        header = self.table.horizontalHeader()
        header.setSectionResizeMode(0, QHeaderView.ResizeMode.Stretch)
        header.setSectionResizeMode(1, QHeaderView.ResizeMode.Stretch)
        header.setSectionResizeMode(2, QHeaderView.ResizeMode.ResizeToContents)
        header.setSectionResizeMode(3, QHeaderView.ResizeMode.ResizeToContents)
        
        layout.addWidget(self.table)
    
    def set_shortcuts(self, shortcuts: List[Shortcut]):
        """
        ショートカットリストを設定
        
        Args:
            shortcuts: ショートカットのリスト
        """
        self.shortcuts = shortcuts
        self.update_table()
    
    def update_table(self):
        """テーブルを更新"""
        self.table.setRowCount(0)
        
        for i, shortcut in enumerate(self.shortcuts):
            self.table.insertRow(i)
            
            app_item = QTableWidgetItem(shortcut.application_name)
            app_item.setFlags(app_item.flags() & ~Qt.ItemFlag.ItemIsEditable)
            self.table.setItem(i, 0, app_item)
            
            feature_item = QTableWidgetItem(shortcut.feature_description)
            feature_item.setFlags(feature_item.flags() & ~Qt.ItemFlag.ItemIsEditable)
            self.table.setItem(i, 1, feature_item)
            
            key_item = QTableWidgetItem(shortcut.shortcut_key)
            key_item.setFlags(key_item.flags() & ~Qt.ItemFlag.ItemIsEditable)
            self.table.setItem(i, 2, key_item)
            
            button_widget = QWidget()
            button_layout = QHBoxLayout(button_widget)
            button_layout.setContentsMargins(2, 2, 2, 2)
            
            delete_button = QPushButton("削除")
            delete_button.setProperty("shortcut_id", shortcut.id)
            delete_button.clicked.connect(self.on_delete_clicked)
            button_layout.addWidget(delete_button)
            
            self.table.setCellWidget(i, 3, button_widget)
    
    def on_delete_clicked(self):
        """削除ボタンがクリックされたときの処理"""
        button = self.sender()
        shortcut_id = button.property("shortcut_id")
        self.shortcut_deleted.emit(shortcut_id)
