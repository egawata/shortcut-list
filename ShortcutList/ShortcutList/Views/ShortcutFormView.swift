import SwiftUI
import AppKit
import Combine

struct ShortcutFormView: View {
    @ObservedObject var shortcutStore: ShortcutStore
    @Environment(\.dismiss) private var dismiss

    @State private var applicationName = ""
    @State private var featureDescription = ""
    @State private var shortcutKey = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case appName, featureDesc, shortcutKey, saveButton
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("アプリケーション情報")) {
                    TextField("アプリケーション名", text: $applicationName)
                        .focused($focusedField, equals: .appName)
                }

                Section(header: Text("ショートカット情報")) {
                    TextField("機能の説明", text: $featureDescription)
                        .focused($focusedField, equals: .featureDesc)
                    
                    ZStack(alignment: .leading) {
                        if shortcutKey.isEmpty {
                            Text("ショートカットキー (例: ⌘ + C)")
                                .foregroundColor(Color(.placeholderTextColor))
                        }
                        KeyEventHandlingView(text: $shortcutKey, onTab: {
                            focusedField = .saveButton
                        })
                        .frame(height: 22)
                        .background(Color(.textBackgroundColor))
                        .cornerRadius(4)
                    }
                    .padding(.vertical, 4)
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

struct KeyEventHandlingView: NSViewRepresentable {
    @Binding var text: String
    var onTab: () -> Void
    
    class KeyEventHandlingNSView: NSView {
        var text: String = "" {
            didSet {
                needsDisplay = true
            }
        }
        var onTextChange: ((String) -> Void)?
        var onTab: (() -> Void)?
        
        override var acceptsFirstResponder: Bool { true }
        
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            window?.makeFirstResponder(self)
        }
        
        override func draw(_ dirtyRect: NSRect) {
            super.draw(dirtyRect)
            
            NSColor.textBackgroundColor.setFill()
            let path = NSBezierPath(roundedRect: bounds, xRadius: 4, yRadius: 4)
            path.fill()
            
            NSColor.separatorColor.setStroke()
            path.lineWidth = 1
            path.stroke()
            
            if !text.isEmpty {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .left
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(ofSize: NSFont.systemFontSize),
                    .foregroundColor: NSColor.textColor,
                    .paragraphStyle: paragraphStyle
                ]
                
                let textRect = NSRect(x: 5, y: 0, width: bounds.width - 10, height: bounds.height)
                text.draw(in: textRect, withAttributes: attributes)
            } else {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .left
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(ofSize: NSFont.systemFontSize),
                    .foregroundColor: NSColor.placeholderTextColor,
                    .paragraphStyle: paragraphStyle
                ]
                
                let placeholder = "ショートカットキー (例: ⌘ + C)"
                let textRect = NSRect(x: 5, y: 0, width: bounds.width - 10, height: bounds.height)
                placeholder.draw(in: textRect, withAttributes: attributes)
            }
        }
        
        override func drawFocusRingMask() {
            let path = NSBezierPath(roundedRect: bounds, xRadius: 4, yRadius: 4)
            path.fill()
        }
        
        override func keyDown(with event: NSEvent) -> Void {
            if event.keyCode == 48 { // Tabキーのキーコード
                onTab?()
                return
            }
            
            var keys: [String] = []
            
            if event.modifierFlags.contains(.command) {
                keys.append("⌘")
            }
            if event.modifierFlags.contains(.shift) {
                keys.append("⇧")
            }
            if event.modifierFlags.contains(.option) {
                keys.append("⌥")
            }
            if event.modifierFlags.contains(.control) {
                keys.append("⌃")
            }
            
            if let character = event.charactersIgnoringModifiers?.uppercased(), !character.isEmpty {
                let isNumpadKey = isNumpadKeyCode(event.keyCode)
                
                if isNumpadKey {
                    keys.append("Num\(character)")
                } else {
                    keys.append(character)
                }
            }
            
            if !keys.isEmpty {
                text = keys.joined(separator: " + ")
                onTextChange?(text)
            }
        }
        
        private func isNumpadKeyCode(_ keyCode: UInt16) -> Bool {
            return (keyCode >= 82 && keyCode <= 92)
        }
    }
    
    func makeNSView(context: Context) -> KeyEventHandlingNSView {
        let view = KeyEventHandlingNSView()
        view.onTextChange = { newText in
            DispatchQueue.main.async {
                self.text = newText
            }
        }
        view.onTab = onTab
        view.text = text
        return view
    }
    
    func updateNSView(_ nsView: KeyEventHandlingNSView, context: Context) {
        nsView.text = text
    }
}

struct ShortcutFormView_Previews: PreviewProvider {
    static var previews: some View {
        ShortcutFormView(shortcutStore: ShortcutStore())
    }
}
