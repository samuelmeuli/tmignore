import Foundation
import SwiftExec

/// Class for modifying the list of files/directories which should be excluded from Time Machine
/// backups
class TimeMachine {
	static let chunkSize = 200

	/// Adds the provided path to the list of exclusions (it will not be included in future backups)
	static func addExclusions(paths: [String]) {
		if paths.isEmpty {
			logger.info("No exclusions to add")
			return
		}

		logger.info("Adding backup exclusions for \(paths.count) paths…")

		for pathChunk in paths.chunked(by: chunkSize) {
			do {
				_ = try exec(program: "/usr/bin/tmutil", arguments: ["addexclusion"] + pathChunk)
			} catch {
				let error = error as! ExecError
				logger.error("Failed to add backup exclusions: \(error.execResult.stderr ?? "")")
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

		for pathChunk in paths.chunked(by: chunkSize) {
			do {
				_ = try exec(program: "/usr/bin/tmutil", arguments: ["removeexclusion"] + pathChunk)
			} catch {
				let error = error as! ExecError
				// 213: File path wasn't found and could therefore not be excluded from a Time Machine
				// backup. This error occurs for cached exclusions which were deleted, therefore it is
				// ignored
				if error.execResult.exitCode != 213 {
					logger.error("Failed to remove backup exclusions: \(error.execResult.stderr ?? "")")
				}
			}
		}

		logger.info("Removed backup exclusions for \(paths.count) paths")
	}
}
