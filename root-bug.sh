#!/bin/bash

# MR00T BUG HUNTER SUITE
# Ultimate Web Reconnaissance Framework
# Version: 2.0
# Author: mr00t
# Tested on: Kali Linux 2023.2

# ===== [ CONFIGURATION ] =====
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

TARGET=""
OUTPUT_DIR="$HOME/bugbounty_results"
TOOLS_DIR="$HOME/tools"
SESSION_FILE="$OUTPUT_DIR/session.mr00t"

# ===== [ INITIALIZATION ] =====
init() {
    clear
    show_banner
    check_dependencies
    create_dirs
    load_session
}

show_banner() {
    echo -e "${RED}"
    cat << "EOF"
 ███╗   ███╗██████╗ ██████╗ ██████╗ ████████╗
 ████╗ ████║██╔══██╗╚════██╗██╔══██╗╚══██╔══╝
 ██╔████╔██║██████╔╝ █████╔╝██████╔╝   ██║   
 ██║╚██╔╝██║██╔══██╗ ╚═══██╗██╔══██╗   ██║   
 ██║ ╚═╝ ██║██║  ██║██████╔╝██║  ██║   ██║   
 ╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝   ╚═╝   
EOF
    echo -e "${NC}"
    echo -e "${BLUE}:: Ultimate Web Reconnaissance Framework ::${NC}"
    echo -e "${YELLOW}Version 2.0 | Codename: NIGHTMARE${NC}"
    echo -e "${RED}WARNING: For authorized penetration testing only!${NC}"
    echo -e "${PURPLE}---------------------------------------------${NC}"
}

check_dependencies() {
    local missing=0
    declare -A tools=(
        ["subfinder"]="go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
        ["httpx"]="go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest"
        ["nuclei"]="go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest"
        ["waybackurls"]="go install -v github.com/tomnomnom/waybackurls@latest"
        ["gau"]="go install -v github.com/lc/gau/v2/cmd/gau@latest"
        ["gf"]="go install -v github.com/tomnomnom/gf@latest"
        ["qsreplace"]="go install -v github.com/tomnomnom/qsreplace@latest"
        ["dnsx"]="go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
        ["naabu"]="go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
    )

    echo -e "\n${CYAN}[*] Checking dependencies...${NC}"
    
    for tool in "${!tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            echo -e "${RED}[X] $tool not found${NC}"
            missing=1
        else
            echo -e "${GREEN}[✓] $tool installed${NC}"
        fi
    done

    if [[ $missing -eq 1 ]]; then
        echo -e "\n${YELLOW}[!] Some tools are missing. Would you like to install them? (y/n)${NC}"
        read -r answer
        if [[ "$answer" == "y" ]]; then
            install_dependencies
        else
            echo -e "${RED}[!] Cannot proceed without required tools. Exiting...${NC}"
            exit 1
        fi
    fi
}

install_dependencies() {
    echo -e "\n${BLUE}[*] Installing missing tools...${NC}"
    for tool in "${!tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            echo -e "${YELLOW}[*] Installing $tool...${NC}"
            eval "${tools[$tool]}"
            if [[ $? -ne 0 ]]; then
                echo -e "${RED}[!] Failed to install $tool${NC}"
                exit 1
            fi
        fi
    done
    echo -e "${GREEN}[+] All tools installed successfully!${NC}"
}

create_dirs() {
    mkdir -p "$OUTPUT_DIR" "$TOOLS_DIR"
}

load_session() {
    if [[ -f "$SESSION_FILE" ]]; then
        echo -e "\n${GREEN}[*] Loading previous session...${NC}"
        source "$SESSION_FILE"
    fi
}

# ===== [ MAIN MENU ] =====
main_menu() {
    echo -e "\n${CYAN}====[ MAIN MENU ]====${NC}"
    echo -e "1. ${GREEN}Target Setup${NC}"
    echo -e "2. ${RED}Reconnaissance${NC}"
    echo -e "3. ${YELLOW}Vulnerability Scanning${NC}"
    echo -e "4. ${BLUE}Report Generation${NC}"
    echo -e "5. ${PURPLE}System Configuration${NC}"
    echo -e "0. ${RED}Exit${NC}"
    
    read -rp "${YELLOW}mr00t>${NC} " choice
    
    case $choice in
        1) target_menu ;;
        2) recon_menu ;;
        3) vuln_menu ;;
        4) report_menu ;;
        5) config_menu ;;
        0) exit 0 ;;
        *) echo -e "${RED}[!] Invalid option!${NC}"; main_menu ;;
    esac
}

