# nexus-rpm-fetcher

Finds and downloads all rpms from a nexus repository

# Dependencies

- [bash](http://zsh.sourceforge.net/)
- [jq](https://stedolan.github.io/jq/)
- [wget](https://www.gnu.org/software/wget/)
- [curl](https://curl.haxx.se/)

# Usage
```
./fetcher.sh -u <nexus-url> [-e <asset-extension> -p <REST path>]

e.g. ./fetcher.sh -u https://your-nexus-repo.com
```
