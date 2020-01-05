// swift-tools-version:5.1

import PackageDescription

let package = Package(
	name: "tmignore",
	platforms: [
		.macOS(.v10_13),
	],
	dependencies: [
		.package(
			url: "https://github.com/IBM-Swift/HeliumLogger",
			from: "1.9.0"
		),
		.package(
			url: "https://github.com/apple/swift-log",
			from: "1.0.0"
		),
		.package(
			url: "https://github.com/jakeheis/SwiftCLI",
			from: "5.0.0"
		),
		.package(
			url: "https://github.com/SwiftyJSON/SwiftyJSON",
			from: "5.0.0"
		),
	],
	targets: [
		.target(
			name: "tmignore",
			dependencies: [
				"HeliumLogger",
				"Logging",
				"SwiftCLI",
				"SwiftyJSON",
			]
		),
	]
)