# ===== [ TARGET MENU ] =====
target_menu() {
    echo -e "\n${CYAN}====[ TARGET SETUP ]====${NC}"
    echo -e "1. ${GREEN}Set Single Target${NC}"
    echo -e "2. ${YELLOW}Load Target List${NC}"
    echo -e "3. ${BLUE}View Current Target${NC}"
    echo -e "0. ${RED}Back to Main Menu${NC}"
    
    read -rp "${YELLOW}mr00t/target>${NC} " choice
    
    case $choice in
        1)
            read -rp "${YELLOW}Enter target domain: ${NC}" TARGET
            OUTPUT_DIR="$HOME/bugbounty_results/$TARGET"
            mkdir -p "$OUTPUT_DIR"
            echo "TARGET=\"$TARGET\"" > "$SESSION_FILE"
            echo "OUTPUT_DIR=\"$OUTPUT_DIR\"" >> "$SESSION_FILE"
            echo -e "${GREEN}[+] Target set to: $TARGET${NC}"
            ;;
        2)
            read -rp "${YELLOW}Enter path to target list: ${NC}" target_list
            if [[ -f "$target_list" ]]; then
                echo "TARGET_LIST=\"$target_list\"" > "$SESSION_FILE"
                echo -e "${GREEN}[+] Target list loaded: $target_list${NC}"
            else
                echo -e "${RED}[!] File not found!${NC}"
            fi
            ;;
        3)
            if [[ -n "$TARGET" ]]; then
                echo -e "${GREEN}[*] Current target: $TARGET${NC}"
            else
                echo -e "${YELLOW}[!] No target set${NC}"
            fi
            ;;
        0) main_menu ;;
        *) echo -e "${RED}[!] Invalid option!${NC}"; target_menu ;;
    esac
    target_menu
}

# ===== [ RECON MENU ] =====
recon_menu() {
    echo -e "\n${CYAN}====[ RECONNAISSANCE ]====${NC}"
    echo -e "1. ${GREEN}Passive Subdomain Enumeration${NC}"
    echo -e "2. ${RED}Active Scanning${NC}"
    echo -e "3. ${YELLOW}URL Discovery${NC}"
    echo -e "4. ${BLUE}Parameter Extraction${NC}"
    echo -e "0. ${RED}Back to Main Menu${NC}"
    
    read -rp "${YELLOW}mr00t/recon>${NC} " choice
    
    case $choice in
        1) passive_recon ;;
        2) active_recon ;;
        3) url_discovery ;;
        4) param_extraction ;;
        0) main_menu ;;
        *) echo -e "${RED}[!] Invalid option!${NC}"; recon_menu ;;
    esac
}

passive_recon() {
    if [[ -z "$TARGET" ]]; then
        echo -e "${RED}[!] No target set!${NC}"
        target_menu
        return
    fi

    echo -e "\n${PURPLE}[*] Starting passive reconnaissance...${NC}"
    
    echo -e "${BLUE}[*] Running subfinder...${NC}"
    subfinder -d "$TARGET" -silent -o "$OUTPUT_DIR/subdomains.txt"
    
    echo -e "${BLUE}[*] Checking live hosts...${NC}"
    httpx -l "$OUTPUT_DIR/subdomains.txt" -silent -o "$OUTPUT_DIR/live_hosts.txt"
    
    echo -e "${GREEN}[+] Passive recon completed!${NC}"
    echo -e "${YELLOW}[*] Results saved to: $OUTPUT_DIR${NC}"
}

