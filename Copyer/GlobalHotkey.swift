//
//  GlobalHotkey.swift
//  Copyer
//

import AppKit
import Carbon

final class GlobalHotkey {
    private var hotKeyRef: EventHotKeyRef?
    private let onPress: () -> Void

    init(onPress: @escaping () -> Void) {
        self.onPress = onPress
    }

    func register() {
        let keyCode = UInt32(kVK_ANSI_V)
        let modifiers: UInt32 = UInt32(cmdKey | shiftKey)

        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType("cpyH".fourCharCodeValue)
        hotKeyID.id = 1

        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyReleased)

        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, theEvent, userData) -> OSStatus in
                guard let userData = userData else { return OSStatus(eventNotHandledErr) }
                let hotkey = Unmanaged<GlobalHotkey>.fromOpaque(userData).takeUnretainedValue()
                DispatchQueue.main.async { hotkey.onPress() }
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            nil
        )

        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        assert(status == noErr, "RegisterEventHotKey failed: \(status)")
    }

    func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
    }
}

private extension String {
    var fourCharCodeValue: Int {
        var result: Int = 0
        if let data = self.data(using: .macOSRoman) {
            data.withUnsafeBytes { (rawBytes: UnsafeRawBufferPointer) in
                let bytes = rawBytes.bindMemory(to: UInt8.self)
                for i in 0..<data.count {
                    result = (result << 8) + Int(bytes[i])
                }
            }
        }
        return result
    }
}
