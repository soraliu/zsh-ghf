# zsh-ghf

Manage knowledge fragments by github issues

# Requirements

- curl
- [jq](https://stedolan.github.io/jq/download)
- [translate-shell](https://github.com/soimort/translate-shell#installation) (optional)

In osx, you can exec the following codes

```bash
brew install jq
brew install translate-shell
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
export ZSH_GHF_API_URL=https://${user}:${token}@api.github.com/repos/soraliu
export ZSH_GHF_REPO_NAME_FRAGMENT=dev-infra
export ZSH_GHF_REPO_NAME_LANG_LEARNING=trans
```

# Usage

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

# License

MIT
