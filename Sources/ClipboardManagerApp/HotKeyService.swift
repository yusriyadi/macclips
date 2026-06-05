import Carbon.HIToolbox
import Foundation

final class HotKeyService {
    private let onPress: () -> Void
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private let hotKeyID = EventHotKeyID(signature: FourCharCode("CLIP".fourCharCodeValue), id: 1)

    init(onPress: @escaping () -> Void) {
        self.onPress = onPress
    }

    func register() {
        guard hotKeyRef == nil else {
            return
        }

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData in
                guard let userData else {
                    return noErr
                }

                let service = Unmanaged<HotKeyService>.fromOpaque(userData).takeUnretainedValue()
                var resolvedHotKeyID = EventHotKeyID()
                GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &resolvedHotKeyID
                )

                guard resolvedHotKeyID.id == service.hotKeyID.id else {
                    return noErr
                }

                service.onPress()
                return noErr
            },
            1,
            &eventType,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            &eventHandler
        )

        RegisterEventHotKey(
            UInt32(kVK_ANSI_V),
            UInt32(cmdKey | shiftKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }
}

private extension String {
    var fourCharCodeValue: UInt32 {
        utf8.reduce(0) { partialResult, scalar in
            (partialResult << 8) + UInt32(scalar)
        }
    }
}
