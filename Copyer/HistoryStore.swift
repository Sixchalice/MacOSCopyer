//
//  HistoryStore.swift
//  Copyer
//

import Combine
import Foundation
import AppKit

struct ClipboardItem: Identifiable {
    let id: UUID
    let content: String
    let date: Date

    var preview: String {
        let maxLength = 80
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count <= maxLength { return trimmed }
        return String(trimmed.prefix(maxLength)) + "…"
    }

    init(id: UUID = UUID(), content: String, date: Date = Date()) {
        self.id = id
        self.content = content
        self.date = date
    }
}

@MainActor
final class HistoryStore: ObservableObject {
    static let maxItems = 100

    @Published private(set) var items: [ClipboardItem] = []
    var onPasteFromHistory: (() -> Void)?

    /// When true, the next clipboard change(s) should be ignored (we just wrote to pasteboard).
    var skipNextChangeCountUpdates: Int = 0

    func add(_ item: ClipboardItem) {
        let trimmed = item.content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return }
        if items.first?.content == trimmed { return }
        items.insert(item, at: 0)
        if items.count > Self.maxItems {
            items.removeLast()
        }
    }

    func writeToPasteboardAndNotifyPaste(_ item: ClipboardItem) {
        skipNextChangeCountUpdates = 2
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.content, forType: .string)
        onPasteFromHistory?()
    }
}
