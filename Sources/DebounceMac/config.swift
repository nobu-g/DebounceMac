import AppKit
import OrderedCollections

// Define Codable structs for JSON configuration
struct KeyConfig: Codable {
    let key: String
    let delay: Int
    let condition: [String: Bool]?
}

class Config {
    static let DEFAULT_DEBOUNCE_DELAY = 100
    private static let DEFAULT_CONFIG = [
        KeyConfig(key: "ALL", delay: Config.DEFAULT_DEBOUNCE_DELAY, condition: nil),
    ]

    private var delayDict: [CGKeyCode: OrderedDictionary<[UInt: Bool], Int>] = [:]

    init(fileName: String) {
        let configs = loadConfig(fileName: fileName)

        for item in configs {
            if item.key == "ALL" {
                for keyCode in keyMap.values {
                    setDelayDict(keyCode: keyCode, delay: item.delay, condition: item.condition)
                }
            } else if let keyCode = keyMap[item.key] {
                setDelayDict(keyCode: keyCode, delay: item.delay, condition: item.condition)
            }
        }
        logger.debug(delayDict)
    }

    private func loadConfig(fileName: String) -> [KeyConfig] {
        if let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let saveDir = appSupportDir.appendingPathComponent("DebounceMac", isDirectory: true)
            let cfgFile = saveDir.appendingPathComponent(fileName)

            if !(FileManager.default.fileExists(atPath: cfgFile.path)) {
                if !(FileManager.default.fileExists(atPath: saveDir.path)) {
                    do {
                        try FileManager.default.createDirectory(at: saveDir, withIntermediateDirectories: false, attributes: nil)
                    } catch {
                        logger.error("failed to create save directory: \(saveDir.path)")
                        return Config.DEFAULT_CONFIG
                    }
                    logger.info("created new directory: \(saveDir.path)")
                }

                // Save default config file
                do {
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    let jsonData = try encoder.encode(Config.DEFAULT_CONFIG)
                    try jsonData.write(to: cfgFile)
                } catch {
                    logger.error("failed to save config file: \(cfgFile.path)")
                    return Config.DEFAULT_CONFIG
                }
                logger.info("created new file: \(cfgFile.path)")
            } else {
                logger.info("existing config file found: \(cfgFile.path)")
            }

            // Read and parse config file
            do {
                let jsonData = try Data(contentsOf: cfgFile)
                let decoder = JSONDecoder()
                let configs = try decoder.decode([KeyConfig].self, from: jsonData)
                return configs
            } catch {
                logger.error("failed to parse config file: \(error)")
                return Config.DEFAULT_CONFIG
            }
        }

        return Config.DEFAULT_CONFIG
    }

    private func setDelayDict(keyCode: Int, delay: Int, condition: [String: Bool]?) {
        let cgKeyCode = CGKeyCode(keyCode)
        var conditionDict: [UInt: Bool] = [:]

        if let condition {
            for (modifier, value) in condition {
                if let modifierFlag = modifierMap[modifier] {
                    conditionDict[modifierFlag.rawValue] = value
                } else {
                    logger.warning("modifier key: \(modifier) is not supported")
                }
            }
        }

        if delayDict[cgKeyCode] == nil {
            delayDict[cgKeyCode] = [conditionDict: delay]
        } else {
            delayDict[cgKeyCode]![conditionDict] = delay
        }
    }

    func getDelay(keyCode: CGKeyCode, modifierFlags: NSEvent.ModifierFlags) -> Int? {
        logger.debug("key code: \(keyCode) modifiers: \(modifierMap.filter { modifierFlags.contains($0.value) }.keys)")
        if let conditionalDelay = delayDict[keyCode] {
            logger.debug("condition: \(conditionalDelay)")
            var resultDelay: Int?
            for (condition, delay) in conditionalDelay {
                var flag = true
                for (modifier, state) in condition {
                    if modifierFlags.contains(NSEvent.ModifierFlags(rawValue: modifier)) != state {
                        flag = false
                    }
                }
                if flag {
                    resultDelay = delay
                }
            }

            return resultDelay
        }

        return nil
    }
}
