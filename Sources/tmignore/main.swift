import Foundation
import os.log

let cache = Cache()

// Parse values specified in `config.json` file
let config = try Config()

// Search file system for Git respositories
let repoPaths = Git.findRepos(ignoredPaths: config.ignoredPaths)

// Build list of files/directories which should be excluded from Time Machine backups
os_log("Applying whitelist…")
var exclusions = [String]()
for repoPath in repoPaths {
	for path in Git.getIgnoredFiles(repoPath: repoPath) {
		// Only exclude path from backups if it is not whitelisted
		if config.whitelist.allSatisfy({ !pathMatchesGlob(glob: $0, path: path) }) {
			exclusions.append(path)
		} else {
			os_log("Skipping whitelisted file: %s", type: .debug, path)
		}
	}
}
os_log("Identified %d paths to exclude from backups", exclusions.count)

// Compare generated exclusion list with the one from the previous script run, calculate diff
let cachedExclusions = cache.read()
let (
	added: exclusionsToAdd,
	removed: exclusionsToRemove
) = getDiff(elementsV1: cachedExclusions, elementsV2: exclusions)

// Add/remove backup exclusions
os_log("Excluding %d files/directories from future backups…", exclusionsToAdd.count)
for exclusionToAdd in exclusionsToAdd {
	TimeMachine.addExclusion(path: exclusionToAdd)
}
os_log("Removing backup exclusions for %d files/directories…", exclusionsToRemove.count)
for exclusionToRemove in exclusionsToRemove {
	TimeMachine.removeExclusion(path: exclusionToRemove)
}

// Update cache file
cache.write(paths: exclusions)

os_log("Finished update")
