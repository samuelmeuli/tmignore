import Darwin
import Foundation

/**
	Calculates the added and removed elements between two versions of a list (V1 and V2)
*/
func getDiff(
	elementsV1: [String],
	elementsV2: [String]
) -> (added: [String], removed: [String]) {
	let setV1 = Set(elementsV1)
	let setV2 = Set(elementsV2)
	return (Array(setV2.subtracting(setV1)), Array(setV1.subtracting(setV2)))
}

/**
	Determines whether the provided path is matched by the glob using the `fnmatch` C function

	Example: `patchMatchesGlob(glob: "*.txt", path: "test.txt")` returns `true`
*/
func pathMatchesGlob(glob: String, path: String) -> Bool {
	return fnmatch(glob, path, 0) == 0
}

/**
	Executes the provided shell command, then parses and returns its status and output
*/
func runCommand(command: String) -> (status: Int32, stdout: String?, stderr: String?) {
	let task = Process()
	task.launchPath = "/bin/bash"
	task.arguments = ["-c", command]

	let stdout = Pipe()
	let stderr = Pipe()
	task.standardOutput = stdout
	task.standardError = stderr

	task.launch()

	// Convert stdout and stderr to strings
	let stdoutData = stdout.fileHandleForReading.readDataToEndOfFile()
	let stderrData = stderr.fileHandleForReading.readDataToEndOfFile()
	let stdoutStr: String = NSString(
		data: stdoutData,
		encoding: String.Encoding.utf8.rawValue
		)! as String
	let stderrStr: String = NSString(
		data: stderrData,
		encoding: String.Encoding.utf8.rawValue
		)! as String

	task.waitUntilExit()

	return (status: task.terminationStatus, stdout: stdoutStr, stderr: stderrStr)
}

/**
	Breaks up the provided (optional) string at newline characters and returns the lines as an array
	of strings
*/
func splitLines(linesStr: String?) -> [String] {
	if let linesStrNotNil = linesStr {
		return linesStrNotNil.split(separator: "\n").map { String($0) }
	} else {
		return [String]()
	}
}
