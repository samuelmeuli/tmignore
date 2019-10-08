import Foundation
import SwiftyJSON

/**
	Functions for reading/writing a cache file for paths which were excluded from Time Machine
	backups in previous script runs.

	The cache is a JSON file with the following structure:

	```
	{
		"paths": [
			"/path/to/exclusion1",
			"/path/to/exclusion2"
		]
	}
	```
*/
class Cache {
	// Path to script's cache direcotry (`~/Library/Caches/tmignore`)
	private let cacheDirPath = FileManager.default.urls(
		for: .cachesDirectory,
		in: .userDomainMask
	).first!.path + "/tmignore"

	private lazy var cacheFilePath = cacheDirPath + "/cache.json"

	/**
		Deletes the cache directory
	*/
	func clear() {
		do {
			try FileManager.default.removeItem(atPath: cacheDirPath)
		} catch {
			logger.error("Could not delete cache directory: \(error.localizedDescription)")
		}
	}

	/**
		Parses the cache file (if it exists) and returns the cached exlusion paths
	*/
	func read() -> [String] {
		var paths = [String]()
		if let jsonData = NSData(contentsOfFile: cacheFilePath) {
			do {
				let json = try JSON(data: jsonData as Data)
				paths = json["paths"].arrayValue.map { $0.stringValue }
				logger.debug("Found cache file at \(cacheFilePath)")
			} catch {
				logger.error("Could not parse cache file: \(error.localizedDescription)")
			}
		} else {
			logger.debug("No cache file found at \(cacheFilePath)")
		}
		return paths
	}

	/**
		Writes the specified exclusion paths into the cache file (which is created in case it
		doesn't exist yet)
	*/
	func write(paths: [String]) {
		// Build JSON data which will be written to the cache file
		var jsonData: Data
		do {
			jsonData = try JSON(["paths": paths]).rawData()
		} catch {
			logger.error(
				"Could not convert cache JSON into raw data: \(error.localizedDescription)"
			)
			return
		}

		// Create cache directory if necessary
		do {
			try FileManager.default.createDirectory(
				atPath: cacheDirPath,
				withIntermediateDirectories: true
			)
		} catch {
			logger.error(
				"Could not create cache directory at \(cacheDirPath): \(error.localizedDescription)"
			)
			return
		}

		// Write JSON to file
		do {
			if FileManager.default.fileExists(atPath: cacheFilePath) {
				// Replace content of existing cache file
				logger.debug("Updating cache file at \(cacheFilePath)")
				let cacheFileURL = URL(fileURLWithPath: cacheFilePath)
				try jsonData.write(to: cacheFileURL)
			} else {
				// Create new cache file
				logger.debug("Creating new cache file at \(cacheFilePath)")
				FileManager.default.createFile(atPath: cacheFilePath, contents: jsonData)
			}
		} catch {
			logger.error(
				"Could not save cache file to \(cacheFilePath): \(error.localizedDescription)"
			)
		}
	}
}
