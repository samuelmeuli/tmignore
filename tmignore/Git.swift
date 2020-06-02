import Foundation
import SwiftExec

/// Class for Git operations
class Git {
	/// Returns the list of ignored files for the specified Git repository (both local and global
	/// `.gitignore` files are considered)
	static func getIgnoredFiles(repoPath: String) -> [String] {
		logger.debug("Obtaining list of ignored files for repo at \(repoPath)…")
		var ignoredFiles = [String]()

		// Let Git list all ignored files/directories
		do {
			let result = try exec(
				program: "/usr/bin/git",
				arguments: [
					"-C", // Directory to run the command in
					repoPath,
					"ls-files",
					"--directory", // Do not list contained files of ignored directories
					"--exclude-standard", // Also use `.git/info/exclude` and global `.gitignore` files
					"--ignored", // List ignored files
					"--others", // Include untracked files
					"-z", // Do not encode "unusual" characters (e.g. "ä" is normally listed as "\303\244")
				]
			)
			// Split lines at NUL bytes (output by Git instead of newline characters because of the "-z"
			// flag)
			let ignoredFilesRel = splitLines(linesStr: result.stdout, lineSeparator: "\0")
			ignoredFiles = ignoredFilesRel.map { "\(repoPath)/\($0)" }
		} catch {
			let error = error as! ExecError
			logger.error(
				"Error obtaining list of ignored files for repository at path \(repoPath): \(error.execResult.stderr ?? "")"
			)
		}

		logger.debug("Found \(ignoredFiles.count) ignored files for repo at \(repoPath)")
		return ignoredFiles
	}

	/// Searches the home directory for Git repositories and returns their paths. Folders specified in
	/// `ignoredPaths` aren't traversed
	static func findRepos(searchPath: String, ignoredPaths: [String]) -> [String] {
		var repoPaths = [String]()
		logger.info("Searching for Git repositories in \(searchPath)…")

		// Start building array of arguments for the `find` command
		var arguments = [searchPath]

		// Tell `find` to skip the ignored paths
		for ignoredPath in ignoredPaths {
			arguments += ["-path", ignoredPath, "-prune", "-o"]
		}

		// Add the remaining `find` arguments
		// "-type d": Only search directories
		// "-name .git": Only search for files/directories named ".git"
		// "-print": Print the results
		arguments += ["-type", "d", "-name", ".git", "-print"]

		// Run the `find` command
		var result: ExecResult
		do {
			result = try exec(program: "/usr/bin/find", arguments: arguments)
		} catch {
			let error = error as! ExecError
			result = error.execResult
			for errLine in splitLines(linesStr: error.execResult.stderr) {
				// Ignore permission errors
				if !errLine.hasSuffix("Operation not permitted") {
					logger.error("Error searching for Git repositories: \(errLine)")
				}
			}
		}

		// Build list of `.git` directories (e.g. ["/path/to/repo/.git"])
		let gitDirs = splitLines(linesStr: result.stdout)

		// Build list of repositories (e.g. ["/path/to/repo"])
		repoPaths = gitDirs.map { String($0.dropLast(5)) }

		logger.info("Found \(repoPaths.count) Git repositories in \(searchPath)")
		return repoPaths
	}
}
