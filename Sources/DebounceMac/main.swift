import AppKit
import Carbon.HIToolbox
import CoreFoundation

import SwiftyBeaver

typealias EventTap = CFMachPort

let SYNTHETIC_KB_ID = 93

let logger = setupLogger()

func tapCallback(proxy _: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    // Do not make the NSEvent here.
    // NSEvent will throw an exception if we try to make an event from the tap timeout type

    if let ptr = refcon {
        let listener = Unmanaged<KeyChanger>.fromOpaque(ptr).takeUnretainedValue()

        if type == CGEventType.tapDisabledByTimeout {
            logger.info("event tap has timed out, re-enabling tap")
            _ = listener.tapEvents()
            return nil
        }
        if type != CGEventType.tapDisabledByUserInput {
            if listener.isBounce(event) {
                return nil
            }
        }
    }

    return Unmanaged.passRetained(event)
}

class KeyChanger {
    private var eventTap: EventTap!
    private var runLoopSource: CFRunLoopSource!
    private var lastKeyTime: Int64
    private var lastKeyCode: CGKeyCode
    private let config: Config

    init(configFile: String) {
        lastKeyTime = -1
        lastKeyCode = 9999
        config = Config(fileName: configFile)
    }

    func tapEvents() -> Bool {
        if eventTap == nil {
            logger.info("Initializing an event tap.")

            let eventMask = CGEventMask(1 << CGEventType.keyDown.rawValue) // receive keyDown event only
            eventTap = CGEvent.tapCreate(
                tap: .cgSessionEventTap,
                place: .tailAppendEventTap,
                options: .defaultTap,
                eventsOfInterest: eventMask,
                callback: tapCallback,
                userInfo: Unmanaged.passRetained(self).toOpaque(), // 参照型をガベージコレクタから外し、ポインタに変換
            )

            if eventTap == nil {
                logger.error("Unable to create event tap.  Must run as root or add privlidges for assistive devices to this app.")
                return false
            }
        }
        CGEvent.tapEnable(tap: eventTap, enable: true)

        return isTapActive()
    }

    func isTapActive() -> Bool {
        CGEvent.tapIsEnabled(tap: eventTap)
    }

    func listen() {
        if runLoopSource == nil {
            if eventTap != nil { // Don't use self.tapActive
                runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
                // Add to the current run loop.
                CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
                logger.info("Registering event tap as run loop source.")
//                CFRunLoopWakeUp(CFRunLoopGetCurrent())
                CFRunLoopRun()
            } else {
                logger.error("No Event tap in place!  You will need to call listen after tapEvents to get events.")
            }
        }
    }

    func isBounce(_ cgEvent: CGEvent) -> Bool {
        if let nsEvent = NSEvent(cgEvent: cgEvent) {
            let currentKeyTime = Int64(Date().timeIntervalSince1970 * 1000)
            let currentKeyCode = nsEvent.keyCode
            let keyboardId = cgEvent.getIntegerValueField(.keyboardEventKeyboardType)

            if keyboardId != SYNTHETIC_KB_ID && currentKeyCode == lastKeyCode && !(nsEvent.isARepeat) {
                if let debounceDelay = config.getDelay(keyCode: currentKeyCode, modifierFlags: nsEvent.modifierFlags) {
                    logger.debug("delay: \(debounceDelay) ? \(currentKeyTime) - \(lastKeyTime)")
                    if (currentKeyTime - lastKeyTime) < debounceDelay {
                        logger.info("BOUNCE detected!!!  Character: '" + (nsEvent.characters ?? "") + "'")
                        logger.info("Time between keys: \(currentKeyTime - lastKeyTime)ms (< \(debounceDelay)ms)")

                        lastKeyTime = currentKeyTime
                        lastKeyCode = currentKeyCode

                        // Cancel keypress event
                        return true
                    }
                } else {
                    logger.warning("failed to get debounce delay")
                }
            }

            lastKeyTime = currentKeyTime
            lastKeyCode = currentKeyCode
        } else {
            logger.error("failed to convert CGEvent to NSEvent")
        }

        return false
    }

    func dealloc() {
        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }
        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false) // Kill the event tap
        }
    }
}

func main() {
    let argv = ProcessInfo.processInfo.arguments
    guard argv.count <= 2 else {
        logger.error("too many arguments")
        return
    }

    let keyChanger = KeyChanger(configFile: argv.count == 1 ? "config.json" : argv[1])
    if !(keyChanger.tapEvents()) {
        logger.info("terminate")
        exit(1)
    }
    keyChanger.listen() // blocking call.
    keyChanger.dealloc()
}

main()
