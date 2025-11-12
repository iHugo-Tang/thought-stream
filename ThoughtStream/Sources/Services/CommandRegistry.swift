import Foundation

// Centralized registry for slash-commands.
// - Internal keys are English (stable identifiers)
// - Display labels rely on system localization; no per-language arrays here
struct CommandDef: Hashable {
    let key: String           // e.g. "idiomatic_english"
    let label: String  // default display text (typically English)

    func displayName() -> String {
        let locKey = "command.\(key)"
        return NSLocalizedString(locKey, tableName: nil, bundle: .main, value: label, comment: "Command menu title")
    }
}

enum CommandRegistry {
    // The list of all supported commands
    static let all: [CommandDef] = [
        CommandDef(key: "idiomatic_english", label: "Idiomatic English")
    ]

    // Prefix used to denote a slash-command selection sent via UI menu
    static let slashPrefix = "💡 /"

    static func displayName(for key: String) -> String {
        command(for: key)?.displayName() ?? key
    }

    static func command(for key: String) -> CommandDef? {
        all.first { $0.key == key }
    }

    // Resolve an internal command key from user-visible text.
    // Supports both raw visible label (localized) and slash-wrapped form.
    static func resolveKey(from text: String) -> String? {
        let stripped = stripSlashPrefix(text)
        if let match = all.first(where: { $0.displayName() == stripped }) {
            return match.key
        }
        if all.contains(where: { $0.key == stripped }) {
            return stripped
        }
        return nil
    }

    static func isCommandText(_ text: String) -> Bool {
        resolveKey(from: text) != nil
    }

    static func stripSlashPrefix(_ text: String) -> String {
        if text.hasPrefix(slashPrefix) {
            return String(text.dropFirst(slashPrefix.count))
        }
        return text
    }
}