active_recon() {
    if [[ ! -f "$OUTPUT_DIR/live_hosts.txt" ]]; then
        echo -e "${RED}[!] Run passive recon first!${NC}"
        recon_menu
        return
    fi

    echo -e "\n${RED}[!] WARNING: Active scanning may trigger alarms!${NC}"
    read -rp "${YELLOW}Continue? (y/n): ${NC}" confirm
    
    if [[ "$confirm" != "y" ]]; then
        echo -e "${BLUE}[*] Scan canceled${NC}"
        recon_menu
        return
    fi

    echo -e "\n${PURPLE}[*] Starting active scanning...${NC}"
    
    echo -e "${BLUE}[*] Scanning top ports with naabu...${NC}"
    naabu -list "$OUTPUT_DIR/live_hosts.txt" -top-ports 100 -silent -o "$OUTPUT_DIR/port_scan.txt"
    
    echo -e "${BLUE}[*] Fingerprinting services...${NC}"
    httpx -l "$OUTPUT_DIR/live_hosts.txt" -title -tech-detect -status-code -o "$OUTPUT_DIR/service_fingerprint.json"
    
    echo -e "${GREEN}[+] Active scan completed!${NC}"
    echo -e "${YELLOW}[*] Results saved to: $OUTPUT_DIR${NC}"
}

url_discovery() {
    if [[ -z "$TARGET" ]]; then
        echo -e "${RED}[!] No target set!${NC}"
        target_menu
        return
    fi

    echo -e "\n${PURPLE}[*] Discovering URLs...${NC}"
    
    echo -e "${BLUE}[*] Checking Wayback Machine...${NC}"
    waybackurls "$TARGET" > "$OUTPUT_DIR/wayback_urls.txt"
    
    echo -e "${BLUE}[*] Running gau...${NC}"
    gau "$TARGET" > "$OUTPUT_DIR/gau_urls.txt"
    
    echo -e "${GREEN}[+] URL discovery completed!${NC}"
    echo -e "${YELLOW}[*] Results saved to: $OUTPUT_DIR${NC}"
}

param_extraction() {
    if [[ ! -f "$OUTPUT_DIR/wayback_urls.txt" ]] || [[ ! -f "$OUTPUT_DIR/gau_urls.txt" ]]; then
        echo -e "${RED}[!] Run URL discovery first!${NC}"
        recon_menu
        return
    fi

    echo -e "\n${PURPLE}[*] Extracting parameters...${NC}"
    
    cat "$OUTPUT_DIR/wayback_urls.txt" "$OUTPUT_DIR/gau_urls.txt" | sort -u | grep "=" > "$OUTPUT_DIR/all_params.txt"
    
    echo -e "${GREEN}[+] Parameter extraction completed!${NC}"
    echo -e "${YELLOW}[*] Results saved to: $OUTPUT_DIR/all_params.txt${NC}"
}

# ===== [ VULNERABILITY SCANNING ] =====
vuln_menu() {
    echo -e "\n${CYAN}====[ VULNERABILITY SCANNING ]====${NC}"
    echo -e "1. ${RED}XSS Scanning${NC}"
    echo -e "2. ${YELLOW}SQLi Detection${NC}"
    echo -e "3. ${BLUE}Subdomain Takeover Check${NC}"
    echo -e "4. ${GREEN}Full Scan with Nuclei${NC}"
    echo -e "0. ${RED}Back to Main Menu${NC}"
    
    read -rp "${YELLOW}mr00t/vuln>${NC} " choice
    
    case $choice in
        1) xss_scan ;;
        2) sqli_scan ;;
        3) takeover_check ;;
        4) nuclei_scan ;;
        0) main_menu ;;
        *) echo -e "${RED}[!] Invalid option!${NC}"; vuln_menu ;;
    esac
}

xss_scan() {
    if [[ ! -f "$OUTPUT_DIR/all_params.txt" ]]; then
        echo -e "${RED}[!] Run parameter extraction first!${NC}"
        vuln_menu
        return
    fi

    echo -e "\n${PURPLE}[*] Starting XSS scan...${NC}"
    
    cat "$OUTPUT_DIR/all_params.txt" | qsreplace '"><script>alert(1)</script>' | httpx -silent -mr 'alert(1)' -o "$OUTPUT_DIR/xss_results.txt"
    
    echo -e "${GREEN}[+] XSS scan completed!${NC}"
    echo -e "${YELLOW}[*] Results saved to: $OUTPUT_DIR/xss_results.txt${NC}"
}

