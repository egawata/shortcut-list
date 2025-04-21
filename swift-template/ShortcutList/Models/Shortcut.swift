import Foundation

struct Shortcut: Identifiable, Codable {
    var id = UUID()
    var applicationName: String
    var featureDescription: String
    var shortcutKey: String
    
    func matches(query: String) -> Bool {
        let lowercasedQuery = query.lowercased()
        return applicationName.lowercased().contains(lowercasedQuery) ||
               featureDescription.lowercased().contains(lowercasedQuery)
    }
}

class ShortcutStore: ObservableObject {
    @Published var shortcuts: [Shortcut] = []
    
    private var fileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("shortcuts.json")
    }
    
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
        do {
            let data = try JSONEncoder().encode(shortcuts)
            try data.write(to: fileURL)
        } catch {
            print("ショートカットの保存に失敗しました: \(error.localizedDescription)")
        }
    }
    
    private func loadShortcuts() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: fileURL)
            shortcuts = try JSONDecoder().decode([Shortcut].self, from: data)
        } catch {
            print("ショートカットの読み込みに失敗しました: \(error.localizedDescription)")
        }
    }
    
    func filterByApplication(name: String) -> [Shortcut] {
        guard !name.isEmpty else { return shortcuts }
        return shortcuts.filter { $0.applicationName.lowercased().contains(name.lowercased()) }
    }
    
    func filterByFeature(description: String) -> [Shortcut] {
        guard !description.isEmpty else { return shortcuts }
        return shortcuts.filter { $0.featureDescription.lowercased().contains(description.lowercased()) }
    }
}
