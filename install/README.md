# jq Installer for Maven Flow

Cross-platform installer for `jq` (command-line JSON processor), required for Maven Flow hooks.

## Why jq?

`jq` is a lightweight and flexible command-line JSON processor that Maven Flow uses for robust JSON parsing in hooks. It provides:
- Proper JSON parsing (not just pattern matching)
- Handles nested structures and escaped characters
- Works consistently across different JSON formatting
- Essential for reliable hook behavior

## Quick Start

### Windows (PowerShell)
```powershell
# From Maven Flow directory
.\install\install-jq.ps1

# Or install globally
irm https://raw.githubusercontent.com/your-repo/main/install/install-jq.ps1 | iex
```

### Windows (Git Bash)
```bash
# From Maven Flow directory
./install/install-jq.sh

# Or one-liner
curl -fsSL https://raw.githubusercontent.com/your-repo/main/install/install-jq.sh | bash
```

### macOS / Linux
```bash
# From Maven Flow directory
./install/install-jq.sh

# Or one-liner
curl -fsSL https://raw.githubusercontent.com/your-repo/main/install/install-jq.sh | bash
```

## Installation Methods

The installer tries multiple methods in order of preference:

### Windows
1. **winget** (Windows Package Manager) - Built into Windows 10/11
2. **Chocolatey** - Package manager for Windows
3. **Scoop** - Command-line installer for Windows
4. **Binary download** - Downloads from GitHub releases

### macOS
1. **Homebrew** - `brew install jq`
2. **MacPorts** - `port install jq`
3. **Binary download** - Downloads from GitHub releases

### Linux
1. **apt** (Debian/Ubuntu) - `sudo apt-get install jq`
2. **dnf** (Fedora) - `sudo dnf install jq`
3. **pacman** (Arch) - `sudo pacman -S jq`
4. **zypper** (openSUSE) - `sudo zypper install jq`
5. **Binary download** - Downloads from GitHub releases

## Manual Installation

If the automated installer fails, install `jq` manually:

### Windows
```powershell
winget install jqlang.jq
```

### macOS
```bash
brew install jq
```

### Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install jq
```

## Verify Installation

```bash
jq --version
# Output: jq-1.8.1

echo '{"test": "success"}' | jq -r '.test'
# Output: success
```

## Troubleshooting

### Windows: "jq command not found" after installation
1. Restart your terminal/shell
2. Or add to PATH manually:
   ```powershell
   $env:Path = "C:\Users\YourUsername\bin;" + $env:Path
   ```

### macOS/Linux: Permission denied
```bash
chmod +x install/install-jq.sh
./install/install-jq.sh
```

### Installation fails
1. Check internet connection
2. Try manual installation using package manager
3. Download binary directly from https://jqlang.org/download/

## Version

Current installer targets: **jq 1.8.1**

## More Information

- Official website: https://jqlang.org/
- GitHub: https://github.com/jqlang/jq
- Documentation: https://stedolan.github.io/jq/
- Download: https://jqlang.org/download/
