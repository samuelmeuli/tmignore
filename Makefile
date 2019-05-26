MODULE_PATH="time_machine_ignore.py"

# Install dependencies and Git hooks
.PHONY: install
install:
	poetry install
	git config core.hooksPath .hooks

# Run the Python script
.PHONY: start
start:
	poetry run python ${MODULE_PATH}

# Format code using Black and isort
.PHONY: format
format:
	poetry run black ${MODULE_PATH} ${BLACK_FLAGS}
	poetry run isort ${MODULE_PATH} --recursive ${ISORT_FLAGS}

# Lint code using flake8
.PHONY: lint
lint:
	poetry run flake8 ${MODULE_PATH} --max-line-length=100
