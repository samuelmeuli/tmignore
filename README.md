# time-machine-ignore

Time Machine on macOS is a highly useful tool for creating backups of all your files. Unfortunately for developers, it also backs up your coding project's dependencies, build output and other undesired files, which slows down the backup process and takes up storage.

**This is a Python script which excludes files and directories specified in `.gitignore` files from future Time Machine backups.**

## Installation

Make sure you have Python 3.6 or higher installed.

1. Clone this repository: `git clone REPO_URL`
2. Navigate into the project directory: `cd time-machine-ignore`
3. Run the installer script: `python install.py`. This will execute the script for the first time and create an agent which keeps the list of excluded paths up to date (runs once a day).

_If your Python installation is not at `/usr/local/bin/python3`, you'll need to change its path in the in the [plist](com.samuelmeuli.time-machine-ignore.plist) file._

## Configuration

- If there are certain files ignored by Git which you _do_ want to back up (e.g. configuration or password files), you can create a `config.json` file in the project root and add these files to the **whitelist**:

```json
{
  "whitelist": [
    "*/application.yml",
    "*/*config*.json",
    "*/.env.*"
  ]
}
```

- You can change **how often you want the script to run** in the [plist](com.samuelmeuli.time-machine-ignore.plist) file. Simply change the `StartInterval` value to the desired interval (in seconds).

## Uninstall

Run `python uninstall.py` in the project directory. This will reset the changes made to Time Machine's list of exclusions, remove the cache and uninstall the launchd agent.
