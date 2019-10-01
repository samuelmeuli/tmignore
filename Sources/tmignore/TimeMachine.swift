import Foundation
import os.log

/**
	Class for modifying the list of files/directories which should be excluded from Time Machine
	backups
*/
class TimeMachine {
	/**
		Adds the provided path to the list of exclusions (it will not be included in future backups)
	*/
	static func addExclusion(path: String) {
		let (status, _, stdErr) = runCommand(command: "tmutil addexclusion \(path)")
		if status == 0 {
			os_log("Added Time Machine exclusion: %s", type: .debug, path)
		} else {
			os_log("Failed to add Time Machine exclusion: %s", type: .error, stdErr ?? "")
		}
	}

	/**
		Removes the provided path from the list of exclusions (it will be included again in future
		backups)
	*/
	static func removeExclusion(path: String) {
		let (status, _, stdErr) = runCommand(command: "tmutil removeexclusion \(path)")
		if status == 0 || status == 213 {
			// 213: File path wasn't found and could therefore not be excluded from a Time Machine
			// backup. This error occurs for cached exlusions which were deleted, therefore it is
			// ignored
			os_log("Removed Time Machine exclusion: %s", type: .debug, path)
		} else {
			os_log("Failed to remove Time Machine exclusion: %s", type: .error, stdErr ?? "")
		}
	}
}
