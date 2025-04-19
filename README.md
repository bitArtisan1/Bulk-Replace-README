<p align="center">
  <a href="https://ko-fi.com/D1D11CZNM1">
    <img src="https://ko-fi.com/img/githubbutton_sm.svg" alt="Support me on Ko-fi" />
  </a>
</p>

<h1 style="font-size:48px;">GIANT TEXT</h1>
# 💠 Bulk Replace GitHub README Badges

This simple script automates updating `README.md` files across all **public GitHub repositories** for a specified user. It replaces **BuyMeACoffee** badges with **Ko‑fi** badges (in my case, you can specify whatever you want to replace) using either the GitHub CLI (`gh`) or GitHub REST API as fallback.

Supports both **Windows** (PowerShell) and **Linux/macOS** (PowerShell or Bash).

---

## 🔄 What It Does

For each repo:

- Clones it locally
- Checks for a `README.md` file
- Replaces:
  - Any `<div align="right">...</div>` with a centered Ko‑fi badge
  - Any existing BuyMeACoffee badge/link with a Ko‑fi alternative
- Commits the change
- Pushes to the `main` branch
- Deletes the local clone

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
```
export GITHUB_TOKEN="<your_personal_access_token>"
```

🚀 **Run the Script:**
```
pwsh ./update_readmes.ps1 \
  -User "bitArtisan1" \
  -KoFiUrl "https://ko-fi.com/D1D11CZNM1" \
  -RepoLimit 100 \
  -GitName "Your Name" \
  -GitEmail "you@example.com"
```
#### Option 2: Bash Script

1. Make sure the following are installed:

```
sudo apt install git curl jq perl
```

2. Use the `update_readmes.sh` script (Bash-compatible version).

3. Run it:
```
chmod +x update_readmes.sh
./update_readmes.sh bitArtisan1 https://ko-fi.com/D1D11CZNM1 100 "Your Name" "you@example.com"
```

## Support Me
If you find this tool useful, consider supporting me by:

- Starring the repository on GitHub
- Sharing the tool with others
- Providing feedback and suggestions
- Follow me for more :)

<a href="https://ko-fi.com/D1D11CZNM1">
  <img src="https://github.com/user-attachments/assets/ba118768-9054-416f-b7b2-adaa69a53434" alt="Support me on Ko-fi" width="200" />
</a>
<center>
    
---
For any issues or feature requests, please open an issue on GitHub. Happy coding!

<div style="text-align: center;">
  <p align="center">
    <img src="https://github.com/user-attachments/assets/36a3e590-bad2-463d-a25e-f56d65c26761" alt="octodance" width="100" height="100" style="margin-right: 10px;"/>
  </p>
</div>
</center>
