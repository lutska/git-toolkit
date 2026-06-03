# git-toolkit
A collection of production-ready Git hooks, automation scripts, and repository quality tools.

The initial implementation focuses on **secret detection using Gitleaks**, while the repository structure is designed to support additional production-grade pre-commit checks in the future.

---

## Current Features

### Secret Detection with [Gitleaks](https://github.com/gitleaks/gitleaks)

The repository provides a Git pre-commit hook that automatically scans staged changes for secrets using Gitleaks before a commit is created.

Examples of detected secrets include:

* Telegram Bot Tokens
* GitHub Personal Access Tokens
* AWS Access Keys
* API Keys
* Database Credentials
* Other secrets supported by Gitleaks

If a secret is detected:

* The commit is blocked
* Details about the finding are displayed
* The developer must remove or remediate the secret before committing

---

## Requirements

* Git
* Bash-compatible shell
* Internet connection (for automatic installation)
* Supported operating systems:

  * Linux
  * macOS
  * Windows (Git Bash)

---

## Repository Structure

```text
git-toolkit/
├── install.sh                      # Main installation script (Installs Gitleaks, configures the pre-commit hook, and supports curl | sh installation).
├── .gitleaks.toml                  # Custom Gitleaks rules extending default detection capabilities.
├── hooks/
│   └── pre-commit                  # Git pre-commit hook executed automatically before every commit.
├── scripts/
│   └── install-gitleaks.sh         # Detects OS/architecture and installs the latest Gitleaks release.
├── examples/
│   └── telegram-token.example      # Example Telegram Bot Token used to verify secret detection.
└── README.md                       # Project documentation and usage instructions.
``` 

The structure is intentionally modular to support future pre-commit hooks and validation tools.

---

## Installation

### One-Line Installation (Recommended)

```bash
curl -sSfL https://raw.githubusercontent.com/lutska/git-toolkit/main/install.sh | bash
```

The installer will:

1. Detect the operating system.
2. Install Gitleaks if it is not already available.
3. Install the Git pre-commit hook.
4. Enable the hook using Git configuration.

---

## Gitleaks Configuration

The repository includes a custom `.gitleaks.toml` configuration file.

The configuration extends the default Gitleaks rule set and adds custom rules for detecting Telegram Bot Tokens.

Default Gitleaks configuration:

https://github.com/gitleaks/gitleaks/blob/master/config/gitleaks.toml

Custom rules are maintained separately to keep the configuration minimal while preserving all built-in Gitleaks detection capabilities.

## Hook Configuration

The hook is enabled automatically during installation and can be controlled using Git configuration:

'''bash
git config hooks.gitleaks false  # disable
git config hooks.gitleaks true   # enable
'''

## How It Works

During every commit:

1. Git executes the `pre-commit` hook.
2. The hook checks whether secret scanning is enabled.
3. Gitleaks scans staged files.
4. If secrets are found:

   * The commit is rejected.
   * Findings are displayed.
5. If no secrets are found:

   * The commit proceeds normally.

---

## Testing

### Example: Telegram Bot Token Detection

Create a file:

```bash
cp examples/telegram-token.example test_commit.py

```

Stage the file:

```bash
git add test_commit.py
```

Attempt to commit:

```bash
git commit -m "[feat] test gitleaks"
```

Expected result:

```text
Running gitleaks secret scan...

[gitleaks] COMMIT REJECTED: secrets detected in staged changes.
[gitleaks] Remove the secret or add '# gitleaks:allow' to suppress false positives.
```


### Example: Commit Allowed

Create a file without secrets:

```bash
echo 'print("Hello, World!")' > test_commit.py
git add test_commit.py
git commit -m "[feat] test gitleaks - without secrets"
```

Expected result:

```text
[gitleaks] No secrets found.
```



### Ignoring False Positives

To suppress a known false positive, add `# gitleaks:allow` to the same line:

```python
TEST_TOKEN = "123456789:AFakeTokenForTestingPurposesOnlyX"  # gitleaks:allow
```

Only use this for test values or non-sensitive data.

---

## Future Roadmap

This repository is intended to become a centralized collection of production-ready Git hooks.

The following hooks are planned for future integration:

### Security

* Gitleaks (implemented)
* TruffleHog
* detect-secrets

### Formatting

* Prettier
* Black
* gofmt
* rustfmt

### Linting

* ESLint
* Ruff
* Pylint
* golangci-lint

### Repository Hygiene

* Trailing whitespace removal
* End-of-file newline validation
* Merge conflict marker detection
* Large file detection

### Testing

* Fast unit test execution
* Changed-file test execution

### Infrastructure Validation

* Terraform fmt
* Terraform validate
* Helm lint
* Kubernetes manifest validation

### Commit Standards

* Conventional Commit validation
* Branch naming validation

---

## Target Production Workflow

```text
Developer
    │
    ▼
Pre-Commit Hooks
    ├── Secret Detection
    ├── Formatting
    ├── Linting
    ├── Repository Hygiene
    └── Fast Tests
    │
    ▼
Git Commit
    │
    ▼
CI/CD Pipeline
    ├── Full Test Suite
    ├── Security Scanning
    ├── Dependency Scanning
    ├── SAST
    ├── Container Scanning
    └── Deployment Validation
```

The goal is to keep pre-commit checks fast while preventing common mistakes from reaching the repository.

---
