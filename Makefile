BUILD_DIR = ./.build/
BUILD_PATH = ./.build/x86_64-apple-macosx/release/tmignore
DIST_DIR = ./dist/

.PHONY: build
build:
	swift build --configuration release --disable-sandbox
	mkdir -p ${DIST_DIR}
	mv ${BUILD_PATH} ${DIST_DIR}

.PHONY: clean
clean:
	rm -rf ${BUILD_DIR} ${DIST_DIR}
