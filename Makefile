.PHONY: build
build:
	swift build -c release --force-resolved-versions

.PHONY: build-in-homebrew
build-in-homebrew:
	swift build -c release --force-resolved-versions --disable-sandbox
