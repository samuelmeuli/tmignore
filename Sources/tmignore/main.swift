import Foundation
import SwiftCLI

let logger = createLogger()

let cli = CLI(
	name: "tmignore",
	version: "1.1.1",
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

		// Search file system for Git repositories
		let repoPaths = Git.findRepos(ignoredPaths: config.ignoredPaths)

		// Build list of files/directories which should be excluded from Time Machine backups
		logger.info("Building list of files to exclude from backups…")
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
		TimeMachine.addExclusions(paths: exclusionsToAdd)
		TimeMachine.removeExclusions(paths: exclusionsToRemove)

		// Update cache file
		cache.write(paths: exclusions)

		logger.info("Finished update")
	}
}

class ListCommand: Command {
	let name = "list"
	let shortDescription = "Lists all files/directories that have been excluded by tmignore"

	func execute() {
		let cache = Cache()

		// Parse all previously added exclusions from the cache file and list those exclusions
		let cachedExclusions = cache.read()
		logger.info(
			"\(cachedExclusions.count) files/directories have been excluded from backups by tmignore:\n"
		)
		for path in cachedExclusions {
			logger.info("  - \(path)")
		}
	}
}

class ResetCommand: Command {
	let name = "reset"
	let shortDescription = "Removes all backup exclusions that were made using tmignore"

	func execute() {
		let cache = Cache()

		// Parse all previously added exclusions from the cache file and undo those exclusions
		let cachedExclusions = cache.read()
		TimeMachine.removeExclusions(paths: cachedExclusions)

		// Delete the cache directory
		logger.info("Deleting the cache…")
		cache.clear()

		logger.info("Finished reset")
	}
}

cli.commands = [RunCommand(), ListCommand(), ResetCommand()]
cli.goAndExit()
