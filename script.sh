#!/usr/bin/env bash

set -euo pipefail

# =========================
# Metadata
# =========================

VERSION="2.1.0"
AUTHOR="CastielJ"

# =========================
# Colors
# =========================

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
NC="\033[0m"

# =========================
# Arguments
# =========================

AUTO_YES=false
if [[ "${1:-}" == "--yes" ]]; then
    AUTO_YES=true
fi

# =========================
# Root Check
# =========================

check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo -e "${YELLOW}[!] Not running as root${NC}"
        echo -e "${YELLOW}[!] Some installs may fail${NC}"

        if ! $AUTO_YES; then
            read -rp "Continue anyway? [y/N]: " choice
            [[ "$choice" =~ ^[Yy]$ ]] || exit 1
        fi
    fi
}

check_root

# =========================
# Banner
# =========================

echo -e "${CYAN}"
echo "====================================="
echo " Reconnaissance Framework v$VERSION"
echo " Author: $AUTHOR"
echo "====================================="
echo -e "${NC}"

# =========================
# Dependencies
# =========================

TOOLS=(
    subfinder
    assetfinder
    amass
    httpx
    katana
    nuclei
    dnsx
    ffuf
)

GO_TOOLS=(
    subfinder
    assetfinder
    httpx
    katana
    nuclei
    dnsx
)

MISSING_TOOLS=()

check_tool() {
    if ! command -v "$1" >/dev/null 2>&1; then
        MISSING_TOOLS+=("$1")
    fi
}

for tool in "${TOOLS[@]}"; do
    check_tool "$tool"
done

# =========================
# Go Handling
# =========================

needs_go=false
for tool in "${MISSING_TOOLS[@]}"; do
    if [[ " ${GO_TOOLS[*]} " == *" $tool "* ]]; then
        needs_go=true
        break
    fi
done

install_go() {
    echo -e "${BLUE}[*] Installing Go...${NC}"

    if command -v apt >/dev/null 2>&1; then
        apt update
        apt install -y golang
    elif command -v pacman >/dev/null 2>&1; then
        pacman -Sy --noconfirm go
    else
        echo -e "${RED}[!] Unsupported package manager. Install Go manually.${NC}"
        exit 1
    fi
}

export PATH="$PATH:$HOME/go/bin"

install_go_tool() {
    local tool="$1"
    echo -e "${GREEN}[+] Installing/Updating $tool${NC}"

    case "$tool" in
        subfinder) go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest ;;
        assetfinder) go install github.com/tomnomnom/assetfinder@latest ;;
        httpx) go install github.com/projectdiscovery/httpx/cmd/httpx@latest ;;
        katana) go install github.com/projectdiscovery/katana/cmd/katana@latest ;;
        nuclei) go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest ;;
        dnsx) go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest ;;
        *)
            echo -e "${YELLOW}[!] No Go install rule for $tool${NC}"
            ;;
    esac
}

# =========================
# Install / Update Missing Tools
# =========================

if [[ "${#MISSING_TOOLS[@]}" -gt 0 ]]; then
    echo -e "${RED}[!] Missing tools:${NC}"
    printf ' - %s\n' "${MISSING_TOOLS[@]}"
    echo

    if $AUTO_YES; then
        install_choice="y"
    else
        read -rp "Install missing tools now? [y/N]: " install_choice
    fi

    if [[ "$install_choice" =~ ^[Yy]$ ]]; then

        if $needs_go && ! command -v go >/dev/null 2>&1; then
            if $AUTO_YES; then
                go_choice="y"
            else
                read -rp "Go is required. Install Go? [y/N]: " go_choice
            fi

            [[ "$go_choice" =~ ^[Yy]$ ]] && install_go
        fi

        for tool in "${MISSING_TOOLS[@]}"; do
            if [[ " ${GO_TOOLS[*]} " == *" $tool "* ]]; then
                install_go_tool "$tool"
            else
                echo -e "${YELLOW}[!] $tool must be installed manually${NC}"
            fi
        done
    else
        echo -e "${RED}[!] Cannot continue without required tools${NC}"
        exit 1
    fi
fi

# =========================
# Auto Update Existing Go Tools
# =========================

echo -e "${BLUE}[*] Auto-updating installed Go tools...${NC}"
for tool in "${GO_TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        install_go_tool "$tool"
    fi
done

# =========================
# User Input
# =========================

read -rp "Enter target domain (example.com): " TARGET

if [[ -z "$TARGET" ]]; then
    echo -e "${RED}[!] No target provided${NC}"
    exit 1
fi

