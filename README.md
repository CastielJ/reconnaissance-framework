# OSINT Framework (v.1.1.1)

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

```bash
git clone https://github.com/CastielJ/osint-framework.git
cd osint-framework
chmod +x script.sh
```
## Usage
```bash
./script.sh
```
##You will be prompted to:

1. Enter a target domain or URL
2. Choose a scan mode

Results will be saved in a folder named after the target.

## SCAN MODES
| Mode           | Description                   |
| -------------- | ----------------------------- |
| **Basic**      | Subdomain enumeration only    |
| **Subdomains** | Subdomains + alive host check |
| **Deep**       | Full reconnaissance workflow  |


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

## License
This project is licensed under the MIT License.
See the LICENSE file for details.

## Author

```
CastielJ
```