sqli_scan() {
    if [[ ! -f "$OUTPUT_DIR/all_params.txt" ]]; then
        echo -e "${RED}[!] Run parameter extraction first!${NC}"
        vuln_menu
        return
    fi

    echo -e "\n${PURPLE}[*] Starting SQLi scan...${NC}"
    
    echo -e "${YELLOW}[*] This may take some time...${NC}"
    sqlmap -m "$OUTPUT_DIR/all_params.txt" --batch --level=3 --risk=3 --output-dir="$OUTPUT_DIR/sqlmap_results"
    
    echo -e "${GREEN}[+] SQLi scan completed!${NC}"
    echo -e "${YELLOW}[*] Results saved to: $OUTPUT_DIR/sqlmap_results${NC}"
}

takeover_check() {
    if [[ ! -f "$OUTPUT_DIR/subdomains.txt" ]]; then
        echo -e "${RED}[!] Run passive recon first!${NC}"
        vuln_menu
        return
    fi

    echo -e "\n${PURPLE}[*] Checking for subdomain takeovers...${NC}"
    
    httpx -l "$OUTPUT_DIR/subdomains.txt" -silent -status-code -cname | awk '/404|403/{print $1}' > "$OUTPUT_DIR/takeover_check.txt"
    
    echo -e "${GREEN}[+] Takeover check completed!${NC}"
    echo -e "${YELLOW}[*] Results saved to: $OUTPUT_DIR/takeover_check.txt${NC}"
}

nuclei_scan() {
    if [[ ! -f "$OUTPUT_DIR/live_hosts.txt" ]]; then
        echo -e "${RED}[!] Run passive recon first!${NC}"
        vuln_menu
        return
    fi

    echo -e "\n${PURPLE}[*] Running full scan with Nuclei...${NC}"
    
    nuclei -l "$OUTPUT_DIR/live_hosts.txt" -severity medium,high,critical -o "$OUTPUT_DIR/nuclei_results.txt"
    
    echo -e "${GREEN}[+] Nuclei scan completed!${NC}"
    echo -e "${YELLOW}[*] Results saved to: $OUTPUT_DIR/nuclei_results.txt${NC}"
}

# ===== [ REPORT GENERATION ] =====
report_menu() {
    echo -e "\n${CYAN}====[ REPORT GENERATION ]====${NC}"
    echo -e "1. ${GREEN}Generate HTML Report${NC}"
    echo -e "2. ${BLUE}Generate PDF Report${NC}"
    echo -e "3. ${YELLOW}View Summary${NC}"
    echo -e "0. ${RED}Back to Main Menu${NC}"
    
    read -rp "${YELLOW}mr00t/report>${NC} " choice
    
    case $choice in
        1) generate_html ;;
        2) generate_pdf ;;
        3) view_summary ;;
        0) main_menu ;;
        *) echo -e "${RED}[!] Invalid option!${NC}"; report_menu ;;
    esac
}

generate_html() {
    echo -e "\n${PURPLE}[*] Generating HTML report...${NC}"
    
    echo "<html><head><title>Bug Bounty Report - $TARGET</title></head><body>" > "$OUTPUT_DIR/report.html"
    echo "<h1>Bug Bounty Report</h1>" >> "$OUTPUT_DIR/report.html"
    echo "<h2>Target: $TARGET</h2>" >> "$OUTPUT_DIR/report.html"
    echo "<h3>Date: $(date)</h3>" >> "$OUTPUT_DIR/report.html"
    
    echo "<h2>Findings</h2>" >> "$OUTPUT_DIR/report.html"
    if [[ -f "$OUTPUT_DIR/nuclei_results.txt" ]]; then
        echo "<h3>Nuclei Results</h3><pre>" >> "$OUTPUT_DIR/report.html"
        cat "$OUTPUT_DIR/nuclei_results.txt" >> "$OUTPUT_DIR/report.html"
        echo "</pre>" >> "$OUTPUT_DIR/report.html"
    fi
    
    echo "</body></html>" >> "$OUTPUT_DIR/report.html"
    
    echo -e "${GREEN}[+] HTML report generated!${NC}"
    echo -e "${YELLOW}[*] Report saved to: $OUTPUT_DIR/report.html${NC}"
}

