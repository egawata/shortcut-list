import Foundation
import AppKit

extension FileManager {
    class ShortcutFileManager {
        static let shared = ShortcutFileManager()
        
        private var currentFileURL: URL
        
        private init() {
            let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let appDir = appSupportDir.appendingPathComponent("ShortcutList", isDirectory: true)
            
            if !FileManager.default.fileExists(atPath: appDir.path) {
                try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
            }
            
            currentFileURL = appDir.appendingPathComponent("shortcuts.json")
        }
        
        func changeFileLocation(to url: URL) {
            currentFileURL = url
        }
        
        func saveShortcuts(_ shortcuts: [Shortcut]) -> Bool {
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let data = try encoder.encode(shortcuts)
                try data.write(to: currentFileURL)
                return true
            } catch {
                print("ショートカットの保存に失敗しました: \(error.localizedDescription)")
                return false
            }
        }
        
        func loadShortcuts() -> [Shortcut] {
            guard FileManager.default.fileExists(atPath: currentFileURL.path) else {
                return []
            }
            
            do {
                let data = try Data(contentsOf: currentFileURL)
                let shortcuts = try JSONDecoder().decode([Shortcut].self, from: data)
                return shortcuts
            } catch {
                print("ショートカットの読み込みに失敗しました: \(error.localizedDescription)")
                return []
            }
        }
        
        func showSavePanel(completion: @escaping (URL?) -> Void) {
            let savePanel = NSSavePanel()
            savePanel.title = "ショートカットの保存先を選択"
            savePanel.nameFieldStringValue = "shortcuts.json"
            savePanel.allowedContentTypes = [.json]
            savePanel.canCreateDirectories = true
            
            savePanel.begin { response in
                if response == .OK, let url = savePanel.url {
                    completion(url)
                } else {
                    completion(nil)
                }
            }
        }
        
        var fileURL: URL {
            return currentFileURL
        }
    }
}
