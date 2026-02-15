//
//  PasteSimulation.swift
//  Copyer
//

import AppKit
import Carbon

enum PasteSimulation {
    /// Posts Cmd+V so the frontmost app pastes (call after setting NSPasteboard.general).
    static func simulateCmdV() {
        let delay = 50_000_000 // 50ms in nanoseconds
        DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(delay)) {
            let src = CGEventSource(stateID: .hidSystemState)
            let vDown = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: true)
            let vUp = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: false)
            vDown?.flags = .maskCommand
            vUp?.flags = .maskCommand
            vDown?.post(tap: .cghidEventTap)
            vUp?.post(tap: .cghidEventTap)
        }
    }
}
