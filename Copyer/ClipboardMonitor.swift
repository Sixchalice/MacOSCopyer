//
//  ClipboardMonitor.swift
//  Copyer
//

import AppKit

@MainActor
final class ClipboardMonitor {
    private var timer: Timer?
    private var lastChangeCount: Int = NSPasteboard.general.changeCount
    private weak var historyStore: HistoryStore?

    func start(historyStore: HistoryStore) {
        self.historyStore = historyStore
        lastChangeCount = NSPasteboard.general.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.checkPasteboard()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func checkPasteboard() {
        guard let store = historyStore else { return }
        if store.skipNextChangeCountUpdates > 0 {
            store.skipNextChangeCountUpdates -= 1
            lastChangeCount = NSPasteboard.general.changeCount
            return
        }
        let pasteboard = NSPasteboard.general
        let current = pasteboard.changeCount
        guard current != lastChangeCount else { return }
        lastChangeCount = current
        if let string = pasteboard.string(forType: .string), !string.isEmpty {
            store.add(ClipboardItem(content: string))
        }
    }
}
