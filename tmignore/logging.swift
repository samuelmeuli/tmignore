import Foundation
import HeliumLogger
import Logging

func createLogger() -> Logger {
	// Set up Helium logger
	let heliumLogger = HeliumLogger()
	heliumLogger.colored = true
	heliumLogger.format = "(%msg)"

	// Configure swift-log to use Helium backend
	LoggingSystem.bootstrap(heliumLogger.makeLogHandler)
	return Logger(label: "com.samuelmeuli.tmignore")
}
