import SwiftUI

struct ShortcutListView: View {
  @ObservedObject var shortcutStore: ShortcutStore
  @State private var searchText = ""
  @State private var searchScope: SearchScope = .all

  enum SearchScope {
    case all, application, feature
  }

  var filteredShortcuts: [Shortcut] {
    if searchText.isEmpty {
      return shortcutStore.shortcuts
    }

    switch searchScope {
    case .all:
      return shortcutStore.shortcuts.filter { $0.matches(query: searchText) }
    case .application:
      return shortcutStore.filterByApplication(name: searchText)
    case .feature:
      return shortcutStore.filterByFeature(description: searchText)
    }
  }

  var body: some View {
    VStack {
      Picker("検索範囲", selection: $searchScope) {
        Text("すべて").tag(SearchScope.all)
        Text("アプリケーション").tag(SearchScope.application)
        Text("機能").tag(SearchScope.feature)
      }
      .pickerStyle(SegmentedPickerStyle())
      .padding(.horizontal)

      List {
        ForEach(filteredShortcuts) { shortcut in
          ShortcutRow(shortcut: shortcut)
        }
        .onDelete { indexSet in
          let shortcutsToDelete = indexSet.map { filteredShortcuts[$0] }

          for shortcut in shortcutsToDelete {
            if let index = shortcutStore.shortcuts.firstIndex(where: { $0.id == shortcut.id }) {
              shortcutStore.deleteShortcut(at: IndexSet(integer: index))
            }
          }
        }
      }
      .searchable(text: $searchText, prompt: "検索")
    }
  }
}

struct ShortcutRow: View {
  let shortcut: Shortcut

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(shortcut.applicationName)
        .font(.headline)

      HStack {
        Text(shortcut.featureDescription)
          .font(.subheadline)
        Spacer()
        Text(shortcut.shortcutKey)
          .font(.system(.body, design: .monospaced))
          .padding(4)
          .background(Color.gray.opacity(0.2))
          .cornerRadius(4)
      }
    }
    .padding(.vertical, 4)
  }
}

struct ShortcutListView_Previews: PreviewProvider {
  static var previews: some View {
    ShortcutListView(shortcutStore: ShortcutStore())
  }
}
