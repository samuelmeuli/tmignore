# `tmignore`

Time Machine on macOS is a highly useful tool for creating backups of all your files. Unfortunately for developers, it also backs up your coding project's dependencies, build output and other undesired files, which slows down the backup process and takes up storage.

**This script excludes files and directories matched by `.gitignore` files from future Time Machine backups.**

## Installation

**Requirements:** Homebrew and Xcode

1. Build and install the script using Homebrew: `brew install samuelmeuli/tap/tmignore`
2. Schedule the script to run once a day: `brew services start tmignore`

## Configuration

If there are certain files ignored by Git which you _do_ want to back up (e.g. configuration or password files), you can create a `config.json` file in a `~/.config/time-machine-ignore/` folder and add these files to the whitelist:

```json
{
  "whitelist": ["*/application.yml", "*/*config*.json", "*/.env.*"]
}
```

You can also prevent `tmignore` from scanning certain folders for Git repositories:

```json
{
  "ignoredPaths": ["~/Documents/"]
}
```

## Development

1. Clone this repository: `git clone REPO_URL`
2. Navigate into the project directory: `cd tmignore`
3. Compile the Swift script: `make build`
4. Run the script: `./dist/tmignore`. You can inspect the logs using the Console app

Suggestions and contributions are always welcome! Please discuss larger changes via issue before submitting a pull request.
