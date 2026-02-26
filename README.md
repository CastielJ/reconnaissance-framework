# OSINT Framework (v.1.0.0)

An automated OSINT (Open Source Intelligence) framework written in Bash.
This script helps gather reconnaissance data on a target domain using
popular security and OSINT tools.

## Features

- Domain & URL input
- Multiple scan modes:
  - Basic
  - Subdomain enumeration
  - Deep reconnaissance
- Organized output per target
- Colored terminal output
- Fully automated workflow

## Tools Used

This script relies on external tools, including:

- subfinder
- assetfinder
- amass
- httpx
- katana
- nuclei

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

## Example

```bash
Write the target Domain or URL: example.com
Choose scan mode:
1) Basic
2) Subdomains
3) Deep
```

## Output Structure

```
example.com/
├── subdomains.txt
├── alive.txt
├── katana.txt
├── nuclei.txt
```

## DISCLAIMER

This tool is for educational and authorized security testing only.

You are responsible for ensuring you have permission to scan the target.
The author is not responsible for misuse.

## License
This project is licensed under the MIT License.

## Author

```
CastielJ
```
