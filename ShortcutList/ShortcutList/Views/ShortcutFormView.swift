import SwiftUI

struct ShortcutFormView: View {
    @ObservedObject var shortcutStore: ShortcutStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var applicationName = ""
    @State private var featureDescription = ""
    @State private var shortcutKey = ""
    
    enum Field: Int, Hashable {
        case applicationName
        case featureDescription
        case shortcutKey
        case saveButton
    }
    
    @FocusState private var focusedField: Field?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("アプリケーション情報")) {
                    TextField("アプリケーション名", text: $applicationName)
                        .focused($focusedField, equals: .applicationName)
                        .onSubmit {
                            focusedField = .featureDescription
                        }
                }

                Section(header: Text("ショートカット情報")) {
                    TextField("機能の説明", text: $featureDescription)
                        .focused($focusedField, equals: .featureDescription)
                        .onSubmit {
                            focusedField = .shortcutKey
                        }
                    TextField("ショートカットキー (例: ⌘ + C)", text: $shortcutKey)
                        .focused($focusedField, equals: .shortcutKey)
                        .onSubmit {
                            if isFormValid {
                                focusedField = .saveButton
                            }
                        }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
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
                    .focused($focusedField, equals: .saveButton)
                    .disabled(!isFormValid)
                    .keyboardShortcut(.defaultAction) // Activates button with Enter key when focused
                    .onSubmit {
                        if isFormValid {
                            saveShortcut()
                        } else {
                            focusedField = .applicationName
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: focusedField) { oldValue, newValue in
            // If Tab is pressed when on saveButton, cycle back to applicationName
            if oldValue == .saveButton && newValue == nil {
                focusedField = .applicationName
            }
        }
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
