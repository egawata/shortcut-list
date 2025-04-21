
from PyQt6.QtWidgets import (
    QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, 
    QPushButton, QLineEdit, QRadioButton, QButtonGroup,
    QLabel, QFileDialog, QMessageBox
)
from PyQt6.QtCore import Qt

from models.shortcut import ShortcutStore
from utils.file_manager import FileManager
from views.shortcut_form import ShortcutForm
from views.shortcut_list import ShortcutListWidget


class MainWindow(QMainWindow):
    """アプリケーションのメインウィンドウ"""
    
    def __init__(self):
        super().__init__()
        
        self.file_manager = FileManager()
        self.shortcut_store = self.file_manager.load_shortcuts()
        
        self.init_ui()
    
    def init_ui(self):
        """UIの初期化"""
        self.setWindowTitle("ショートカットリスト")
        self.setMinimumSize(800, 600)
        
        main_widget = QWidget()
        self.setCentralWidget(main_widget)
        
        main_layout = QVBoxLayout(main_widget)
        
        header_layout = QHBoxLayout()
        header_label = QLabel("ショートカットリスト")
        header_label.setStyleSheet("font-size: 18px; font-weight: bold;")
        header_layout.addWidget(header_label)
        
        header_layout.addStretch()
        
        self.add_button = QPushButton("ショートカットを追加")
        self.add_button.clicked.connect(self.show_add_form)
        header_layout.addWidget(self.add_button)
        
        self.change_location_button = QPushButton("保存先を変更")
        self.change_location_button.clicked.connect(self.change_save_location)
        header_layout.addWidget(self.change_location_button)
        
        main_layout.addLayout(header_layout)
        
        search_layout = QVBoxLayout()
        
        self.search_input = QLineEdit()
        self.search_input.setPlaceholderText("検索...")
        self.search_input.textChanged.connect(self.filter_shortcuts)
        search_layout.addWidget(self.search_input)
        
        scope_layout = QHBoxLayout()
        scope_layout.addWidget(QLabel("検索範囲:"))
        
        self.scope_group = QButtonGroup(self)
        
        self.all_radio = QRadioButton("すべて")
        self.all_radio.setChecked(True)
        self.scope_group.addButton(self.all_radio)
        scope_layout.addWidget(self.all_radio)
        
        self.app_radio = QRadioButton("アプリケーション名")
        self.scope_group.addButton(self.app_radio)
        scope_layout.addWidget(self.app_radio)
        
        self.feature_radio = QRadioButton("機能")
        self.scope_group.addButton(self.feature_radio)
        scope_layout.addWidget(self.feature_radio)
        
        scope_layout.addStretch()
        search_layout.addLayout(scope_layout)
        
        main_layout.addLayout(search_layout)
        
        self.shortcut_list = ShortcutListWidget()
        self.shortcut_list.set_shortcuts(self.shortcut_store.get_all_shortcuts())
        self.shortcut_list.shortcut_deleted.connect(self.delete_shortcut)
        main_layout.addWidget(self.shortcut_list)
        
        for radio in [self.all_radio, self.app_radio, self.feature_radio]:
            radio.toggled.connect(self.filter_shortcuts)
    
    def show_add_form(self):
        """ショートカット追加フォームを表示"""
        dialog = ShortcutForm(self)
        if dialog.exec():
            shortcut = dialog.get_shortcut()
            self.shortcut_store.add_shortcut(shortcut)
            self.file_manager.save_shortcuts(self.shortcut_store)
            self.filter_shortcuts()  # リストを更新
    
    def delete_shortcut(self, shortcut_id):
        """ショートカットを削除"""
        self.shortcut_store.remove_shortcut(shortcut_id)
        self.file_manager.save_shortcuts(self.shortcut_store)
        self.filter_shortcuts()  # リストを更新
    
    def filter_shortcuts(self):
        """ショートカットをフィルタリング"""
        query = self.search_input.text()
        
        if self.app_radio.isChecked():
            filtered = self.shortcut_store.filter_by_application(query)
        elif self.feature_radio.isChecked():
            filtered = self.shortcut_store.filter_by_feature(query)
        else:  # all_radio
            filtered = self.shortcut_store.search(query)
        
        self.shortcut_list.set_shortcuts(filtered)
    
    def change_save_location(self):
        """保存先を変更"""
        file_path, _ = QFileDialog.getSaveFileName(
            self,
            "保存先を選択",
            str(self.file_manager.file_path),
            "JSONファイル (*.json)"
        )
        
        if file_path:
            self.file_manager.change_file_path(file_path)
            success = self.file_manager.save_shortcuts(self.shortcut_store)
            
            if success:
                QMessageBox.information(self, "成功", "保存先を変更しました。")
            else:
                QMessageBox.warning(self, "エラー", "保存先の変更に失敗しました。")
