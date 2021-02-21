# tmignore

Time Machine on macOS is a highly useful tool for creating backups of all your files. Unfortunately for developers, it also backs up your coding project's dependencies, build output and other undesired files, which slows down the backup process and takes up storage.

**`tmignore` excludes files and directories matched by `.gitignore` files from future Time Machine backups.**

## Install

macOS 10.13+ is required to run `tmignore`.

1. Build and install the script using Homebrew (Xcode is required):

   ```sh
   brew install samuelmeuli/tap/tmignore
   ```

   or

   ```sh
   wget https://github.com/samuelmeuli/tmignore/raw/master/tmignore.rb
   brew install --build-from-source ./tmignore.rb
   ```

2. If you want to run the script once:

   ```sh
   tmignore run
   ```

   To schedule the script to run once a day:

   ```sh
   brew services start tmignore
   ```

Alternatively, if you don't want to build the binary yourself, you can download the compiled program on the [Releases](https://github.com/samuelmeuli/tmignore/releases/latest) page.

## Commands

- **`run`:** Searches the disk for files/directories ignored by Git and excludes them from future Time Machine backups
- **`list`:** Lists all files/directories that have been excluded by `tmignore`
- **`reset`:** Removes all backup exclusions that were made using `tmignore`

## Configuration

You can configure the behavior of `tmignore` by creating a configuration file at `~/.config/tmignore/config.json`:

- **`"searchPaths"`:** Directories which should be scanned for Git repositories. Default: `["~"]` (home directory)

- **`"ignoredPaths"`:** Directories which should be excluded from the Git repository search. Default: `["~/.Trash", "~/Applications", "~/Downloads", "~/Library", "~/Music/iTunes", "~/Music/Music", "~/Pictures/Photos\\ Library.photoslibrary"]`

- **`"whitelist"`:** Files/directories which should be included in backups, even if they are matched by a `.gitignore` file. Useful e.g. for configuration or password files. Default: `[]`

**Configuration example:**

```json
{
	"searchPaths": ["~", "/path/to/another/drive"],
	"whitelist": ["*/application.yml", "*/config.json", "*/.env.*"]
}
```

## Contributing

Suggestions and contributions are always welcome! Please discuss larger changes via issue before submitting a pull request.
