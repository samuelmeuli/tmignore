import Foundation
import Logging
import SwiftCLI

let logger = Logger(label: "com.samuelmeuli.tmignore")

let cli = CLI(
	name: "tmignore",
	version: "0.2.0",
	description: "Exclude development files from Time Machine backups"
)

class RunCommand: Command {
	let name = "run"
	let shortDescription = "Searches the disk for files/directories ignored by Git and excludes " +
		"them from future Time Machine backups"

	func execute() throws {
		let cache = Cache()

		// Parse values specified in `config.json` file
		let config = try Config()

		// Search file system for Git respositories
		let repoPaths = Git.findRepos(ignoredPaths: config.ignoredPaths)

		// Build list of files/directories which should be excluded from Time Machine backups
		logger.info("Applying whitelist…")
		var exclusions = [String]()
		for repoPath in repoPaths {
			for path in Git.getIgnoredFiles(repoPath: repoPath) {
				// Only exclude path from backups if it is not whitelisted
				if config.whitelist.allSatisfy({ !pathMatchesGlob(glob: $0, path: path) }) {
					exclusions.append(path)
				} else {
					logger.debug("Skipping whitelisted file: \(path)")
				}
			}
		}
		logger.info("Identified \(exclusions.count) paths to exclude from backups")

		// Compare generated exclusion list with the one from the previous script run, calculate diff
		let cachedExclusions = cache.read()
		let (
			added: exclusionsToAdd,
			removed: exclusionsToRemove
		) = getDiff(elementsV1: cachedExclusions, elementsV2: exclusions)

		// Add/remove backup exclusions
		logger.info("Excluding \(exclusionsToAdd.count) files/directories from future backups…")
		for exclusionToAdd in exclusionsToAdd {
			TimeMachine.addExclusion(path: exclusionToAdd)
		}
		logger.info("Removing \(exclusionsToRemove.count) backup exclusions…")
		for exclusionToRemove in exclusionsToRemove {
			TimeMachine.removeExclusion(path: exclusionToRemove)
		}

		// Update cache file
		cache.write(paths: exclusions)

		logger.info("Finished update")
	}
}

class ResetCommand: Command {
	let name = "reset"
	let shortDescription = "Removes all created exclusions and clears the cache"

	func execute() {
		// TODO
	}
}

cli.commands = [RunCommand(), ResetCommand()]
cli.goAndExit()
