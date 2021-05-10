// swift-tools-version:5.3
import PackageDescription


let package = Package(
	name: "clt-logger",
	platforms: [
		.macOS(.v10_13)
	],
	products: [
		.executable(name: "tmignore", targets: ["tmignore"])
	],
	dependencies: [
		.package(                   url: "https://github.com/IBM-Swift/HeliumLogger.git", from: "1.9.0"),
		.package(                   url: "https://github.com/apple/swift-log.git", from: "1.2.0"),
		.package(                   url: "https://github.com/jakeheis/SwiftCLI.git", from: "6.0.1"),
		.package(name: "SwiftExec", url: "https://github.com/samuelmeuli/swift-exec.git", from: "0.1.1"),
		.package(                   url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
	],
	targets: [
		.target(name: "tmignore", dependencies: [
			.product(name: "HeliumLogger", package: "HeliumLogger"),
			.product(name: "Logging",      package: "swift-log"),
			.product(name: "SwiftCLI",     package: "SwiftCLI"),
			.product(name: "SwiftExec",    package: "SwiftExec"),
			.product(name: "SwiftyJSON",   package: "SwiftyJSON"),
		], path: "tmignore"),
	]
)
