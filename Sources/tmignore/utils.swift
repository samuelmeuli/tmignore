import Darwin
import Foundation

/// Calculates the added and removed elements between two versions of a list (V1 and V2)
func findDiff(
	elementsV1: [String],
	elementsV2: [String]
) -> (added: [String], removed: [String]) {
	let setV1 = Set(elementsV1)
	let setV2 = Set(elementsV2)
	return (Array(setV2.subtracting(setV1)), Array(setV1.subtracting(setV2)))
}

/// Determines whether the provided path is matched by the glob using the `fnmatch` C function.
/// Example: `patchMatchesGlob(glob: "*.txt", path: "test.txt")` returns `true`
func pathMatchesGlob(glob: String, path: String) -> Bool {
	fnmatch(glob, path, 0) == 0
}

/// Executes the provided shell command, then parses and returns its status and output
func runCommand(_ command: String) -> (status: Int32, stdout: String?, stderr: String?) {
	let task = Process()
	task.executableURL = URL(fileURLWithPath: "/bin/bash")
	task.arguments = ["-c", command]

	let outPipe = Pipe()
	let errPipe = Pipe()
	task.standardOutput = outPipe
	task.standardError = errPipe

	do {
		try task.run()
	} catch {
		return (status: -1, stdout: nil, stderr: error.localizedDescription)
	}

	// Convert stdout and stderr to strings
	let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
	let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
	let outStr = String(data: outData, encoding: .utf8)
	let errStr = String(data: errData, encoding: .utf8)

	task.waitUntilExit()

	return (status: task.terminationStatus, stdout: outStr, stderr: errStr)
}

/// Breaks up the provided (optional) string at newline characters and returns the lines as an array
/// of strings
func splitLines(linesStr: String?, lineSeparator: Character = "\n") -> [String] {
	if let linesStrNotNil = linesStr {
		return linesStrNotNil.split(separator: lineSeparator).map { String($0) }
	} else {
		return [String]()
	}
}