generate_pdf() {
    if ! command -v wkhtmltopdf &>/dev/null; then
        echo -e "${RED}[!] wkhtmltopdf not found! Install with: sudo apt install wkhtmltopdf${NC}"
        return
    fi

    echo -e "\n${PURPLE}[*] Generating PDF report...${NC}"
    
    if [[ ! -f "$OUTPUT_DIR/report.html" ]]; then
        generate_html
    fi
    
    wkhtmltopdf "$OUTPUT_DIR/report.html" "$OUTPUT_DIR/report.pdf" &>/dev/null
    
    echo -e "${GREEN}[+] PDF report generated!${NC}"
    echo -e "${YELLOW}[*] Report saved to: $OUTPUT_DIR/report.pdf${NC}"
}

view_summary() {
    echo -e "\n${CYAN}====[ SCAN SUMMARY ]====${NC}"
    echo -e "${GREEN}Target: ${WHITE}$TARGET${NC}"
    echo -e "${GREEN}Scan Date: ${WHITE}$(date)${NC}"
    
    echo -e "\n${YELLOW}[*] Subdomains Found: ${WHITE}$(wc -l < "$OUTPUT_DIR/subdomains.txt" 2>/dev/null || echo 0)${NC}"
    echo -e "${YELLOW}[*] Live Hosts: ${WHITE}$(wc -l < "$OUTPUT_DIR/live_hosts.txt" 2>/dev/null || echo 0)${NC}"
    echo -e "${YELLOW}[*] Vulnerabilities Found: ${WHITE}$(grep -c "\[" "$OUTPUT_DIR/nuclei_results.txt" 2>/dev/null || echo 0)${NC}"
}

# ===== [ SYSTEM CONFIG ] =====
config_menu() {
    echo -e "\n${CYAN}====[ SYSTEM CONFIGURATION ]====${NC}"
    echo -e "1. ${GREEN}Update Tools${NC}"
    echo -e "2. ${BLUE}Set Output Directory${NC}"
    echo -e "3. ${YELLOW}View Configuration${NC}"
    echo -e "0. ${RED}Back to Main Menu${NC}"
    
    read -rp "${YELLOW}mr00t/config>${NC} " choice
    
    case $choice in
        1) update_tools ;;
        2) set_output_dir ;;
        3) view_config ;;
        0) main_menu ;;
        *) echo -e "${RED}[!] Invalid option!${NC}"; config_menu ;;
    esac
}

update_tools() {
    echo -e "\n${PURPLE}[*] Updating all tools...${NC}"
    
    echo -e "${BLUE}[*] Updating subfinder...${NC}"
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    
    echo -e "${BLUE}[*] Updating nuclei...${NC}"
    go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
    
    echo -e "${GREEN}[+] Tools updated successfully!${NC}"
}

set_output_dir() {
    read -rp "${YELLOW}Enter new output directory: ${NC}" new_dir
    if [[ -n "$new_dir" ]]; then
        OUTPUT_DIR="$new_dir"
        mkdir -p "$OUTPUT_DIR"
        echo "OUTPUT_DIR=\"$OUTPUT_DIR\"" > "$SESSION_FILE"
        echo -e "${GREEN}[+] Output directory set to: $OUTPUT_DIR${NC}"
    else
        echo -e "${RED}[!] Invalid directory!${NC}"
    fi
}

view_config() {
    echo -e "\n${CYAN}====[ CURRENT CONFIG ]====${NC}"
    echo -e "${GREEN}Target: ${WHITE}$TARGET${NC}"
    echo -e "${GREEN}Output Directory: ${WHITE}$OUTPUT_DIR${NC}"
    echo -e "${GREEN}Tools Directory: ${WHITE}$TOOLS_DIR${NC}"
}

# ===== [ MAIN EXECUTION ] =====
init
main_menu
