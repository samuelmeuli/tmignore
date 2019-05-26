import os
import pickle
from pathlib import Path
from shutil import rmtree
from subprocess import DEVNULL, CalledProcessError, Popen, call, check_output

BIN_DIR = "/usr/local/bin"
HOME_DIR = str(Path.home())
LAUNCH_AGENTS_DIR = os.path.join(HOME_DIR, "Library", "LaunchAgents")
SCRIPT_NAME = os.path.basename(__file__)
SCRIPT_PATH = os.path.realpath(__file__)
CURRENT_DIR = os.path.dirname(SCRIPT_PATH)

LABEL = "com.samuelmeuli.time-machine-ignore"
PLIST_NAME = LABEL + ".plist"
PLIST_PATH = os.path.join(CURRENT_DIR, PLIST_NAME)

SCRIPT_LINK = os.path.join(BIN_DIR, SCRIPT_NAME)
PLIST_LINK = os.path.join(LAUNCH_AGENTS_DIR, PLIST_NAME)

CACHE_DIR = os.path.join(HOME_DIR, "Library", "Caches", LABEL)
CACHE_PATH = os.path.join(CACHE_DIR, "excluded")

# Paths to exclude from the Git repo search
IGNORED_PATHS = [os.path.join(HOME_DIR, ".Trash"), os.path.join(HOME_DIR, "Library")]


def install():
    # Set up launchd user agent (runs script periodically)
    print("Setting up agent…")
    create_hard_link(SCRIPT_PATH, SCRIPT_LINK)
    create_hard_link(PLIST_PATH, PLIST_LINK)
    call(["launchctl", "load", PLIST_LINK])


def uninstall():
    # Remove created backup exclusions
    paths_cached = read_cache()
    for exclusion_to_remove in paths_cached:
        remove_exclusion(exclusion_to_remove)

    # Remove cache
    print("Removing files…")
    rmtree(CACHE_DIR)

    # Remove launchd user agent
    print("Removing agent…")
    call(["launchctl", "unload", PLIST_LINK])
    delete_hard_link(SCRIPT_LINK)
    delete_hard_link(PLIST_LINK)

    print("Done")


def create_hard_link(src, dest):
    delete_hard_link(dest)
    os.link(src, dest)


def delete_hard_link(path):
    if os.path.isfile(path):
        os.unlink(path)


def add_exclusion(path):
    """Exclude the specified path from future Time Machine backups

    :param path: Path to the file or directory to exclude
    :type path: str
    """
    cmd = ["tmutil", "addexclusion", path]
    Popen(cmd)
    print(f"Added exclusion: {path}")


def remove_exclusion(path):
    """Remove the Time Machine exclusion for the specified path

    :param path: Path to remove the exclusion for
    :type path: str
    """
    cmd = ["tmutil", "removeexclusion", path]
    Popen(cmd)
    print(f"Removed exclusion: {path}")


def find_git_repos():
    """Search the user's files and return a list of all Git repos

    :return: List of Git repos
    :rtype: list<str>
    """
    # Build `find` command which searches for all .git directories and skips the paths which should
    # be ignored (IGNORED_PATHS)
    cmd = ["find", HOME_DIR]
    for path in IGNORED_PATHS:
        cmd += ["-path", path, "-prune", "-o"]
    cmd += ["-type", "d", "-name", ".git", "-print"]

    # Execute `find` command and parse results as list
    try:
        output = check_output(cmd, stderr=DEVNULL)  # Discard permission error output
    except CalledProcessError as e:
        # Ignore permission errors
        output = e.output
    output_str = output.decode("utf-8")
    git_dirs = output_str.split("\n")[:-1]

    # Return list of parent directories (i.e. the Git repos)
    return [os.path.dirname(git_dir) for git_dir in git_dirs]


def read_cache():
    """Return list of paths stored in cache. If no cache file exists, return an empty list

    :return: List of paths which were previously excluded from Time Machine backups
    :rtype: list<str>
    """
    if not os.path.isdir(CACHE_DIR):
        os.mkdir(CACHE_DIR)
    if not os.path.isfile(CACHE_PATH):
        return []
    with open(CACHE_PATH, "rb") as cache:
        return pickle.load(cache)


def write_cache(paths):
    """Write the provided list of paths to the cache file. If none exists, create one

    :param paths: List of paths which were excluded from Time Machine backups during this script run
    :type paths: list<str>
    """
    with open(CACHE_PATH, "wb") as cache:
        pickle.dump(paths, cache)


def get_cache_diff(paths_new, paths_old):
    """Compare the path list created in this script run with the cached one and return the added/
    removed paths

    :param paths_new: Paths to be excluded from backups, identified in this script run
    :type paths_new: list<str>
    :param paths_old: Paths to be excluded from backups, identified in the previous script run
    :type paths_old: list<str>
    :return: Paths which were added compared to the cache, paths which were removed compared to the
        cache
    :rtype: list<str>, list<str>
    """
    set_new = set(paths_new)
    set_old = set(paths_old)
    return set_new - set_old, set_old - set_new


def main():
    # Build list of paths to Git repos
    print("Searching for Git repositories…")
    repo_paths = find_git_repos()
    print(f"Found {len(repo_paths)} Git repositories")

    # Obtain list of ignored files for all Git repos (both local and global .gitignore files are
    # considered)
    paths_to_exclude = []
    for repo_path in repo_paths:
        cmd = ["git", "ls-files", "--directory", "--exclude-standard", "--ignored", "--others"]
        ignored_files_output = check_output(cmd, cwd=repo_path)
        ignored_files = ignored_files_output.decode("utf-8").split("\n")[:-1]
        paths_to_exclude += [
            os.path.join(repo_path, ignored_file) for ignored_file in ignored_files
        ]

    # Compare identified ignore paths with cached ones
    paths_cached = read_cache()
    exclusions_to_add, exclusions_to_remove = get_cache_diff(paths_to_exclude, paths_cached)

    # Add/remove backup exclusions
    print(f"Excluding {len(exclusions_to_add)} files/directories from future backups…")
    for exclusion_to_add in exclusions_to_add:
        add_exclusion(exclusion_to_add)
    print(f"Removing backup exclusions for {len(exclusions_to_remove)} files/directories…")
    for exclusion_to_remove in exclusions_to_remove:
        remove_exclusion(exclusion_to_remove)

    write_cache(paths_to_exclude)
    print("Finished update")


if __name__ == "__main__":
    main()
