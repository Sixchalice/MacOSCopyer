//
//  AppDelegate.swift
//  Copyer
//

import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private let historyStore = HistoryStore()
    private let clipboardMonitor = ClipboardMonitor()
    private var globalHotkey: GlobalHotkey?

    /// The app that had focus when we opened the popover; we paste into it after selection.
    private var targetAppForPaste: NSRunningApplication?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        historyStore.onPasteFromHistory = { [weak self] in
            self?.popover?.performClose(nil)
            self?.activateTargetAndPaste()
        }

        clipboardMonitor.start(historyStore: historyStore)

        globalHotkey = GlobalHotkey { [weak self] in
            self?.togglePopover()
        }
        globalHotkey?.register()

        setupStatusItem()
        setupPopover()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem?.button else { return }
        button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard history")
        button.action = #selector(statusItemButtonClicked)
        button.target = self
    }

    private func setupPopover() {
        let contentView = ClipboardHistoryView(
            historyStore: historyStore,
            onSelectItem: { [weak self] item in
                self?.historyStore.writeToPasteboardAndNotifyPaste(item)
            },
            onDismiss: { [weak self] in
                self?.popover?.performClose(nil)
            }
        )
        let hosting = NSHostingController(rootView: contentView)
        popover = NSPopover()
        popover?.contentViewController = hosting
        popover?.behavior = .transient
        popover?.contentSize = NSSize(width: 320, height: 400)
    }

    @objc private func statusItemButtonClicked() {
        togglePopover()
    }

    private func togglePopover() {
        guard let statusItem = statusItem,
              let popover = popover,
              let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            // Remember which app had focus so we can paste back into it (don’t paste into Copyer).
            let frontmost = NSWorkspace.shared.frontmostApplication
            if frontmost?.bundleIdentifier != Bundle.main.bundleIdentifier {
                targetAppForPaste = frontmost
            } else {
                targetAppForPaste = nil
            }
            NSApp.activate()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    private func activateTargetAndPaste() {
        if let target = targetAppForPaste, target.activate(options: []) {
            PasteSimulation.simulateCmdV()
        } else {
            PasteSimulation.simulateCmdV()
        }
        targetAppForPaste = nil
    }
}
