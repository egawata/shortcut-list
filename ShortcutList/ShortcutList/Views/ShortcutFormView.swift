import SwiftUI

struct ShortcutFormView: View {
  @ObservedObject var shortcutStore: ShortcutStore
  @Environment(\.dismiss) private var dismiss

  @State private var applicationName = ""
  @State private var featureDescription = ""
  @State private var shortcutKey = ""

  var body: some View {
    NavigationStack {
      Form {
        Section(header: Text("アプリケーション情報")) {
          TextField("アプリケーション名", text: $applicationName)
        }

        Section(header: Text("ショートカット情報")) {
          TextField("機能の説明", text: $featureDescription)
          TextField("ショートカットキー (例: ⌘ + C)", text: $shortcutKey)
        }
      }
      .navigationTitle("ショートカットの追加")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("キャンセル") {
            dismiss()
          }
        }

        ToolbarItem(placement: .confirmationAction) {
          Button("保存") {
            saveShortcut()
          }
          .disabled(!isFormValid)
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private var isFormValid: Bool {
    !applicationName.isEmpty && !featureDescription.isEmpty && !shortcutKey.isEmpty
  }

  private func saveShortcut() {
    let newShortcut = Shortcut(
      applicationName: applicationName,
      featureDescription: featureDescription,
      shortcutKey: shortcutKey
    )

    shortcutStore.addShortcut(newShortcut)
    dismiss()
  }
}

struct ShortcutFormView_Previews: PreviewProvider {
  static var previews: some View {
    ShortcutFormView(shortcutStore: ShortcutStore())
  }
}
