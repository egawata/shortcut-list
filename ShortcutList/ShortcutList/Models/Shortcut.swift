import Foundation

struct Shortcut: Identifiable, Codable, Equatable {
  var id = UUID()
  var applicationName: String
  var featureDescription: String
  var shortcutKey: String

  func matches(query: String) -> Bool {
    let lowercasedQuery = query.lowercased()
    return applicationName.lowercased().contains(lowercasedQuery)
      || featureDescription.lowercased().contains(lowercasedQuery)
      || shortcutKey.lowercased().contains(lowercasedQuery)
  }

  static func == (lhs: Shortcut, rhs: Shortcut) -> Bool {
    return lhs.id == rhs.id
  }
}

class ShortcutStore: ObservableObject {
  @Published var shortcuts: [Shortcut] = []

  init() {
    loadShortcuts()
  }

  func addShortcut(_ shortcut: Shortcut) {
    shortcuts.append(shortcut)
    saveShortcuts()
  }

  func deleteShortcut(at offsets: IndexSet) {
    shortcuts.remove(atOffsets: offsets)
    saveShortcuts()
  }

  private func saveShortcuts() {
    let success = FileManager.ShortcutFileManager.shared.saveShortcuts(shortcuts)
    if !success {
      print("ショートカットの保存に失敗しました")
    }
  }

  private func loadShortcuts() {
    shortcuts = FileManager.ShortcutFileManager.shared.loadShortcuts()
  }

  func filterByApplication(name: String) -> [Shortcut] {
    guard !name.isEmpty else { return shortcuts }
    return shortcuts.filter { $0.applicationName.lowercased().contains(name.lowercased()) }
  }

  func filterByFeature(description: String) -> [Shortcut] {
    guard !description.isEmpty else { return shortcuts }
    return shortcuts.filter {
      $0.featureDescription.lowercased().contains(description.lowercased())
    }
  }

  func changeFileLocation(completion: @escaping (Bool) -> Void) {
    FileManager.ShortcutFileManager.shared.showSavePanel { url in
      guard let url = url else {
        completion(false)
        return
      }

      FileManager.ShortcutFileManager.shared.changeFileLocation(to: url)
      let success = FileManager.ShortcutFileManager.shared.saveShortcuts(self.shortcuts)
      completion(success)
    }
  }

  var currentFilePath: String {
    return FileManager.ShortcutFileManager.shared.fileURL.path
  }
}
