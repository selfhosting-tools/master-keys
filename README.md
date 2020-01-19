# master-keys

[![Project Status: Active  The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

This repository contains GPG keys used to sign projects (git, releases, docker images, etc)

**Keys in this repository must NOT be trusted by default**, but fingerprints should be hard-coded on project basis.

## Clone and verify script

The script helps you to clone a git repository and check GPG signature. You need Docker to use the script.

Download the script:

```sh
curl -O https://raw.githubusercontent.com/selfhosting-tools/master-keys/master/clone_and_verify.sh
```

Set variables at the top of the script according to your needs:

```sh
TRUSTED_GPG_KEYS="CA2B146D7407C0932B96AA8756CD3255CE0673F6"
REPO="nsd-docker"
CLONE_DIRECTORY="$(pwd)/source"
```

`TRUSTED_GPG_KEYS` is a space-separated list of GPG fingerprints to trust  
`REPO` is the repo you want to clone  
`CLONE_DIRECTORY` is the path where to store the cloned repo

Run the script:

```sh
sh clone_and_verify.sh
```

If the script exits with 0, you should now have `$REPO` cloned into `$CLONE_DIRECTORY` making sure the HEAD commit is signed with a trusted key. Otherwise (non-zero exit code) an error has occurred.
