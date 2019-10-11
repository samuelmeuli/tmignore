# tmignore

Time Machine on macOS is a highly useful tool for creating backups of all your files. Unfortunately for developers, it also backs up your coding project's dependencies, build output and other undesired files, which slows down the backup process and takes up storage.

**`tmignore` excludes files and directories matched by `.gitignore` files from future Time Machine backups.**

## Install

**Requirements:** Homebrew and Xcode

1. Build and install the script using Homebrew:

   ```sh
   brew install samuelmeuli/tap/tmignore
   ```

2. If you want to run the script once:

   ```sh
   tmignore run
   ```

   To schedule the script to run once a day:

   ```sh
   brew services start tmignore
   ```

## Configuration

You can configure the behavior of `tmignore` by creating a configuration file at `~/.config/tmignore/config.json`:

- **`"whitelist"`:** If there are certain files ignored by Git which you _do_ want to back up (e.g. configuration or password files), you can add these files to the whitelist:

  ```js
  {
    // Default: []
    "whitelist": [
      "*/application.yml",
      "*/config.json",
      "*/.env.*"
    ]
  }
  ```

- **`"ignoredPaths"`:** You can also prevent `tmignore` from scanning certain folders for Git repositories:

  ```js
  {
    /*
      Default: [
        "~/.Trash",
        "~/Applications",
        "~/Downloads",
        "~/Library",
        "~/Music/iTunes",
        "~/Music/Music",
        "~/Pictures/Photos\\ Library.photoslibrary"
      ]
    */
    "ignoredPaths": [
      "~/.Trash",
      "~/Documents/"
    ]
  }
  ```

## Uninstall

To remove all backup exclusions that were made using `tmignore`, simply run the following command:

```sh
tmignore reset
```

## Development

1. Clone this repository: `git clone REPO_URL`
2. Navigate into the project directory: `cd tmignore`
3. Compile the Swift script: `make build`
4. Run the script: `./dist/tmignore`

Suggestions and contributions are always welcome! Please discuss larger changes via issue before submitting a pull request.
