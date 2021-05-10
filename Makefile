.PHONY: build
build:
	swift build -c release

.PHONY: build-in-homebrew
build-in-homebrew:
	swift build -c release --disable-sandbox
