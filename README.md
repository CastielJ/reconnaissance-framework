# OSINT Framework (v.2.1.0)

An automated OSINT (Open Source Intelligence) framework written in Bash.
This script helps gather reconnaissance data on a target domain using
popular security and OSINT tools.

## Features

- Subdomain enumeration
- DNS record enumeration
- Alive host detection
- URL crawling
- Vulnerability scanning
- Directory fuzzing
- Configurable ffuf rate
- Organized output per target
- Colored terminal output
- Single-file Bash framework
- Auto-detects missing tools
- Prompts to install them
- Auto-installs Go if needed
- Go-based tools are updated automatically on each run
- Script warns if not run as root
- Still works without root (with limitations)
- Interactive and non-interactive (`--yes`) execution modes
- Organized output structure per target
- Rate-limited fuzzing with user-selected aggressiveness

## Supported package managers

- apt
- pacman

## Tools Used

This script relies on external tools, including:

- `subfinder`
- `assetfinder`
- `amass`
- `httpx`
- `dnsx`
- `katana`
- `ffuf`
- `nuclei`

⚠️ **You must install these tools separately.**

## Installation

### Requirements
- Bash 4+
- One of the following package managers:
  - `apt` (Debian/Ubuntu/Kali)
  - `pacman` (Arch-based)
- Internet connection

### Clone
```bash
git clone https://github.com/CastielJ/osint-framework.git
cd osint-framework
chmod +x script.sh
```
## You will be prompted to:

1. Enter a target domain or URL
2. Choose a scan mode

Results will be saved in a folder named after the target.

## SCAN MODES
| Mode           | Description                   |
| -------------- | ----------------------------- |
| **Basic**      | Subdomain enumeration only    |
| **Subdomains** | Subdomains + alive host check |
| **Deep**       | Full reconnaissance workflow  |


## Command-Line Options

| Option   | Description |
|--------|-------------|
| `--yes` | Non-interactive mode. Automatically accepts all installation prompts and continues execution. Useful for CI, VPS, and automation. |


## Example

```bash
Write the target Domain or URL: example.com
Choose scan mode:
1) Basic
2) Subdomains
3) Deep
```

## ffuf Rate Selection
The framework allows you to choose how aggressive ffuf should be:
| Mode       | Rate         | Recommendation          |
| ---------- | ------------ | ----------------------- |
| Stealth    | 5 req/s      | Production / bug bounty |
| Normal     | 10 req/s     | Default (recommended)   |
| Aggressive | 30 req/s     | Labs / testing          |
| Custom     | User-defined | ⚠️ Use with caution     |

## Output Structure

```
example.com/
├── subdomains/
│   ├── subfinder.txt
│   ├── assetfinder.txt
│   ├── amass.txt
│   └── all.txt
├── dns/
│   └── dnslister.txt
├── alive/
│   └── alive.txt
├── katana/
│   └── urls.txt
├── ffuf/
│   └── dirs.json
├── nuclei/
│   └── results.txt
```

## DISCLAIMER

This tool is for educational and authorized security testing only.

You are responsible for ensuring you have permission to scan the target.
The author is **not responsible** for misuse.

Future improvements awaiting

## License
This project is licensed under the MIT License.
See the LICENSE file for details.

## Author

```
CastielJ
```
