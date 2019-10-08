// swift-tools-version:5.1

import PackageDescription

let package = Package(
	name: "tmignore",
	platforms: [
		.macOS(.v10_12)
	],
	dependencies: [
		.package(
			url: "https://github.com/jakeheis/SwiftCLI",
			from: "5.0.0"
		),
		.package(
			url: "https://github.com/apple/swift-log.git",
			from: "1.0.0"
		),
		.package(
			url: "https://github.com/SwiftyJSON/SwiftyJSON.git",
			from: "5.0.0"
		)
	],
	targets: [
		.target(
			name: "tmignore",
			dependencies: [
				"Logging",
				"SwiftCLI",
				"SwiftyJSON"
			]
		)
	]
)
