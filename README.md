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

## 🪟 Windows Guide

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
