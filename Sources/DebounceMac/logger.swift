import Foundation
import SwiftyBeaver


func setupLogger() -> SwiftyBeaver.Type {
    let logger = SwiftyBeaver.self

    let consoleDestination: ConsoleDestination = {
        let console = ConsoleDestination()
        console.format = "$Dyyyy-MM-dd HH:mm:ss$d $C$L$c: $M"  // 2019-08-04 19:42:51 INFO: Initializing an event tap.
        console.useTerminalColors = true  // supress heart mark
        console.minLevel = .debug  // default: .verbose
        return console
    }()
    let fileDestination: FileDestination = {
        let file = FileDestination()
        file.logFileURL = URL(fileURLWithPath: "\(NSHomeDirectory())/Library/Caches/debounce_mac.log")  // default: ~/Library/Caches/swiftybeaver.log
        file.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"  // 2019-08-04 19:42:51.612 INFO main.tapEvents():54 - Initializing an event tap.
        file.colored = true
        file.minLevel = .info  // default: .verbose
        return file
    }()

    logger.addDestination(consoleDestination)
    logger.addDestination(fileDestination)

    return logger
}
