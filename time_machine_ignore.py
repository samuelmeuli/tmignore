import os
from pathlib import Path
from subprocess import DEVNULL, CalledProcessError, Popen, check_output

# Path to user's home directory (only that directory and its subdirectories will be searched)
HOME_DIR = str(Path.home())

# Paths to exclude from the Git repo search
IGNORE_PATHS = [os.path.join(HOME_DIR, ".Trash"), os.path.join(HOME_DIR, "Library")]


def exclude_path_from_backup(path):
    """Exclude the specified path from future Time Machine backups

    :param path: Path to the file or directory to exclude
    :type path: str
    """
    # Check whether file/directory is already excluded
    is_excluded_cmd = ["tmutil", "isexcluded", path]
    is_excluded_output = check_output(is_excluded_cmd)
    if is_excluded_output.decode("utf-8").startswith("[Excluded]"):
        print(f"Already excluded: {path}")
    else:
        # If not: Exclude it from future backups
        exclude_cmd = ["tmutil", "addexclusion", path]
        Popen(exclude_cmd)
        print(f"Excluded path from backup: {path}")


def find_git_repos():
    """Search the user's files and return a list of all Git repos

    :return: List of Git repos
    :rtype: list<str>
    """
    # Build `find` command which searches for all .git directories and skips the paths which should
    # be ignored (IGNORE_PATHS)
    cmd = ["find", HOME_DIR]
    for path in IGNORE_PATHS:
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


def main():
    # Build list of paths to Git repos
    print("Finding Git repositories…")
    repo_paths = find_git_repos()
    print(f"Found {len(repo_paths)} Git repositories")

    for repo_path in repo_paths:
        print(f"\nProcessing repository {repo_path}")

        # Obtain list of ignored files for the current repo (both local and global .gitignore files
        # are considered)
        cmd = ["git", "ls-files", "--directory", "--exclude-standard", "--ignored", "--others"]
        ignored_files_output = check_output(cmd, cwd=repo_path)
        ignored_files = ignored_files_output.decode("utf-8").split("\n")[:-1]

        # Exclude the ignored files from future Time Machine backups
        for ignored_file in ignored_files:
            exclude_path_from_backup(os.path.join(repo_path, ignored_file))


if __name__ == "__main__":
    main()
