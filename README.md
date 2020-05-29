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
