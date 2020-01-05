import Foundation

/// Class for modifying the list of files/directories which should be excluded from Time Machine
/// backups
class TimeMachine {
	/// Takes the (potentially long) list of paths and splits it up into smaller chunks. Each chunk is
	/// converted to a string of the form "'path1' 'path2' 'path3'" so these paths can be passed as
	/// command arguments. The chunking is necessary because a size limit for shell commands exists
	private static func buildArgStrs(paths: [String]) -> [String] {
		let chunkSize = 200
		var idx = 0
		var argList = [String]()

		while idx < paths.count {
			let chunk = paths[idx ..< min(idx + chunkSize, paths.count - 1)]
			argList.append(chunk.map { "'\($0)'" }.joined(separator: " "))
			idx += chunkSize
		}

		return argList
	}

	/// Adds the provided path to the list of exclusions (it will not be included in future backups)
	static func addExclusions(paths: [String]) {
		if paths.isEmpty {
			logger.info("No exclusions to add")
			return
		}

		logger.info("Adding backup exclusions for \(paths.count) paths…")

		for argStr in buildArgStrs(paths: paths) {
			let (status, _, stdErr) = runCommand("tmutil addexclusion \(argStr)")
			if status != 0 {
				logger.error("Failed to add backup exclusions: \(stdErr ?? "")")
			}
		}

		logger.info("Added backup exclusions for \(paths.count) paths")
	}

	/// Removes the provided path from the list of exclusions (it will be included again in future
	/// backups)
	static func removeExclusions(paths: [String]) {
		if paths.isEmpty {
			logger.info("No exclusions to remove")
			return
		}

		logger.info("Removing backup exclusions for \(paths.count) paths…")

		for argStr in buildArgStrs(paths: paths) {
			let (status, _, stdErr) = runCommand("tmutil removeexclusion \(argStr)")
			// 213: File path wasn't found and could therefore not be excluded from a Time Machine backup.
			// This error occurs for cached exclusions which were deleted, therefore it is ignored
			if status != 0, status != 213 {
				logger.error("Failed to remove backup exclusions: \(stdErr ?? "")")
			}
		}

		logger.info("Removed backup exclusions for \(paths.count) paths")
	}
}
