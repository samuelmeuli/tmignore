import Darwin
import Foundation

extension Array {
	/// Splits the array into smaller chunks.
	///
	/// Source: https://stackoverflow.com/a/38156873/6767508
	func chunked(by chunkSize: Int) -> [[Element]] {
		stride(from: 0, to: count, by: chunkSize).map {
			Array(self[$0 ..< Swift.min($0 + chunkSize, self.count)])
		}
	}
}

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

/// Breaks up the provided (optional) string at newline characters and returns the lines as an array
/// of strings
func splitLines(linesStr: String?, lineSeparator: Character = "\n") -> [String] {
	if let linesStrNotNil = linesStr {
		return linesStrNotNil.split(separator: lineSeparator).map { String($0) }
	} else {
		return [String]()
	}
}
