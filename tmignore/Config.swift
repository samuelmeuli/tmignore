import Foundation
import SwiftyJSON

enum ConfigError: Error {
	case parseFailed
}

/// Responsible for parsing and storing values of the script's configuration file
class Config {
	let configPath = NSString(string: "~/.config/tmignore/config.json").expandingTildeInPath

	// Default values

	// Paths which aren't scanned for Git repositories
	var ignoredPaths = [
		"~/.Trash",
		"~/Applications",
		"~/Downloads",
		"~/Library",
		"~/Music/iTunes",
		"~/Music/Music",
		"~/Pictures/Photos\\ Library.photoslibrary",
	]

	// Files which will be included in backups, even if they are matched by a `.gitignore` file
	var whitelist = [String]()

	/// Parses the cache file (if it exists) and saves the contained values into instance variables
	/// so they can be accessed later on
	init() throws {
		if let jsonData = NSData(contentsOfFile: configPath) {
			do {
				let json = try JSON(data: jsonData as Data)
				logger.debug("Found config file at \(configPath)")
				if json["ignoredPaths"] != JSON.null {
					ignoredPaths = json["ignoredPaths"].arrayValue.map { $0.stringValue }
				}
				if json["whitelist"] != JSON.null {
					whitelist = json["whitelist"].arrayValue.map { $0.stringValue }
				}
			} catch {
				logger.error("Could not parse config file: \(error.localizedDescription)")
				throw ConfigError.parseFailed
			}
		} else {
			logger.debug("No config file found at \(configPath)")
		}
	}
}
