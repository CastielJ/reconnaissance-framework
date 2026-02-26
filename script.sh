#!/bin/bash
set -euo pipefail
# Colors (Work on most modern terminals)
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}==========================================${NC}"
echo -e "${GREEN}     OSINT-FRAMEWORK (By CastielJ)       ${NC}"
echo -e "${BLUE}==========================================${NC}"

# 1. The target input
read -p "Write the target Domain or URL: " INPUT_TARGET

# Getting rid of http(s):// and anything else that we don't need
TARGET=$(echo "$INPUT_TARGET" | sed -e 's|^[^/]*//||' -e 's|/.*$||')

if [[ -z "$TARGET" ]]; then
    echo -e "${RED}Error. Write the target Domain or URL${NC}"
    exit 1
fi

echo -e "${YELLOW}[i] Working with the clear domain: $TARGET${NC}"

REPORT_DIR="reports/$TARGET"
mkdir -p "$REPORT_DIR"

# Choose wisely
echo -e "\n1. Fast  2. Deep  3. Maximal scanning"
read -p "Your Choise: " MODE

# --- Base ---
run_basic() {
    echo -e "${BLUE}[*] Collecting DNS and Technologies...${NC}"
    dig "$TARGET" ANY +short > "$REPORT_DIR/dns.txt"
    whatweb "$TARGET" > "$REPORT_DIR/whatweb.txt"
    # Nmap Gets without https://, so it's a clear domain now
    nmap -F "$TARGET" > "$REPORT_DIR/nmap.txt"
}

# --- Subdomains  ---
run_subs() {
    echo -e "${BLUE}[*] Looking for Subdomains...${NC}"
    subfinder -d "$TARGET" > "$REPORT_DIR/all_subs.txt"
    assetfinder --subs-only "$TARGET" >> "$REPORT_DIR/all_subs.txt"
    sort -u "$REPORT_DIR/all_subs.txt" -o "$REPORT_DIR/all_subs.txt"

    echo -e "${BLUE}[*] Looking for alive hosts (Httpx)...${NC}"
    # It can say "no -s", but you don't mind it, it still works (Hope so)
    cat "$REPORT_DIR/all_subs.txt" | httpx -silent -status-code -title -o "$REPORT_DIR/alive.txt"
}

# --- Files ---
run_deep() {
    echo -e "${BLUE}[*] Looking for files in archives (GAU)...${NC}"
    # Warnings are being sent to /dev/null
    gau --subs "$TARGET" 2>/dev/null | grep -E "\.(sql|log|bak|conf|env|zip|tar.gz)" > "$REPORT_DIR/files.txt"

    echo -e "${BLUE}[*] Katana (Crawler)...${NC}"
    katana -u "https://$TARGET" -silent -o "$REPORT_DIR/katana.txt"
    
    echo -e "${BLUE}[*] Nuclei Check...${NC}"
    nuclei -u "https://$TARGET" -severity low,medium,high,critical -silent -o "$REPORT_DIR/nuclei.txt"
}

case $MODE in
    1) run_basic ;;
    2) run_basic; run_subs ;;
    3) run_basic; run_subs; run_deep ;;
esac

echo -e "\n${GREEN}[+] Done! The results are in $REPORT_DIR${NC} folder!"
