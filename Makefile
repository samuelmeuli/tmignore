OUTPUT_DIR = ./dist/
SCHEME_NAME = tmignore

.PHONY: build
build:
	xcodebuild archive -derivedDataPath $(shell mktemp -d) -scheme ${SCHEME_NAME}

.PHONY: clean
clean:
	rm -rf ${OUTPUT_DIR}