echo
echo "Choose scan mode:"
echo "1) Basic"
echo "2) Subdomains"
echo "3) Deep (Recommended)"
read -rp "Select option [1-3]: " MODE

# =========================
# Output Structure
# =========================

BASE_DIR="$TARGET"
SUB_DIR="$BASE_DIR/subdomains"
DNS_DIR="$BASE_DIR/dns"
ALIVE_DIR="$BASE_DIR/alive"
FFUF_DIR="$BASE_DIR/ffuf"
KATANA_DIR="$BASE_DIR/katana"
NUCLEI_DIR="$BASE_DIR/nuclei"

mkdir -p "$SUB_DIR" "$DNS_DIR" "$ALIVE_DIR" "$FFUF_DIR" "$KATANA_DIR" "$NUCLEI_DIR"

# =========================
# Functions
# =========================

run_subdomains() {
    echo -e "${BLUE}[*] Enumerating subdomains...${NC}"

    subfinder -d "$TARGET" -silent > "$SUB_DIR/subfinder.txt"
    assetfinder --subs-only "$TARGET" > "$SUB_DIR/assetfinder.txt"
    amass enum -passive -d "$TARGET" > "$SUB_DIR/amass.txt"

    cat "$SUB_DIR"/*.txt | sort -u > "$SUB_DIR/all.txt"
}

run_dns() {
    echo -e "${BLUE}[*] Running DNS resolution (dnsx)...${NC}"

    dnsx -l "$SUB_DIR/all.txt" \
         -a -resp \
         -o "$DNS_DIR/dnsx.txt"
}

run_katana() {
    echo -e "${BLUE}[*] Crawling URLs (katana)...${NC}"
    katana -silent -list "$ALIVE_DIR/alive.txt" > "$KATANA_DIR/urls.txt"
}

run_nuclei() {
    echo -e "${BLUE}[*] Running vulnerability scan (nuclei)...${NC}"
    nuclei -l "$ALIVE_DIR/alive.txt" -o "$NUCLEI_DIR/results.txt"
}

choose_ffuf_rate() {
    echo
    echo -e "${CYAN}Choose ffuf request rate:${NC}"
    echo "1) Stealth (5 req/s)"
    echo "2) Normal (10 req/s) [Recommended]"
    echo "3) Aggressive (30 req/s)"
    echo "4) Custom"
    read -rp "Select option [1-4]: " RATE_CHOICE

    case "$RATE_CHOICE" in
        1) FFUF_RATE=5 ;;
        2) FFUF_RATE=10 ;;
        3) FFUF_RATE=30 ;;
        4)
            read -rp "Enter custom rate (req/s): " FFUF_RATE
            ;;
        *)
            echo -e "${YELLOW}[!] Invalid choice, defaulting to 10${NC}"
            FFUF_RATE=10
            ;;
    esac

    if [[ "$FFUF_RATE" -gt 30 ]]; then
        echo -e "${RED}[!] WARNING: High ffuf rate selected!${NC}"
        echo -e "${RED}[!] Use only with explicit authorization.${NC}"
        sleep 2
    fi
}

run_ffuf() {
    choose_ffuf_rate

    WORDLIST="/usr/share/wordlists/dirb/common.txt"

    echo -e "${BLUE}[*] Running ffuf directory fuzzing...${NC}"
    echo -e "${GREEN}[+] Rate: $FFUF_RATE req/s${NC}"

    ffuf -u "https://$TARGET/FUZZ" \
         -w "$WORDLIST" \
         -rate "$FFUF_RATE" \
         -mc 200,204,301,302,307,401,403 \
         -o "$FFUF_DIR/dirs.json"

    echo -e "${YELLOW}[!] ffuf generates high traffic. Ensure authorization.${NC}"
}

run_alive() {
    echo -e "${BLUE}[*] Checking alive web services (httpx)...${NC}"

    httpx -list "$SUB_DIR/all.txt" \
          -follow-redirects \
          -timeout 5 \
          -retries 2 \
          -threads 50 \
          -title \
          -status-code \
          -tech-detect \
          -o "$ALIVE_DIR/alive.txt"
}

# =========================
# Execution Logic
# =========================

case "$MODE" in
    1)
        run_subdomains
        ;;
    2)
        run_subdomains
        run_alive
        ;;
    3)
        run_subdomains
        run_dns
        run_katana
        run_ffuf
        run_nuclei
        run_alive
        ;;
    *)
        echo -e "${RED}[!] Invalid mode selected${NC}"
        exit 1
        ;;
esac

# =========================
# Done
# =========================

echo
echo -e "${GREEN}[✓] Scan completed successfully${NC}"
echo -e "${GREEN}[✓] Results saved in: $BASE_DIR${NC}"
