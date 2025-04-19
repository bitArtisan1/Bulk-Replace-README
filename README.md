# 🔠 Bulk Replace GitHub README Badges

This script automates updating `README.md` files across all **public GitHub repositories** for a specified user. It replaces **BuyMeACoffee** badges with **Ko‑fi** badges using either the GitHub CLI (`gh`) or GitHub REST API as fallback.

Supports both **Windows** (PowerShell) and **Linux/macOS** (PowerShell or Bash).

---

## ✨ Features

- Replaces specific badge HTML blocks using multi-line regex.
- Works across multiple repos in one go.
- Uses `gh` CLI for convenience, or REST API + `git` fallback.
- Automatically configures Git user identity (if needed).
- Fully cross-platform (PowerShell Core or Bash).

---

## ⊞ Windows Guide

### ✅ Requirements

- [PowerShell 7+ (PowerShell Core)](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
- [Git for Windows](https://git-scm.com/)
- Optional: [GitHub CLI (gh)](https://cli.github.com/)
- Write access to target repos

### 🛠️ Installation & Setup

1. **Install PowerShell 7+**

```winget install --id Microsoft.Powershell --source winget```

2. **Install GitHub CLI (gh)**

```winget install --id GitHub.cli --source winget```

3. **Authenticate gh (if installed)**

```gh auth login```

Follow the prompt to authorize via browser.

4. **(If not using `gh`) Set your GitHub Token**

> ⚠️ Required if `gh` is not installed.

#### How to Get a GitHub Token:

- Visit: [https://github.com/settings/tokens](https://github.com/settings/tokens)
- Click **"Generate new token (classic)"**
- Set scopes:
  - ✅ `repo`
- Copy the token and set it:

```$Env:GITHUB_TOKEN = '<your_personal_access_token>'```

5. **Run the Script**
```
pwsh -ExecutionPolicy Bypass -File .\update_readmes.ps1 `
  -User "bitArtisan1" `
  -KoFiUrl "https://ko-fi.com/D1D11CZNM1" `
  -RepoLimit 100 `
  -GitName "Your Name" `
  -GitEmail "you@example.com"
```
---

## 🐧 Linux / macOS Guide

### ✅ Requirements

- PowerShell 7+ (`pwsh`) **or** Bash
- `git`
- Optional: `gh` CLI
- If using Bash version: `jq`, `curl`, `perl`

### 🛠️ Installation

#### Option 1: PowerShell Core

🔧 **Install PowerShell 7+**:

##### Debian/Ubuntu example:
```
$ wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
$ sudo dpkg -i packages-microsoft-prod.deb
$ sudo apt update
$ sudo apt install -y powershell
```
📦 **Install Git** (if not installed):

sudo apt install git

💡 **Optional: Install GitHub CLI (`gh`)**
```
$ type -p curl >/dev/null || sudo apt install curl -y
$ curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg |
$ sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
$ sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

$ echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" |
$ sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

$ sudo apt update
$ sudo apt install gh
```
🔑 **If not using `gh`, get a GitHub Token**

1. Visit: https://github.com/settings/tokens
2. Click **"Generate new token (classic)"**
3. Set scopes:
   - ✅ `repo`
4. Click **Generate token**
5. Copy the token and export it in your shell:

export GITHUB_TOKEN="<your_personal_access_token>"

🚀 **Run the Script:**

pwsh ./update_readmes.ps1 \
  -User "bitArtisan1" \
  -KoFiUrl "https://ko-fi.com/D1D11CZNM1" \
  -RepoLimit 100 \
  -GitName "Your Name" \
  -GitEmail "you@example.com"
