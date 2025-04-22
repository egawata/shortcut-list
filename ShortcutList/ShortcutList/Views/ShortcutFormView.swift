import AppKit
import Combine
import SwiftUI

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
                        KeyEventHandlingView(
                            text: $shortcutKey,
                            onTab: {
                                focusedField = .saveButton
                            }
                        )
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
                    .paragraphStyle: paragraphStyle,
                ]

                let textRect = NSRect(x: 5, y: 0, width: bounds.width - 10, height: bounds.height)
                text.draw(in: textRect, withAttributes: attributes)
            } else {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .left

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(ofSize: NSFont.systemFontSize),
                    .foregroundColor: NSColor.placeholderTextColor,
                    .paragraphStyle: paragraphStyle,
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

        override func keyDown(with event: NSEvent) {
            if event.keyCode == 48 {  // Tabキーのキーコード
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

            if isFunctionKey(event.keyCode) {
                let functionKeyNumber = functionKeyNumber(from: event.keyCode)
                if functionKeyNumber > 0 {
                    keys.append("F\(functionKeyNumber)")
                    text = keys.joined(separator: " + ")
                    onTextChange?(text)
                }
                return
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
            return (keyCode >= 82 && keyCode <= 92) || keyCode == 65 || keyCode == 67
                || keyCode == 69 || keyCode == 75 || keyCode == 78 || keyCode == 81 || keyCode == 76
        }

        private func isFunctionKey(_ keyCode: UInt16) -> Bool {
            let functionKeyCodes: Set<UInt16> = [
                122, 120, 99, 118, 96, 97, 98, 100, 101, 109, 103, 111, 105, 107, 113, 106, 64, 79,
                80, 90,
            ]
            return functionKeyCodes.contains(keyCode)
        }

        private func functionKeyNumber(from keyCode: UInt16) -> Int {
            switch keyCode {
            case 122: return 1  // F1
            case 120: return 2  // F2
            case 99: return 3  // F3
            case 118: return 4  // F4
            case 96: return 5  // F5
            case 97: return 6  // F6
            case 98: return 7  // F7
            case 100: return 8  // F8
            case 101: return 9  // F9
            case 109: return 10  // F10
            case 103: return 11  // F11
            case 111: return 12  // F12
            case 105: return 13  // F13
            case 107: return 14  // F14
            case 113: return 15  // F15
            case 106: return 16  // F16
            case 64: return 17  // F17
            case 79: return 18  // F18
            case 80: return 19  // F19
            case 90: return 20  // F20
            default: return 0
            }
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
