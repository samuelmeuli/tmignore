.PHONY: build
build:
	xcodebuild archive -derivedDataPath $(shell mktemp -d) -scheme tmignore
