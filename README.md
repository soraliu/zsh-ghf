# zsh-ghf

Manage knowledge fragments by github issues

# Prerequisites

- curl
- gdate
- gawk
- pngpaste
- zsh
- [jq](https://stedolan.github.io/jq/download)
- [translate-shell](https://github.com/soimort/translate-shell#installation) (optional)

On OSX, you can exec the following codes

```bash
brew install zsh
brew install jq
brew install translate-shell
brew install pngpaste
brew install gawk
```

Make sure that you have export `/usr/local/bin`

```bash
# ~/.zshrc
export PATH="/usr/local/bin:$PATH"
```

# Installation

```bash
git clone https://github.com/soraliu/zsh-ghf.git $ZSH_CUSTOM/plugins/zsh-ghf
```

```bash
# ~/.zshrc

plugins=(
  # ...
  zsh-ghf
  # ...
)

# ~/.ghfrc
# substitute ${user} ${token} with your own configuration
# make sure the repo is exist
export ZSH_GHF_API_URL=https://${user}:${token}@api.github.com/repos/${user}
export ZSH_GHF_REPO_NAME_FRAGMENT=dev-infra
export ZSH_GHF_REPO_NAME_LANG_LEARNING=trans
```

# Usage

## initialize

```bash
sync_all
```

## push

```bash
push -t shell 'find . -type d -name "${dirname:-dir}"'
```

## dict

```bash
dict -t fruit apple
```

## tozh

```bash
tozh -t 'oral english' -t 'community' "I'v got it."
```

## toen

```bash
toen -t 'tools' "zsh-ghf 这个插件真好用."
```

# The workflow of `Alfred`

Go to [`release`](https://github.com/soraliu/zsh-ghf/releases) page to download workflow


## Usage

The usage of workflow is almost the same as cli, the only difference is that if you omit the comment, the workflow will paste from clipboard

## Commands (push, dict, tozh, toen)

```bash
# notice that `-c` should be the last arg when there is no `-t` arg
push 'find . -type d -name "${dirname:-dir}"' 'find . -type f -name "${filename:-*.ts}"' -c
push -c -t shell 'find . -type d -name "${dirname:-dir}"'
# or you can ignore the comment, and the workflow will paste from clipboard
push -t shell
# or you can pass nothing to it
push

dict -t fruit apple
# or you can ignore the comment, and the workflow will paste from clipboard
dict -t fruit
# or you can pass nothing to it
dict
```

# EBFC

Inspired by the Ebbinghaus forgetting curve.

## Prerequisites

- terminal-notifier

On OSX, you can exec the following codes

```bash
brew install terminal-notifier
```

## Configuration

```bash
# ~/.ghfrc
export ZSH_GHF_PATH_TO_CACHE_ROOT=~/.ghf
export ZSH_GHF_NOTIFICATION_SOUND=submarine
export ZSH_GHF_DAEMON_POLLING_INTERVAL=30
export ZSH_GHF_DAEMON_NOTIFICATION_INTERVAL=30
```

## The workflow of `Alfred`

Go to [`release`](https://github.com/soraliu/zsh-ghf/releases) page to download workflow

### Usage

### Commands (ghf-daemon, ghf-sync)

```bash
# Step 1. Firstly sync issues from github
gsync
# Step 2. Start a daemon
gdaemon # same as `ghf-daemon start`
gdaemon stop
# List all issues
gls
```

# License

MIT
