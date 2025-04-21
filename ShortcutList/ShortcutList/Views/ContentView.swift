import SwiftUI

struct ContentView: View {
  @StateObject private var shortcutStore = ShortcutStore()
  @State private var isShowingAddSheet = false
  @State private var isShowingFileLocationSheet = false
  @State private var fileLocationMessage = ""
  @State private var showingFileLocationAlert = false

  var body: some View {
    NavigationView {
      ShortcutListView(shortcutStore: shortcutStore)
        .navigationTitle("ショートカット一覧")
        .toolbar {
          ToolbarItem(placement: .primaryAction) {
            Button(action: {
              isShowingAddSheet = true
            }) {
              Label("追加", systemImage: "plus")
            }
          }

          ToolbarItem(placement: .automatic) {
            Button(action: {
              shortcutStore.changeFileLocation { success in
                fileLocationMessage =
                  success ? "保存先を変更しました: \(shortcutStore.currentFilePath)" : "保存先の変更に失敗しました"
                showingFileLocationAlert = true
              }
            }) {
              Label("保存先を変更", systemImage: "folder")
            }
          }
        }
        .sheet(isPresented: $isShowingAddSheet) {
          ShortcutFormView(shortcutStore: shortcutStore)
        }
        .alert("保存先の変更", isPresented: $showingFileLocationAlert) {
          Button("OK", role: .cancel) {}
        } message: {
          Text(fileLocationMessage)
        }
    }
    .frame(minWidth: 700, minHeight: 500)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
