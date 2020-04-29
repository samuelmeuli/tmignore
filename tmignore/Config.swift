import Foundation
import SwiftyJSON

enum ConfigError: Error {
	case parseFailed
}

/// Responsible for parsing and storing values of the script's configuration file.
class Config {
	let configPath = NSString(string: "~/.config/tmignore/config.json").expandingTildeInPath
	var configJson = JSON()
	let fileManager = FileManager.default

	// Directories which should be scanned for Git repositories.
	let searchPathsKey = "searchPaths"
	let searchPathsDefault = ["~"]
	var searchPaths: [String] {
		let searchPathsStrings = configJson[searchPathsKey] == JSON.null
			? searchPathsDefault
			: configJson[searchPathsKey].arrayValue.map { $0.stringValue }
		return searchPathsStrings.map { NSString(string: $0).expandingTildeInPath }
	}

	// Directories which should be excluded from the Git repository search.
	let ignoredPathsKey = "ignoredPaths"
	let ignoredPathsDefault = [
		"~/.Trash",
		"~/Applications",
		"~/Downloads",
		"~/Library",
		"~/Music/iTunes",
		"~/Music/Music",
		"~/Pictures/Photos\\ Library.photoslibrary",
	]
	var ignoredPaths: [String] {
		let ignoredPathsStrings = configJson[ignoredPathsKey] == JSON.null
			? ignoredPathsDefault
			: configJson[ignoredPathsKey].arrayValue.map { $0.stringValue }
		return ignoredPathsStrings.map { NSString(string: $0).expandingTildeInPath }
	}

	// Files/directories which should be included in backups, even if they are matched by a
	// `.gitignore` file. Useful e.g. for configuration or password files.
	let whitelistKey = "whitelist"
	let whitelistDefault = [String]()
	var whitelist: [String] {
		let whitelistPathsStrings = configJson[whitelistKey] == JSON.null
			? whitelistDefault
			: configJson[whitelistKey].arrayValue.map { $0.stringValue }
		return whitelistPathsStrings.map { NSString(string: $0).expandingTildeInPath }
	}

	/// Parses the cache file (if it exists) and saves its contents.
	init() throws {
		if let jsonData = NSData(contentsOfFile: configPath) {
			do {
				configJson = try JSON(data: jsonData as Data)
			} catch {
				logger.error("Could not parse config file: \(error.localizedDescription)")
				throw ConfigError.parseFailed
			}
		} else {
			logger.debug("No config file found at \(configPath)")
		}
	}
}
