import AppKit
import SwiftyJSON
import OrderedDictionary


class Config {
    static let DEFAULT_DEBOUNCE_DELAY = 100
    private static let DEFAULT_JSON = JSON([["key": "ALL", "delay": Config.DEFAULT_DEBOUNCE_DELAY]])
    private let json: JSON
    private var delayDict: [CGKeyCode: OrderedDictionary<[UInt: Bool], Int>] = [:]

    init(fileName: String) {
        self.json = {
            if let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                let saveDir = appSupportDir.appendingPathComponent("DebounceMac", isDirectory: true)
                let cfgFile = saveDir.appendingPathComponent(fileName)
                if !(FileManager.default.fileExists(atPath: cfgFile.path)) {
                    if !(FileManager.default.fileExists(atPath: saveDir.path)) {
                        do {
                            try FileManager.default.createDirectory(at: saveDir, withIntermediateDirectories: false, attributes: nil)
                        } catch {
                            logger.error("failed to create save directory: \(saveDir.path)")
                            return Config.DEFAULT_JSON
                        }
                        logger.info("created new directory: \(saveDir.path)")
                    }
                    let jsonString = Config.DEFAULT_JSON.rawString()
                    do {
                        try jsonString!.write(to: cfgFile, atomically: false, encoding: .utf8)  // save default config file
                    } catch {
                        logger.error("failed to save config file: \(cfgFile.path)")
                        return Config.DEFAULT_JSON
                    }
                    logger.info("created new file: \(cfgFile.path)")
                }

                if let jsonString = try? String(contentsOf: cfgFile, encoding: .utf8) {
                    if let data = jsonString.data(using: .utf8) {
                        if let jsonObj = try? JSON(data: data) {
                            return jsonObj
                        } else {
                            logger.error("failed to parse json string")
                            return Config.DEFAULT_JSON
                        }
                    } else {
                        logger.error("failed to encode json string")
                        return Config.DEFAULT_JSON
                    }
                } else {
                    logger.error("cannot open config file: \(cfgFile.path)")
                    return Config.DEFAULT_JSON
                }
            }
            return Config.DEFAULT_JSON
        }()

        guard let items = self.json.array else {
            logger.error("malformed json")
            return
        }
        for item in items {
            guard let key = item["key"].string else {
                logger.error("key must be String")
                return
            }
            guard let delay = item["delay"].int else {
                logger.error("delay must be Integer(ms)")
                return
            }
            if key == "ALL" {
                for keyCode in keyMap.values {
                    self.setDelayDict(keyCode: keyCode, delay: delay, condition: item["condition"])
                }
            } else if let keyCode = keyMap[key] {
                self.setDelayDict(keyCode: keyCode, delay: delay, condition: item["condition"])
            }
        }
    }

    private func setDelayDict(keyCode: Int, delay: Int, condition: JSON) {
        let cgKeyCode = CGKeyCode(keyCode)
        var conditionDict: [UInt: Bool] = [:]
        if let condition = condition.dictionary {
            for (modifier, boolJson): (String, JSON) in condition {
                if let modifierFlag = modifierMap[modifier] {
                    conditionDict[modifierFlag.rawValue] = boolJson.bool!
                } else {
                    logger.warning("modifier key: \(modifier) is not supported")
                }
            }
        }
        if self.delayDict[cgKeyCode] == nil {
            self.delayDict[cgKeyCode] = [conditionDict: delay]
        } else {
            self.delayDict[cgKeyCode]![conditionDict] = delay
        }
    }

    func getDelay(keyCode: CGKeyCode, modifierFlags: NSEvent.ModifierFlags) -> Int? {
        if let conditionalDelay = self.delayDict[keyCode] {
            var resultDelay: Int? = nil
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
