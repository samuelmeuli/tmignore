import Foundation
import os.log
import SwiftyJSON

enum ConfigError: Error {
	case parseFailed
}

/**
	Responsible for parsing and storing values of the script's configuration file
*/
class Config {
	let configPath = NSString(string: "~/.config/tmignore/config.json").expandingTildeInPath

	// Default values

	// Paths which aren't scanend for Git repositories
	var ignoredPaths = [
		"~/.Trash",
		"~/Applications",
		"~/Library",
		"~/Music/iTunes",
		"~/Pictures/Photos\\ Library.photoslibrary"
	]

	// Files which will be included in backups, even if they are matched by a `.gitignore` file
	var whitelist = [String]()

	/**
		Parses the cache file (if it exists) and saves the contained values into instance variables
		so they can be accessed later on
	*/
	init() throws {
		if let jsonData = NSData(contentsOfFile: configPath) {
			do {
				let json = try JSON(data: jsonData as Data)
				ignoredPaths += json["ignoredPaths"].arrayValue.map { $0.stringValue }
				whitelist = json["whitelist"].arrayValue.map { $0.stringValue }
			} catch {
				os_log("Could not parse config file: %s", type: .error, error.localizedDescription)
				throw ConfigError.parseFailed
			}
		} else {
			os_log("No config file found at %s", configPath)
		}
	}
}
