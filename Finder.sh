#!/bin/bash

# Clear terminal screen for layout clarity
clear
echo "=========================================================="
echo "       AUTOMATED SUBDOMAIN & DIRECTORY PIPELINE           "
echo "=========================================================="
echo ""

# 1. Capture Target Domain
read -p "[?] Enter Target Domain (e.g., dbs.com): " TARGET_DOMAIN
if [ -z "$TARGET_DOMAIN" ]; then
    echo "[-] Error: Target domain cannot be blank."
    exit 1
fi

# 2. Capture Output File Names
read -p "[?] Enter Subdomain Output Filename (Default: subdomains_found.txt): " SUB_OUT
SUB_OUT=${SUB_OUT:-subdomains_found.txt}

read -p "[?] Enter Directory Output Filename (Default: directories_found.txt): " DIR_OUT
DIR_OUT=${DIR_OUT:-directories_found.txt}

# 3. Capture and Verify DNS Wordlist
DEFAULT_DNS_WL="/usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt"
echo -e "\n[i] Default DNS Wordlist: $DEFAULT_DNS_WL"
read -p "[?] Press ENTER to use default, or provide custom DNS Wordlist path: " USER_DNS_WL

DNS_WORDLIST=${USER_DNS_WL:-$DEFAULT_DNS_WL}

if [ ! -f "$DNS_WORDLIST" ]; then
    echo "[-] Error: DNS Wordlist not found at: $DNS_WORDLIST"
    exit 1
fi

# 4. Capture and Verify Directory Wordlist
DEFAULT_DIR_WL="/usr/share/seclists/Discovery/Web-Content/common.txt"
echo -e "\n[i] Default Directory Wordlist: $DEFAULT_DIR_WL"
read -p "[?] Press ENTER to use default, or provide custom Directory Wordlist path: " USER_DIR_WL

DIR_WORDLIST=${USER_DIR_WL:-$DEFAULT_DIR_WL}

if [ ! -f "$DIR_WORDLIST" ]; then
    echo "[-] Error: Directory Wordlist not found at: $DIR_WORDLIST"
    exit 1
fi

echo ""
echo "=========================================================="
echo "LAUNCHING PHASE 1: Subdomain Discovery"
echo "Target:    $TARGET_DOMAIN"
echo "Wordlist:  $DNS_WORDLIST"
echo "Output:    $SUB_OUT"
echo "=========================================================="

# Run subdomain finder using modern gobuster syntax (Fixing the '-do' syntax error)
gobuster dns -d "$TARGET_DOMAIN" \
             -w "$DNS_WORDLIST" \
             -t 50 \
             -o "$SUB_OUT"

# Check if the subdomain discovery stage actually generated data
if [ ! -s "$SUB_OUT" ]; then
    echo "[-] Error: No subdomains found or file is empty. Pipeline stopping."
    exit 1
fi

echo ""
echo "=========================================================="
echo "LAUNCHING PHASE 2: Directory Enumeration Loop"
echo "Using Wordlist: $DIR_WORDLIST"
echo "Saving Log To:  $DIR_OUT"
echo "=========================================================="

# Loop through each extracted line, stripping hidden formatting or terminal colors cleanly
while read -r line; do
    # Filter wordlists or text outputs, isolating only the first column domain
    subdomain=$(echo "$line" | awk '{print $1}' | tr -d '\r\n\t\033' | sed 's/\[[0-9;]*m//g')
    
    # Skip noisy logs or structural headers produced by Gobuster output files
    if [[ -z "$subdomain" || "$subdomain" == "Found:" || "$subdomain" == "Finished" || "$subdomain" == "Starting" ]]; then
        continue
    fi

    echo "[+] Enumerating Directories: https://$subdomain"
    
    # Perform directory fuzzer on the stripped domain strings
    # -k: skips TLS check to avoid connection drops on self-signed bank certs
    # -q: forces silent output logging only valid findings
    gobuster dir -u "https://$subdomain" \
                 -w "$DIR_WORDLIST" \
                 -t 30 \
                 -q \
                 -k >> "$DIR_OUT" 2>/dev/null

done < "$SUB_OUT"

echo ""
echo "=========================================================="
echo "[+] SUCCESS: Complete infrastructure scanning finished!"
echo "[+] Subdomains saved:  $(pwd)/$SUB_OUT"
echo "[+] Directories saved: $(pwd)/$DIR_OUT"
echo "=========================================================="
