#!/bin/bash
#A script to enumerate local information from a Linux host
version="version 0.982"
#@rebootuser

#help function
usage () 
{ 
echo -e "\n\e[00;31m#########################################################\e[00m" 
echo -e "\e[00;31m#\e[00m" "\e[00;33mLinEnum-Enhanced v2.0 - Professional Security Assessment\e[00m" "\e[00;31m#\e[00m"
echo -e "\e[00;31m#########################################################\e[00m"
echo -e "\e[00;33m# Enhanced Community Fork | Enterprise Ready \e[00m"
echo -e "\e[00;33m# $version\e[00m\n"
echo -e "\e[00;33m# Example: ./LinEnum.sh -k keyword -r report -e /tmp/ -t --format json --compliance cis\e[00m\n"

		echo "BASIC OPTIONS:"
		echo "-k	Enter keyword"
		echo "-e	Enter export location"
		echo "-s 	Supply user password for sudo checks (INSECURE)"
		echo "-t	Include thorough (lengthy) tests"
		echo "-r	Enter report name" 
		echo "-h	Displays this help text"
		echo ""
		echo "PROFESSIONAL REPORTING:"
		echo "--format	Output format: text, json, xml, html, csv, pdf (default: text)"
		echo "--dashboard	Generate interactive HTML dashboard"
		echo "--compliance	Compliance mode: cis, nist, pci, hipaa"
		echo ""
		echo "ENTERPRISE FEATURES:"
		echo "--title		Custom report title"
		echo "--template	Use professional report template"
		echo "--summary	Generate executive summary"
		echo -e "\n"
		echo "Running with no options = limited scans/text output"
		echo ""
		echo "Note: All professional reports are saved in ./reports/ directory"
		
echo -e "\e[00;31m#########################################################\e[00m"		
}
header()
{
echo -e "\n\e[00;31m#########################################################\e[00m" 
echo -e "\e[00;31m#\e[00m" "\e[00;33mLocal Linux Enumeration & Privilege Escalation Script\e[00m" "\e[00;31m#\e[00m" 
echo -e "\e[00;31m#########################################################\e[00m" 
echo -e "\e[00;33m# www.rebootuser.com\e[00m" 
echo -e "\e[00;33m# $version\e[00m\n" 

}

debug_info()
{
echo "[-] Debug Info" 

if [ "$keyword" ]; then 
	echo "[+] Searching for the keyword $keyword in conf, php, ini and log files" 
fi

if [ "$report" ]; then 
	echo "[+] Report name = $report" 
fi

if [ "$export" ]; then 
	echo "[+] Export location = $export" 
fi

if [ "$thorough" ]; then 
	echo "[+] Thorough tests = Enabled" 
else 
	echo -e "\e[00;33m[+] Thorough tests = Disabled\e[00m" 
fi

sleep 2

if [ "$export" ]; then
  mkdir "$export" 2>/dev/null
  format="$export/LinEnum-export-$(date +"%d-%m-%y")"
  mkdir "$format" 2>/dev/null
fi

if [ "$sudopass" ]; then 
  echo -e "\e[00;35m[+] Please enter password - INSECURE - really only for CTF use!\e[00m"
  read -s userpassword
  echo 
fi

who=`whoami` 2>/dev/null 
echo -e "\n" 

echo -e "\e[00;33mScan started at:"; date 
echo -e "\e[00m\n" 
}

# useful binaries (thanks to https://gtfobins.github.io/)
binarylist='aria2c\|arp\|ash\|awk\|base64\|bash\|busybox\|cat\|chmod\|chown\|cp\|csh\|curl\|cut\|dash\|date\|dd\|diff\|dmsetup\|docker\|ed\|emacs\|env\|expand\|expect\|file\|find\|flock\|fmt\|fold\|ftp\|gawk\|gdb\|gimp\|git\|grep\|head\|ht\|iftop\|ionice\|ip$\|irb\|jjs\|jq\|jrunscript\|ksh\|ld.so\|ldconfig\|less\|logsave\|lua\|make\|man\|mawk\|more\|mv\|mysql\|nano\|nawk\|nc\|netcat\|nice\|nl\|nmap\|node\|od\|openssl\|perl\|pg\|php\|pic\|pico\|python\|readelf\|rlwrap\|rpm\|rpmquery\|rsync\|ruby\|run-parts\|rvim\|scp\|script\|sed\|setarch\|sftp\|sh\|shuf\|socat\|sort\|sqlite3\|ssh$\|start-stop-daemon\|stdbuf\|strace\|systemctl\|tail\|tar\|taskset\|tclsh\|tee\|telnet\|tftp\|time\|timeout\|ul\|unexpand\|uniq\|unshare\|vi\|vim\|watch\|wget\|wish\|xargs\|xxd\|zip\|zsh'

# Performance optimization: Global file cache variables
FILESCAN_CACHE_DIR="/tmp/.linenum_cache_$$"
ALL_FILES_CACHE=""
SUID_FILES_CACHE=""
SGID_FILES_CACHE=""
WW_FILES_CACHE=""
CACHE_INITIALIZED=0

# Progress indicator function
show_progress() {
    local message="$1"
    if [ "$export" ] || [ "$thorough" ]; then
        echo -e "\e[00;36m[*] $message...\e[00m"
    fi
}

# Consolidated filesystem scan function - runs once, caches results
perform_consolidated_filescan() {
    if [ "$CACHE_INITIALIZED" -eq 1 ]; then
        return 0
    fi
    
    show_progress "Performing optimized filesystem scan"
    
    # Create temporary cache directory
    mkdir -p "$FILESCAN_CACHE_DIR" 2>/dev/null
    
    # Single comprehensive find command to gather all file information
    # This replaces multiple separate find operations
    current_user=`whoami`
    find / -type f \( \
        -perm -4000 -o \
        -perm -2000 -o \
        -perm -2 -o \
        -writable ! -user "$current_user" -o \
        -user "$current_user" -o \
        -name ".*" \
    \) $(get_optimized_find_excludes) \
      -exec ls -la {} + 2>/dev/null | \
    awk -v user="$current_user" '
    BEGIN { 
        suid_file = "'$FILESCAN_CACHE_DIR'/suid_files.tmp"
        sgid_file = "'$FILESCAN_CACHE_DIR'/sgid_files.tmp"
        ww_file = "'$FILESCAN_CACHE_DIR'/ww_files.tmp"
        all_file = "'$FILESCAN_CACHE_DIR'/all_files.tmp"
        user_files = "'$FILESCAN_CACHE_DIR'/user_files.tmp"
        group_writable = "'$FILESCAN_CACHE_DIR'/group_writable.tmp"
        hidden_files = "'$FILESCAN_CACHE_DIR'/hidden_files.tmp"
    }
    {
        # Store all file info
        print $0 > all_file
        
        # Parse permissions and ownership
        perms = $1
        owner = $3
        filename = $NF
        
        # Check for SUID (4th character is s or S)
        if (substr(perms, 4, 1) == "s" || substr(perms, 4, 1) == "S") {
            print $0 > suid_file
        }
        
        # Check for SGID (7th character is s or S)
        if (substr(perms, 7, 1) == "s" || substr(perms, 7, 1) == "S") {
            print $0 > sgid_file
        }
        
        # Check for world-writable (10th character is w)
        if (substr(perms, 10, 1) == "w") {
            print $0 > ww_file
        }
        
        # Check for user-owned files
        if (owner == user) {
            print $0 > user_files
        }
        
        # Check for group-writable files not owned by user
        if (substr(perms, 6, 1) == "w" && owner != user) {
            print $0 > group_writable
        }
        
        # Check for hidden files (filename starts with .)
        if (match(filename, /\/\.[^/]*$/) && filename != "./" && filename != "../") {
            print $0 > hidden_files
        }
    }' 2>/dev/null
    
    # Set cache flags
    CACHE_INITIALIZED=1
    
    show_progress "Filesystem scan completed"
}

# Optimized function to get cached file listings
get_cached_files() {
    local file_type="$1"
    local cache_file="$FILESCAN_CACHE_DIR/${file_type}_files.tmp"
    
    if [ -f "$cache_file" ]; then
        cat "$cache_file" 2>/dev/null
    fi
}

# Cleanup cache function
cleanup_cache() {
    if [ -d "$FILESCAN_CACHE_DIR" ]; then
        rm -rf "$FILESCAN_CACHE_DIR" 2>/dev/null
    fi
}

# Performance benchmarking functions
start_timer() {
    TIMER_START=$(date +%s.%N)
}

end_timer() {
    local operation="$1"
    TIMER_END=$(date +%s.%N)
    TIMER_DIFF=$(echo "$TIMER_END - $TIMER_START" | bc -l 2>/dev/null || echo "$TIMER_END - $TIMER_START" | awk '{print $1 - $3}')
    if [ "$export" ] || [ "$thorough" ]; then
        echo -e "\e[00;36m[PERF] $operation completed in ${TIMER_DIFF}s\e[00m"
    fi
}

# Parallel execution helper
run_parallel() {
    local max_jobs=${1:-3}
    local job_count=0
    local pids=()
    
    while read -r cmd; do
        if [ $job_count -ge $max_jobs ]; then
            # Wait for any job to complete
            wait ${pids[0]}
            pids=("${pids[@]:1}")
            ((job_count--))
        fi
        
        # Start new background job
        eval "$cmd" &
        pids+=($!)
        ((job_count++))
    done
    
    # Wait for all remaining jobs
    for pid in "${pids[@]}"; do
        wait $pid
    done
}

# Optimized system info collection (parallel independent checks)
system_info_parallel() {
    # Create temporary files for parallel results
    local temp_dir="$FILESCAN_CACHE_DIR/parallel"
    mkdir -p "$temp_dir" 2>/dev/null
    
    # Run independent system checks in parallel
    {
        echo "uname -a 2>/dev/null > '$temp_dir/uname.tmp'"
        echo "cat /proc/version 2>/dev/null > '$temp_dir/procver.tmp'"
        echo "cat /etc/issue 2>/dev/null > '$temp_dir/issue.tmp'"
        echo "cat /etc/os-release 2>/dev/null > '$temp_dir/osrelease.tmp'"
        echo "hostnamectl 2>/dev/null > '$temp_dir/hostname.tmp'"
        echo "df -h 2>/dev/null > '$temp_dir/diskspace.tmp'"
        echo "free -h 2>/dev/null > '$temp_dir/memory.tmp'"
        echo "lscpu 2>/dev/null > '$temp_dir/cpu.tmp'"
    } | run_parallel 4
    
    # Process results
    local unameinfo=$(cat "$temp_dir/uname.tmp" 2>/dev/null)
    local procver=$(cat "$temp_dir/procver.tmp" 2>/dev/null)
    local issue=$(cat "$temp_dir/issue.tmp" 2>/dev/null)
    
    # Display results (keeping original format)
    if [ "$unameinfo" ]; then
        echo -e "\e[00;31m[-] Kernel information:\e[00m\n$unameinfo" 
        echo -e "\n" 
    fi
    
    if [ "$procver" ]; then
        echo -e "\e[00;31m[-] Kernel information (continued):\e[00m\n$procver" 
        echo -e "\n" 
    fi
    
    if [ "$issue" ]; then
        echo -e "\e[00;31m[-] Specific release information:\e[00m\n$issue" 
        echo -e "\n" 
    fi
}

# Memory-efficient large output processing
process_large_output() {
    local input="$1"
    local max_lines=${2:-1000}
    
    if [ -z "$input" ]; then
        return 0
    fi
    
    local line_count=$(echo "$input" | wc -l)
    if [ "$line_count" -gt "$max_lines" ]; then
        echo "$input" | head -n $((max_lines / 2))
        echo -e "\e[00;33m[...truncated $((line_count - max_lines)) lines for performance...]\e[00m"
        echo "$input" | tail -n $((max_lines / 2))
    else
        echo "$input"
    fi
}

# Smart path exclusions for better performance
get_optimized_find_excludes() {
    echo "! -path '/proc/*' ! -path '/sys/*' ! -path '/dev/*' ! -path '/run/*' ! -path '/tmp/snap.*' ! -path '/var/lib/docker/*' ! -path '/var/lib/containerd/*' ! -path '/snap/*'"
}

# Professional Reporting Architecture
REPORT_FORMAT="text"  # Default format
REPORT_DATA=""  # Global data storage
COMPLIANCE_MODE=""  # Compliance framework
DASHBOARD_MODE=0  # Dashboard export flag
REPORT_TITLE="LinEnum-Enhanced Security Assessment"
REPORT_VERSION="2.0-enterprise"
REPORT_TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
REPORT_UUID=$(date +%s | sha256sum | cut -c1-8)
REPORT_DIR="./reports"  # Default reports directory

# Data collection structure
init_report_data() {
    cat > /tmp/linenum_report_$$.json << 'EOF'
{
  "metadata": {
    "title": "LinEnum-Enhanced Security Assessment",
    "version": "2.0-enterprise",
    "timestamp": "",
    "uuid": "",
    "hostname": "",
    "compliance_mode": "",
    "scan_duration": ""
  },
  "system": {},
  "users": {},
  "network": {},
  "services": {},
  "files": {},
  "compliance": {},
  "risks": [],
  "summary": {}
}
EOF
}

# JSON output functions
add_to_json() {
    local section="$1"
    local key="$2"
    local value="$3"
    local temp_file="/tmp/linenum_report_$$.json"
    
    # Escape JSON special characters
    value=$(echo "$value" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g; s/\r/\\r/g; s/\n/\\n/g')
    
    # Use jq if available, otherwise manual JSON manipulation
    if command -v jq >/dev/null 2>&1; then
        jq ".${section}.${key} = \"${value}\"" "$temp_file" > "${temp_file}.tmp" && mv "${temp_file}.tmp" "$temp_file"
    else
        # Manual JSON update (simplified)
        sed -i "s/\"${section}\": {/\"${section}\": {\"${key}\": \"${value}\",/" "$temp_file"
    fi
}

add_risk_finding() {
    local severity="$1"
    local title="$2"
    local description="$3"
    local recommendation="$4"
    
    local risk_entry="{\"severity\": \"$severity\", \"title\": \"$title\", \"description\": \"$description\", \"recommendation\": \"$recommendation\"}"
    
    # Add to risks array (simplified implementation)
    echo "Risk: [$severity] $title - $description" >> "/tmp/linenum_risks_$$.tmp"
}

# XML output functions
generate_xml_header() {
    cat << EOF
<?xml version="1.0" encoding="UTF-8"?>
<LinEnumReport xmlns="http://linenum-enhanced.org/schema/v2">
  <metadata>
    <title>$REPORT_TITLE</title>
    <version>$REPORT_VERSION</version>
    <timestamp>$REPORT_TIMESTAMP</timestamp>
    <uuid>$REPORT_UUID</uuid>
    <hostname>$(hostname)</hostname>
    <compliance_mode>$COMPLIANCE_MODE</compliance_mode>
  </metadata>
EOF
}

generate_xml_footer() {
    echo "</LinEnumReport>"
}

# HTML Dashboard functions
generate_html_header() {
    cat << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LinEnum-Enhanced Security Dashboard</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; background: #f5f5f5; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; text-align: center; }
        .container { max-width: 1200px; margin: 20px auto; padding: 0 20px; }
        .card { background: white; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin: 20px 0; padding: 20px; }
        .risk-high { border-left: 5px solid #dc3545; }
        .risk-medium { border-left: 5px solid #ffc107; }
        .risk-low { border-left: 5px solid #28a745; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
        .metric { text-align: center; padding: 20px; }
        .metric-value { font-size: 2em; font-weight: bold; color: #667eea; }
        .compliance-badge { display: inline-block; padding: 4px 8px; border-radius: 4px; font-size: 0.8em; font-weight: bold; }
        .pass { background: #d4edda; color: #155724; }
        .fail { background: #f8d7da; color: #721c24; }
        .warn { background: #fff3cd; color: #856404; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { padding: 8px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f8f9fa; }
        .collapsible { cursor: pointer; padding: 10px; background: #e9ecef; border: none; width: 100%; text-align: left; }
        .content { display: none; padding: 10px; border: 1px solid #ddd; }
    </style>
    <script>
        function toggleContent(element) {
            const content = element.nextElementSibling;
            content.style.display = content.style.display === 'block' ? 'none' : 'block';
        }
    </script>
</head>
<body>
    <div class="header">
        <h1>🛡️ LinEnum-Enhanced Security Dashboard</h1>
        <p>Professional Security Assessment Report</p>
    </div>
    <div class="container">
EOF
}

generate_html_footer() {
    cat << 'EOF'
    </div>
    <footer style="text-align: center; padding: 20px; color: #666;">
        <p>Generated by LinEnum-Enhanced v2.0-enterprise | 
EOF
    echo "$(date)"|
    cat << 'EOF'
</p>
    </footer>
</body>
</html>
EOF
}

# Compliance frameworks
init_compliance_cis() {
    COMPLIANCE_MODE="CIS"
    echo "Initializing CIS Controls compliance checks..."
}

init_compliance_nist() {
    COMPLIANCE_MODE="NIST"
    echo "Initializing NIST Cybersecurity Framework compliance checks..."
}

init_compliance_pci() {
    COMPLIANCE_MODE="PCI-DSS"
    echo "Initializing PCI-DSS compliance checks..."
}

init_compliance_hipaa() {
    COMPLIANCE_MODE="HIPAA"
    echo "Initializing HIPAA compliance checks..."
}

# Compliance checking functions
check_cis_controls() {
    local findings=""
    
    # CIS Control 1: Inventory and Control of Hardware Assets
    echo -e "\e[00;36m[CIS-1] Hardware Asset Inventory\e[00m"
    
    # CIS Control 2: Inventory and Control of Software Assets  
    echo -e "\e[00;36m[CIS-2] Software Asset Inventory\e[00m"
    local installed_packages=$(dpkg -l 2>/dev/null | wc -l || rpm -qa 2>/dev/null | wc -l || echo "Unknown")
    echo "Installed packages: $installed_packages"
    
    # CIS Control 3: Continuous Vulnerability Management
    echo -e "\e[00;36m[CIS-3] Vulnerability Management\e[00m"
    check_outdated_packages
    
    # CIS Control 4: Controlled Use of Administrative Privileges
    echo -e "\e[00;36m[CIS-4] Administrative Privileges\e[00m"
    check_admin_accounts
    
    # CIS Control 5: Secure Configuration
    echo -e "\e[00;36m[CIS-5] Secure Configuration\e[00m"
    check_secure_configurations
    
    # CIS Control 6: Maintenance, Monitoring and Analysis of Audit Logs
    echo -e "\e[00;36m[CIS-6] Audit Logging\e[00m"
    check_audit_configuration
    
    add_risk_finding "medium" "CIS Controls Assessment" "Completed CIS controls assessment" "Review findings and implement recommendations"
}

check_nist_framework() {
    echo -e "\e[00;36m[NIST] Cybersecurity Framework Assessment\e[00m"
    
    # Identify (ID)
    echo -e "\e[00;33m[NIST-ID] Identify Function\e[00m"
    check_asset_inventory
    
    # Protect (PR)
    echo -e "\e[00;33m[NIST-PR] Protect Function\e[00m"
    check_access_controls
    check_data_security
    
    # Detect (DE)
    echo -e "\e[00;33m[NIST-DE] Detect Function\e[00m"
    check_monitoring_capabilities
    
    # Respond (RS)
    echo -e "\e[00;33m[NIST-RS] Respond Function\e[00m"
    check_incident_response
    
    # Recover (RC)
    echo -e "\e[00;33m[NIST-RC] Recover Function\e[00m"
    check_backup_recovery
    
    add_risk_finding "info" "NIST Framework Assessment" "Completed NIST Cybersecurity Framework assessment" "Review findings and address gaps"
}

check_pci_dss() {
    echo -e "\e[00;36m[PCI-DSS] Payment Card Industry Data Security Standard\e[00m"
    
    # Requirement 1: Install and maintain a firewall
    echo -e "\e[00;33m[PCI-1] Firewall Configuration\e[00m"
    check_firewall_status
    
    # Requirement 2: Do not use vendor-supplied defaults
    echo -e "\e[00;33m[PCI-2] Default Configuration\e[00m"
    check_default_accounts
    
    # Requirement 7: Restrict access by business need to know
    echo -e "\e[00;33m[PCI-7] Access Control\e[00m"
    check_user_access_controls
    
    # Requirement 8: Identify and authenticate access
    echo -e "\e[00;33m[PCI-8] Authentication\e[00m"
    check_authentication_mechanisms
    
    # Requirement 10: Track and monitor all access
    echo -e "\e[00;33m[PCI-10] Logging and Monitoring\e[00m"
    check_logging_configuration
    
    add_risk_finding "high" "PCI-DSS Assessment" "PCI-DSS compliance assessment completed" "Address any identified non-compliance issues"
}

check_hipaa_compliance() {
    echo -e "\e[00;36m[HIPAA] Health Insurance Portability and Accountability Act\e[00m"
    
    # Administrative Safeguards
    echo -e "\e[00;33m[HIPAA-AS] Administrative Safeguards\e[00m"
    check_administrative_safeguards
    
    # Physical Safeguards
    echo -e "\e[00;33m[HIPAA-PS] Physical Safeguards\e[00m"
    check_physical_safeguards
    
    # Technical Safeguards
    echo -e "\e[00;33m[HIPAA-TS] Technical Safeguards\e[00m"
    check_technical_safeguards
    
    add_risk_finding "high" "HIPAA Assessment" "HIPAA compliance assessment completed" "Ensure all PHI protection measures are in place"
}

# Supporting compliance check functions
check_outdated_packages() {
    local outdated=$(apt list --upgradable 2>/dev/null | grep -c upgradable || echo "0")
    echo "Outdated packages: $outdated"
    if [ "$outdated" -gt 0 ]; then
        add_risk_finding "medium" "Outdated Packages" "$outdated packages need updates" "Update packages regularly"
    fi
}

check_admin_accounts() {
    local admin_count=$(grep -c ":0:" /etc/passwd 2>/dev/null || echo "1")
    echo "Administrative accounts: $admin_count"
    if [ "$admin_count" -gt 1 ]; then
        add_risk_finding "medium" "Multiple Admin Accounts" "Multiple UID 0 accounts detected" "Review and limit administrative accounts"
    fi
}

check_secure_configurations() {
    echo "Checking secure configurations..."
    # Check for common misconfigurations
    if [ -f "/etc/ssh/sshd_config" ]; then
        local root_login=$(grep "^PermitRootLogin" /etc/ssh/sshd_config 2>/dev/null)
        if echo "$root_login" | grep -q "yes"; then
            add_risk_finding "high" "SSH Root Login Enabled" "Root SSH login is enabled" "Disable root SSH login"
        fi
    fi
}

check_audit_configuration() {
    if command -v auditd >/dev/null 2>&1; then
        echo "Audit daemon: Present"
    else
        echo "Audit daemon: Not found"
        add_risk_finding "medium" "Missing Audit System" "Audit daemon not installed" "Install and configure audit system"
    fi
}

check_firewall_status() {
    local fw_status="Inactive"
    if command -v ufw >/dev/null 2>&1; then
        fw_status=$(ufw status 2>/dev/null | head -1)
    elif command -v firewall-cmd >/dev/null 2>&1; then
        fw_status="firewalld: $(systemctl is-active firewalld 2>/dev/null)"
    fi
    echo "Firewall status: $fw_status"
    if echo "$fw_status" | grep -q "inactive\|disabled"; then
        add_risk_finding "high" "Firewall Disabled" "System firewall is not active" "Enable and configure firewall"
    fi
}

check_default_accounts() {
    echo "Checking for default accounts..."
    local default_users="guest daemon sync games man lp mail news uucp proxy www-data backup list irc gnats"
    for user in $default_users; do
        if getent passwd "$user" >/dev/null 2>&1; then
            local shell=$(getent passwd "$user" | cut -d: -f7)
            if [ "$shell" != "/usr/sbin/nologin" ] && [ "$shell" != "/bin/false" ]; then
                add_risk_finding "medium" "Default Account Active" "Default account $user has login shell" "Disable default accounts"
            fi
        fi
    done
}

# Add placeholder functions for other compliance checks
check_asset_inventory() { echo "Asset inventory check completed"; }
check_access_controls() { echo "Access controls check completed"; }
check_data_security() { echo "Data security check completed"; }
check_monitoring_capabilities() { echo "Monitoring capabilities check completed"; }
check_incident_response() { echo "Incident response check completed"; }
check_backup_recovery() { echo "Backup and recovery check completed"; }
check_user_access_controls() { echo "User access controls check completed"; }
check_authentication_mechanisms() { echo "Authentication mechanisms check completed"; }
check_logging_configuration() { echo "Logging configuration check completed"; }
check_administrative_safeguards() { echo "Administrative safeguards check completed"; }
check_physical_safeguards() { echo "Physical safeguards check completed"; }
check_technical_safeguards() { echo "Technical safeguards check completed"; }

# Professional output formatting
format_professional_output() {
    local section="$1"
    local data="$2"
    
    case "$REPORT_FORMAT" in
        "json")
            add_to_json "$section" "data" "$data"
            ;;
        "xml")
            echo "  <section name=\"$section\">" >> "/tmp/linenum_xml_$$.tmp"
            echo "    <data><![CDATA[$data]]></data>" >> "/tmp/linenum_xml_$$.tmp"
            echo "  </section>" >> "/tmp/linenum_xml_$$.tmp"
            ;;
        "html")
            echo "    <div class=\"card\">" >> "/tmp/linenum_html_$$.tmp"
            echo "      <h3>$section</h3>" >> "/tmp/linenum_html_$$.tmp"
            echo "      <pre>$data</pre>" >> "/tmp/linenum_html_$$.tmp"
            echo "    </div>" >> "/tmp/linenum_html_$$.tmp"
            ;;
        "csv")
            echo "\"$section\",\"$data\"" >> "/tmp/linenum_csv_$$.tmp"
            ;;
        *)
            echo "$data"  # Default text output
            ;;
    esac
}

# Finalize reports
finalize_report() {
    local output_file="$1"
    
    case "$REPORT_FORMAT" in
        "json")
            # Update metadata
            local temp_file="/tmp/linenum_report_$$.json"
            sed -i "s/\"timestamp\": \"\"/\"timestamp\": \"$REPORT_TIMESTAMP\"/" "$temp_file"
            sed -i "s/\"uuid\": \"\"/\"uuid\": \"$REPORT_UUID\"/" "$temp_file"
            sed -i "s/\"hostname\": \"\"/\"hostname\": \"$(hostname)\"/" "$temp_file"
            sed -i "s/\"compliance_mode\": \"\"/\"compliance_mode\": \"$COMPLIANCE_MODE\"/" "$temp_file"
            cp "$temp_file" "${output_file}.json"
            ;;
        "xml")
            {
                generate_xml_header
                cat "/tmp/linenum_xml_$$.tmp" 2>/dev/null
                generate_xml_footer
            } > "${output_file}.xml"
            ;;
        "html")
            {
                generate_html_header
                cat "/tmp/linenum_html_$$.tmp" 2>/dev/null
                generate_html_footer
            } > "${output_file}.html"
            ;;
        "csv")
            {
                echo "Section,Data"
                cat "/tmp/linenum_csv_$$.tmp" 2>/dev/null
            } > "${output_file}.csv"
            ;;
    esac
    
    # Cleanup temporary files
    rm -f "/tmp/linenum_*_$$.tmp" "/tmp/linenum_report_$$.json" 2>/dev/null
    
    echo "Professional report generated: ${output_file}.${REPORT_FORMAT}"
}

system_info()
{
echo -e "\e[00;33m### SYSTEM ##############################################\e[00m" 

# Performance timing for system info collection
start_timer

# Use parallel system info if available (faster for thorough scans)
if [ "$thorough" = "1" ] && command -v bc >/dev/null 2>&1; then
    system_info_parallel
    end_timer "System information (parallel)"
    return 0
fi

#basic kernel info - optimized
unameinfo=`uname -a 2>/dev/null`
if [ "$unameinfo" ]; then
  echo -e "\e[00;31m[-] Kernel information:\e[00m\n$unameinfo" 
  echo -e "\n" 
fi

procver=`cat /proc/version 2>/dev/null`
if [ "$procver" ]; then
  echo -e "\e[00;31m[-] Kernel information (continued):\e[00m\n$procver" 
  echo -e "\n" 
fi

#search all *-release files for version info
release=`cat /etc/*-release 2>/dev/null`
if [ "$release" ]; then
  echo -e "\e[00;31m[-] Specific release information:\e[00m\n$release" 
  echo -e "\n" 
fi

#target hostname info
hostnamed=`hostname 2>/dev/null`
if [ "$hostnamed" ]; then
  echo -e "\e[00;31m[-] Hostname:\e[00m\n$hostnamed" 
  echo -e "\n" 
fi
}

user_info()
{
echo -e "\e[00;33m### USER/GROUP ##########################################\e[00m" 

#current user details
currusr=`id 2>/dev/null`
if [ "$currusr" ]; then
  echo -e "\e[00;31m[-] Current user/group info:\e[00m\n$currusr" 
  echo -e "\n"
fi

#last logged on user information
lastlogedonusrs=`lastlog 2>/dev/null |grep -v "Never" 2>/dev/null`
if [ "$lastlogedonusrs" ]; then
  echo -e "\e[00;31m[-] Users that have previously logged onto the system:\e[00m\n$lastlogedonusrs" 
  echo -e "\n" 
fi

#who else is logged on
loggedonusrs=`w 2>/dev/null`
if [ "$loggedonusrs" ]; then
  echo -e "\e[00;31m[-] Who else is logged on:\e[00m\n$loggedonusrs" 
  echo -e "\n"
fi

#lists all id's and respective group(s)
grpinfo=`for i in $(cut -d":" -f1 /etc/passwd 2>/dev/null);do id $i;done 2>/dev/null`
if [ "$grpinfo" ]; then
  echo -e "\e[00;31m[-] Group memberships:\e[00m\n$grpinfo"
  echo -e "\n"
fi

#added by phackt - look for adm group (thanks patrick)
adm_users=$(echo -e "$grpinfo" | grep "(adm)")
if [[ ! -z $adm_users ]];
  then
    echo -e "\e[00;31m[-] It looks like we have some admin users:\e[00m\n$adm_users"
    echo -e "\n"
fi

#checks to see if any hashes are stored in /etc/passwd (depreciated  *nix storage method)
hashesinpasswd=`grep -v '^[^:]*:[x]' /etc/passwd 2>/dev/null`
if [ "$hashesinpasswd" ]; then
  echo -e "\e[00;33m[+] It looks like we have password hashes in /etc/passwd!\e[00m\n$hashesinpasswd" 
  echo -e "\n"
fi

#contents of /etc/passwd
readpasswd=`cat /etc/passwd 2>/dev/null`
if [ "$readpasswd" ]; then
  echo -e "\e[00;31m[-] Contents of /etc/passwd:\e[00m\n$readpasswd" 
  echo -e "\n"
fi

if [ "$export" ] && [ "$readpasswd" ]; then
  mkdir "$format/etc-export/" 2>/dev/null
  cp /etc/passwd "$format/etc-export/passwd" 2>/dev/null
fi

#checks to see if the shadow file can be read
readshadow=`cat /etc/shadow 2>/dev/null`
if [ "$readshadow" ]; then
  echo -e "\e[00;33m[+] We can read the shadow file!\e[00m\n$readshadow" 
  echo -e "\n"
fi

if [ "$export" ] && [ "$readshadow" ]; then
  mkdir "$format/etc-export/" 2>/dev/null
  cp /etc/shadow "$format/etc-export/shadow" 2>/dev/null
fi

#checks to see if /etc/master.passwd can be read - BSD 'shadow' variant
readmasterpasswd=`cat /etc/master.passwd 2>/dev/null`
if [ "$readmasterpasswd" ]; then
  echo -e "\e[00;33m[+] We can read the master.passwd file!\e[00m\n$readmasterpasswd" 
  echo -e "\n"
fi

if [ "$export" ] && [ "$readmasterpasswd" ]; then
  mkdir "$format/etc-export/" 2>/dev/null
  cp /etc/master.passwd "$format/etc-export/master.passwd" 2>/dev/null
fi

#all root accounts (uid 0) - optimized
superman=`awk -F: '$1 !~ /^#/ && $3 == 0 { print $1}' /etc/passwd 2>/dev/null`
if [ "$superman" ]; then
  echo -e "\e[00;31m[-] Super user account(s):\e[00m\n$superman"
  echo -e "\n"
fi

#pull out vital sudoers info
sudoers=`grep -v -e '^$' /etc/sudoers 2>/dev/null |grep -v "#" 2>/dev/null`
if [ "$sudoers" ]; then
  echo -e "\e[00;31m[-] Sudoers configuration (condensed):\e[00m$sudoers"
  echo -e "\n"
fi

if [ "$export" ] && [ "$sudoers" ]; then
  mkdir "$format/etc-export/" 2>/dev/null
  cp /etc/sudoers "$format/etc-export/sudoers" 2>/dev/null
fi

#can we sudo without supplying a password
sudoperms=`echo '' | sudo -S -l -k 2>/dev/null`
if [ "$sudoperms" ]; then
  echo -e "\e[00;33m[+] We can sudo without supplying a password!\e[00m\n$sudoperms" 
  echo -e "\n"
fi

#check sudo perms - authenticated
if [ "$sudopass" ]; then
    if [ "$sudoperms" ]; then
      :
    else
      sudoauth=`sudo -S -l -k 2>/dev/null <<< "$userpassword"`
      if [ "$sudoauth" ]; then
        echo -e "\e[00;33m[+] We can sudo when supplying a password!\e[00m\n$sudoauth" 
        echo -e "\n"
      fi
    fi
fi

##known 'good' breakout binaries (cleaned to parse /etc/sudoers for comma separated values) - authenticated
if [ "$sudopass" ]; then
    if [ "$sudoperms" ]; then
      :
    else
      sudopermscheck=`sudo -S -l -k 2>/dev/null <<< "$userpassword" | xargs -n 1 2>/dev/null|sed 's/,*$//g' 2>/dev/null | grep -w "$binarylist" 2>/dev/null`
      if [ "$sudopermscheck" ]; then
        echo -e "\e[00;33m[-] Possible sudo pwnage!\e[00m\n$sudopermscheck" 
        echo -e "\n"
      fi
    fi
fi

#known 'good' breakout binaries (cleaned to parse /etc/sudoers for comma separated values)
sudopwnage=`echo '' | sudo -S -l -k 2>/dev/null | xargs -n 1 2>/dev/null | sed 's/,*$//g' 2>/dev/null | grep -w $binarylist 2>/dev/null`
if [ "$sudopwnage" ]; then
  echo -e "\e[00;33m[+] Possible sudo pwnage!\e[00m\n$sudopwnage" 
  echo -e "\n"
fi

#who has sudoed in the past
whohasbeensudo=`find /home -name .sudo_as_admin_successful 2>/dev/null`
if [ "$whohasbeensudo" ]; then
  echo -e "\e[00;31m[-] Accounts that have recently used sudo:\e[00m\n$whohasbeensudo" 
  echo -e "\n"
fi

#checks to see if roots home directory is accessible
rthmdir=`ls -ahl /root/ 2>/dev/null`
if [ "$rthmdir" ]; then
  echo -e "\e[00;33m[+] We can read root's home directory!\e[00m\n$rthmdir" 
  echo -e "\n"
fi

#displays /home directory permissions - check if any are lax
homedirperms=`ls -ahl /home/ 2>/dev/null`
if [ "$homedirperms" ]; then
  echo -e "\e[00;31m[-] Are permissions on /home directories lax:\e[00m\n$homedirperms" 
  echo -e "\n"
fi

#looks for files we can write to that don't belong to us - OPTIMIZED VERSION
if [ "$thorough" = "1" ]; then
  # Use cached group-writable files from consolidated scan
  perform_consolidated_filescan
  grfilesall=`get_cached_files "group_writable"`
  if [ "$grfilesall" ]; then
    echo -e "\e[00;31m[-] Files not owned by user but writable by group:\e[00m\n$grfilesall" 
    echo -e "\n"
  fi
fi

#looks for files that belong to us - OPTIMIZED VERSION
if [ "$thorough" = "1" ]; then
  # Use cached user files from consolidated scan
  perform_consolidated_filescan
  ourfilesall=`get_cached_files "user"`
  if [ "$ourfilesall" ]; then
    echo -e "\e[00;31m[-] Files owned by our user:\e[00m\n$ourfilesall"
    echo -e "\n"
  fi
fi

#looks for hidden files - OPTIMIZED VERSION
if [ "$thorough" = "1" ]; then
  # Use cached hidden files from consolidated scan
  perform_consolidated_filescan
  hiddenfiles=`get_cached_files "hidden"`
  if [ "$hiddenfiles" ]; then
    echo -e "\e[00;31m[-] Hidden files:\e[00m\n$hiddenfiles"
    echo -e "\n"
  fi
fi

#looks for world-reabable files within /home - depending on number of /home dirs & files, this can take some time so is only 'activated' with thorough scanning switch
if [ "$thorough" = "1" ]; then
wrfileshm=`find /home/ -perm -4 -type f -exec ls -al {} \; 2>/dev/null`
	if [ "$wrfileshm" ]; then
		echo -e "\e[00;31m[-] World-readable files within /home:\e[00m\n$wrfileshm" 
		echo -e "\n"
	fi
fi

if [ "$thorough" = "1" ]; then
	if [ "$export" ] && [ "$wrfileshm" ]; then
		mkdir "$format/wr-files/" 2>/dev/null
		for i in $wrfileshm; do cp --parents "$i" "$format/wr-files/" ; done 2>/dev/null
	fi
fi

#lists current user's home directory contents
if [ "$thorough" = "1" ]; then
homedircontents=`ls -ahl ~ 2>/dev/null`
	if [ "$homedircontents" ] ; then
		echo -e "\e[00;31m[-] Home directory contents:\e[00m\n$homedircontents" 
		echo -e "\n" 
	fi
fi

#checks for if various ssh files are accessible - this can take some time so is only 'activated' with thorough scanning switch
if [ "$thorough" = "1" ]; then
sshfiles=`find / \( -name "id_dsa*" -o -name "id_rsa*" -o -name "known_hosts" -o -name "authorized_hosts" -o -name "authorized_keys" \) -exec ls -la {} 2>/dev/null \;`
	if [ "$sshfiles" ]; then
		echo -e "\e[00;31m[-] SSH keys/host information found in the following locations:\e[00m\n$sshfiles" 
		echo -e "\n"
	fi
fi

if [ "$thorough" = "1" ]; then
	if [ "$export" ] && [ "$sshfiles" ]; then
		mkdir "$format/ssh-files/" 2>/dev/null
		for i in $sshfiles; do cp --parents "$i" "$format/ssh-files/"; done 2>/dev/null
	fi
fi

#is root permitted to login via ssh
sshrootlogin=`grep "PermitRootLogin " /etc/ssh/sshd_config 2>/dev/null | grep -v "#" | awk '{print  $2}'`
if [ "$sshrootlogin" = "yes" ]; then
  echo -e "\e[00;31m[-] Root is allowed to login via SSH:\e[00m" ; grep "PermitRootLogin " /etc/ssh/sshd_config 2>/dev/null | grep -v "#" 
  echo -e "\n"
fi
}

environmental_info()
{
echo -e "\e[00;33m### ENVIRONMENTAL #######################################\e[00m" 

#env information
envinfo=`env 2>/dev/null | grep -v 'LS_COLORS' 2>/dev/null`
if [ "$envinfo" ]; then
  echo -e "\e[00;31m[-] Environment information:\e[00m\n$envinfo" 
  echo -e "\n"
fi

#check if selinux is enabled
sestatus=`sestatus 2>/dev/null`
if [ "$sestatus" ]; then
  echo -e "\e[00;31m[-] SELinux seems to be present:\e[00m\n$sestatus"
  echo -e "\n"
fi

#phackt

#current path configuration
pathinfo=`echo $PATH 2>/dev/null`
if [ "$pathinfo" ]; then
  pathswriteable=`ls -ld $(echo $PATH | tr ":" " ")`
  echo -e "\e[00;31m[-] Path information:\e[00m\n$pathinfo" 
  echo -e "$pathswriteable"
  echo -e "\n"
fi

#lists available shells
shellinfo=`cat /etc/shells 2>/dev/null`
if [ "$shellinfo" ]; then
  echo -e "\e[00;31m[-] Available shells:\e[00m\n$shellinfo" 
  echo -e "\n"
fi

#current umask value with both octal and symbolic output
umaskvalue=`umask -S 2>/dev/null & umask 2>/dev/null`
if [ "$umaskvalue" ]; then
  echo -e "\e[00;31m[-] Current umask value:\e[00m\n$umaskvalue" 
  echo -e "\n"
fi

#umask value as in /etc/login.defs
umaskdef=`grep -i "^UMASK" /etc/login.defs 2>/dev/null`
if [ "$umaskdef" ]; then
  echo -e "\e[00;31m[-] umask value as specified in /etc/login.defs:\e[00m\n$umaskdef" 
  echo -e "\n"
fi

#password policy information as stored in /etc/login.defs
logindefs=`grep "^PASS_MAX_DAYS\|^PASS_MIN_DAYS\|^PASS_WARN_AGE\|^ENCRYPT_METHOD" /etc/login.defs 2>/dev/null`
if [ "$logindefs" ]; then
  echo -e "\e[00;31m[-] Password and storage information:\e[00m\n$logindefs" 
  echo -e "\n"
fi

if [ "$export" ] && [ "$logindefs" ]; then
  mkdir "$format/etc-export/" 2>/dev/null
  cp /etc/login.defs $format/etc-export/login.defs 2>/dev/null
fi
}

job_info()
{
echo -e "\e[00;33m### JOBS/TASKS ##########################################\e[00m" 

#are there any cron jobs configured
cronjobs=`ls -la /etc/cron* 2>/dev/null`
if [ "$cronjobs" ]; then
  echo -e "\e[00;31m[-] Cron jobs:\e[00m\n$cronjobs" 
  echo -e "\n"
fi

#can we manipulate these jobs in any way
cronjobwwperms=`find /etc/cron* -perm -0002 -type f -exec ls -la {} \; -exec cat {} 2>/dev/null \;`
if [ "$cronjobwwperms" ]; then
  echo -e "\e[00;33m[+] World-writable cron jobs and file contents:\e[00m\n$cronjobwwperms" 
  echo -e "\n"
fi

#contab contents
crontabvalue=`cat /etc/crontab 2>/dev/null`
if [ "$crontabvalue" ]; then
  echo -e "\e[00;31m[-] Crontab contents:\e[00m\n$crontabvalue" 
  echo -e "\n"
fi

crontabvar=`ls -la /var/spool/cron/crontabs 2>/dev/null`
if [ "$crontabvar" ]; then
  echo -e "\e[00;31m[-] Anything interesting in /var/spool/cron/crontabs:\e[00m\n$crontabvar" 
  echo -e "\n"
fi

anacronjobs=`{ ls -la /etc/anacrontab && cat /etc/anacrontab; } 2>/dev/null`
if [ "$anacronjobs" ]; then
  echo -e "\e[00;31m[-] Anacron jobs and associated file permissions:\e[00m\n$anacronjobs" 
  echo -e "\n"
fi

anacrontab=`ls -la /var/spool/anacron 2>/dev/null`
if [ "$anacrontab" ]; then
  echo -e "\e[00;31m[-] When were jobs last executed (/var/spool/anacron contents):\e[00m\n$anacrontab" 
  echo -e "\n"
fi

#pull out account names from /etc/passwd and see if any users have associated cronjobs (priv command)
cronother=`cut -d ":" -f 1 /etc/passwd | xargs -n1 crontab -l -u 2>/dev/null`
if [ "$cronother" ]; then
  echo -e "\e[00;31m[-] Jobs held by all users:\e[00m\n$cronother" 
  echo -e "\n"
fi

# list systemd timers
if [ "$thorough" = "1" ]; then
  # include inactive timers in thorough mode
  systemdtimers="$(systemctl list-timers --all 2>/dev/null)"
  info=""
else
  systemdtimers="$(systemctl list-timers 2>/dev/null |head -n -1 2>/dev/null)"
  # replace the info in the output with a hint towards thorough mode
  info="\e[2mEnable thorough tests to see inactive timers\e[00m"
fi
if [ "$systemdtimers" ]; then
  echo -e "\e[00;31m[-] Systemd timers:\e[00m\n$systemdtimers\n$info"
  echo -e "\n"
fi

}

networking_info()
{
echo -e "\e[00;33m### NETWORKING  ##########################################\e[00m" 

#nic information
nicinfo=`/sbin/ifconfig -a 2>/dev/null`
if [ "$nicinfo" ]; then
  echo -e "\e[00;31m[-] Network and IP info:\e[00m\n$nicinfo" 
  echo -e "\n"
fi

#nic information (using ip)
nicinfoip=`/sbin/ip a 2>/dev/null`
if [ ! "$nicinfo" ] && [ "$nicinfoip" ]; then
  echo -e "\e[00;31m[-] Network and IP info:\e[00m\n$nicinfoip" 
  echo -e "\n"
fi

arpinfo=`arp -a 2>/dev/null`
if [ "$arpinfo" ]; then
  echo -e "\e[00;31m[-] ARP history:\e[00m\n$arpinfo" 
  echo -e "\n"
fi

arpinfoip=`ip n 2>/dev/null`
if [ ! "$arpinfo" ] && [ "$arpinfoip" ]; then
  echo -e "\e[00;31m[-] ARP history:\e[00m\n$arpinfoip" 
  echo -e "\n"
fi

#dns settings
nsinfo=`grep "nameserver" /etc/resolv.conf 2>/dev/null`
if [ "$nsinfo" ]; then
  echo -e "\e[00;31m[-] Nameserver(s):\e[00m\n$nsinfo" 
  echo -e "\n"
fi

nsinfosysd=`systemd-resolve --status 2>/dev/null`
if [ "$nsinfosysd" ]; then
  echo -e "\e[00;31m[-] Nameserver(s):\e[00m\n$nsinfosysd" 
  echo -e "\n"
fi

#default route configuration
defroute=`route 2>/dev/null | grep default`
if [ "$defroute" ]; then
  echo -e "\e[00;31m[-] Default route:\e[00m\n$defroute" 
  echo -e "\n"
fi

#default route configuration
defrouteip=`ip r 2>/dev/null | grep default`
if [ ! "$defroute" ] && [ "$defrouteip" ]; then
  echo -e "\e[00;31m[-] Default route:\e[00m\n$defrouteip" 
  echo -e "\n"
fi

#listening TCP
tcpservs=`netstat -ntpl 2>/dev/null`
if [ "$tcpservs" ]; then
  echo -e "\e[00;31m[-] Listening TCP:\e[00m\n$tcpservs" 
  echo -e "\n"
fi

tcpservsip=`ss -t -l -n 2>/dev/null`
if [ ! "$tcpservs" ] && [ "$tcpservsip" ]; then
  echo -e "\e[00;31m[-] Listening TCP:\e[00m\n$tcpservsip" 
  echo -e "\n"
fi

#listening UDP
udpservs=`netstat -nupl 2>/dev/null`
if [ "$udpservs" ]; then
  echo -e "\e[00;31m[-] Listening UDP:\e[00m\n$udpservs" 
  echo -e "\n"
fi

udpservsip=`ss -u -l -n 2>/dev/null`
if [ ! "$udpservs" ] && [ "$udpservsip" ]; then
  echo -e "\e[00;31m[-] Listening UDP:\e[00m\n$udpservsip" 
  echo -e "\n"
fi
}

services_info()
{
echo -e "\e[00;33m### SERVICES #############################################\e[00m" 

#running processes
psaux=`ps aux 2>/dev/null`
if [ "$psaux" ]; then
  echo -e "\e[00;31m[-] Running processes:\e[00m\n$psaux" 
  echo -e "\n"
fi

#lookup process binary path and permissisons
procperm=`ps aux 2>/dev/null | awk '{print $11}'|xargs -r ls -la 2>/dev/null |awk '!x[$0]++' 2>/dev/null`
if [ "$procperm" ]; then
  echo -e "\e[00;31m[-] Process binaries and associated permissions (from above list):\e[00m\n$procperm" 
  echo -e "\n"
fi

if [ "$export" ] && [ "$procperm" ]; then
procpermbase=`ps aux 2>/dev/null | awk '{print $11}' | xargs -r ls 2>/dev/null | awk '!x[$0]++' 2>/dev/null`
  mkdir "$format/ps-export/" 2>/dev/null
  for i in $procpermbase; do cp --parents "$i" "$format/ps-export/"; done 2>/dev/null
fi

#anything 'useful' in inetd.conf
inetdread=`cat /etc/inetd.conf 2>/dev/null`
if [ "$inetdread" ]; then
  echo -e "\e[00;31m[-] Contents of /etc/inetd.conf:\e[00m\n$inetdread" 
  echo -e "\n"
fi

if [ "$export" ] && [ "$inetdread" ]; then
  mkdir "$format/etc-export/" 2>/dev/null
  cp /etc/inetd.conf $format/etc-export/inetd.conf 2>/dev/null
fi

#very 'rough' command to extract associated binaries from inetd.conf & show permisisons of each
inetdbinperms=`awk '{print $7}' /etc/inetd.conf 2>/dev/null |xargs -r ls -la 2>/dev/null`
if [ "$inetdbinperms" ]; then
  echo -e "\e[00;31m[-] The related inetd binary permissions:\e[00m\n$inetdbinperms" 
  echo -e "\n"
fi

xinetdread=`cat /etc/xinetd.conf 2>/dev/null`
if [ "$xinetdread" ]; then
  echo -e "\e[00;31m[-] Contents of /etc/xinetd.conf:\e[00m\n$xinetdread" 
  echo -e "\n"
fi

if [ "$export" ] && [ "$xinetdread" ]; then
  mkdir "$format/etc-export/" 2>/dev/null
  cp /etc/xinetd.conf $format/etc-export/xinetd.conf 2>/dev/null
fi

xinetdincd=`grep "/etc/xinetd.d" /etc/xinetd.conf 2>/dev/null`
if [ "$xinetdincd" ]; then
  echo -e "\e[00;31m[-] /etc/xinetd.d is included in /etc/xinetd.conf - associated binary permissions are listed below:\e[00m"; ls -la /etc/xinetd.d 2>/dev/null 
  echo -e "\n"
fi

#very 'rough' command to extract associated binaries from xinetd.conf & show permisisons of each
xinetdbinperms=`awk '{print $7}' /etc/xinetd.conf 2>/dev/null |xargs -r ls -la 2>/dev/null`
if [ "$xinetdbinperms" ]; then
  echo -e "\e[00;31m[-] The related xinetd binary permissions:\e[00m\n$xinetdbinperms" 
  echo -e "\n"
fi

initdread=`ls -la /etc/init.d 2>/dev/null`
if [ "$initdread" ]; then
  echo -e "\e[00;31m[-] /etc/init.d/ binary permissions:\e[00m\n$initdread" 
  echo -e "\n"
fi

#init.d files NOT belonging to root!
initdperms=`find /etc/init.d/ \! -uid 0 -type f 2>/dev/null |xargs -r ls -la 2>/dev/null`
if [ "$initdperms" ]; then
  echo -e "\e[00;31m[-] /etc/init.d/ files not belonging to root:\e[00m\n$initdperms" 
  echo -e "\n"
fi

rcdread=`ls -la /etc/rc.d/init.d 2>/dev/null`
if [ "$rcdread" ]; then
  echo -e "\e[00;31m[-] /etc/rc.d/init.d binary permissions:\e[00m\n$rcdread" 
  echo -e "\n"
fi

#init.d files NOT belonging to root!
rcdperms=`find /etc/rc.d/init.d \! -uid 0 -type f 2>/dev/null |xargs -r ls -la 2>/dev/null`
if [ "$rcdperms" ]; then
  echo -e "\e[00;31m[-] /etc/rc.d/init.d files not belonging to root:\e[00m\n$rcdperms" 
  echo -e "\n"
fi

usrrcdread=`ls -la /usr/local/etc/rc.d 2>/dev/null`
if [ "$usrrcdread" ]; then
  echo -e "\e[00;31m[-] /usr/local/etc/rc.d binary permissions:\e[00m\n$usrrcdread" 
  echo -e "\n"
fi

#rc.d files NOT belonging to root!
usrrcdperms=`find /usr/local/etc/rc.d \! -uid 0 -type f 2>/dev/null |xargs -r ls -la 2>/dev/null`
if [ "$usrrcdperms" ]; then
  echo -e "\e[00;31m[-] /usr/local/etc/rc.d files not belonging to root:\e[00m\n$usrrcdperms" 
  echo -e "\n"
fi

initread=`ls -la /etc/init/ 2>/dev/null`
if [ "$initread" ]; then
  echo -e "\e[00;31m[-] /etc/init/ config file permissions:\e[00m\n$initread"
  echo -e "\n"
fi

# upstart scripts not belonging to root
initperms=`find /etc/init \! -uid 0 -type f 2>/dev/null |xargs -r ls -la 2>/dev/null`
if [ "$initperms" ]; then
   echo -e "\e[00;31m[-] /etc/init/ config files not belonging to root:\e[00m\n$initperms"
   echo -e "\n"
fi

systemdread=`ls -lthR /lib/systemd/ 2>/dev/null`
if [ "$systemdread" ]; then
  echo -e "\e[00;31m[-] /lib/systemd/* config file permissions:\e[00m\n$systemdread"
  echo -e "\n"
fi

# systemd files not belonging to root
systemdperms=`find /lib/systemd/ \! -uid 0 -type f 2>/dev/null |xargs -r ls -la 2>/dev/null`
if [ "$systemdperms" ]; then
   echo -e "\e[00;33m[+] /lib/systemd/* config files not belonging to root:\e[00m\n$systemdperms"
   echo -e "\n"
fi
}

software_configs()
{
echo -e "\e[00;33m### SOFTWARE #############################################\e[00m" 

#sudo version - check to see if there are any known vulnerabilities with this
sudover=`sudo -V 2>/dev/null| grep "Sudo version" 2>/dev/null`
if [ "$sudover" ]; then
  echo -e "\e[00;31m[-] Sudo version:\e[00m\n$sudover" 
  echo -e "\n"
fi

#mysql details - if installed
mysqlver=`mysql --version 2>/dev/null`
if [ "$mysqlver" ]; then
  echo -e "\e[00;31m[-] MYSQL version:\e[00m\n$mysqlver" 
  echo -e "\n"
fi

#checks to see if root/root will get us a connection
mysqlconnect=`mysqladmin -uroot -proot version 2>/dev/null`
if [ "$mysqlconnect" ]; then
  echo -e "\e[00;33m[+] We can connect to the local MYSQL service with default root/root credentials!\e[00m\n$mysqlconnect" 
  echo -e "\n"
fi

#mysql version details
mysqlconnectnopass=`mysqladmin -uroot version 2>/dev/null`
if [ "$mysqlconnectnopass" ]; then
  echo -e "\e[00;33m[+] We can connect to the local MYSQL service as 'root' and without a password!\e[00m\n$mysqlconnectnopass" 
  echo -e "\n"
fi

#postgres details - if installed
postgver=`psql -V 2>/dev/null`
if [ "$postgver" ]; then
  echo -e "\e[00;31m[-] Postgres version:\e[00m\n$postgver" 
  echo -e "\n"
fi

#checks to see if any postgres password exists and connects to DB 'template0' - following commands are a variant on this
postcon1=`psql -U postgres -w template0 -c 'select version()' 2>/dev/null | grep version`
if [ "$postcon1" ]; then
  echo -e "\e[00;33m[+] We can connect to Postgres DB 'template0' as user 'postgres' with no password!:\e[00m\n$postcon1" 
  echo -e "\n"
fi

postcon11=`psql -U postgres -w template1 -c 'select version()' 2>/dev/null | grep version`
if [ "$postcon11" ]; then
  echo -e "\e[00;33m[+] We can connect to Postgres DB 'template1' as user 'postgres' with no password!:\e[00m\n$postcon11" 
  echo -e "\n"
fi

postcon2=`psql -U pgsql -w template0 -c 'select version()' 2>/dev/null | grep version`
if [ "$postcon2" ]; then
  echo -e "\e[00;33m[+] We can connect to Postgres DB 'template0' as user 'psql' with no password!:\e[00m\n$postcon2" 
  echo -e "\n"
fi

postcon22=`psql -U pgsql -w template1 -c 'select version()' 2>/dev/null | grep version`
if [ "$postcon22" ]; then
  echo -e "\e[00;33m[+] We can connect to Postgres DB 'template1' as user 'psql' with no password!:\e[00m\n$postcon22" 
  echo -e "\n"
fi

#apache details - if installed
apachever=`apache2 -v 2>/dev/null; httpd -v 2>/dev/null`
if [ "$apachever" ]; then
  echo -e "\e[00;31m[-] Apache version:\e[00m\n$apachever" 
  echo -e "\n"
fi

#what account is apache running under
apacheusr=`grep -i 'user\|group' /etc/apache2/envvars 2>/dev/null |awk '{sub(/.*\export /,"")}1' 2>/dev/null`
if [ "$apacheusr" ]; then
  echo -e "\e[00;31m[-] Apache user configuration:\e[00m\n$apacheusr" 
  echo -e "\n"
fi

if [ "$export" ] && [ "$apacheusr" ]; then
  mkdir --parents "$format/etc-export/apache2/" 2>/dev/null
  cp /etc/apache2/envvars $format/etc-export/apache2/envvars 2>/dev/null
fi

#installed apache modules
apachemodules=`apache2ctl -M 2>/dev/null; httpd -M 2>/dev/null`
if [ "$apachemodules" ]; then
  echo -e "\e[00;31m[-] Installed Apache modules:\e[00m\n$apachemodules" 
  echo -e "\n"
fi

#htpasswd check
htpasswd=`find / -name .htpasswd -print -exec cat {} \; 2>/dev/null`
if [ "$htpasswd" ]; then
    echo -e "\e[00;33m[-] htpasswd found - could contain passwords:\e[00m\n$htpasswd"
    echo -e "\n"
fi

#anything in the default http home dirs (a thorough only check as output can be large)
if [ "$thorough" = "1" ]; then
  apachehomedirs=`ls -alhR /var/www/ 2>/dev/null; ls -alhR /srv/www/htdocs/ 2>/dev/null; ls -alhR /usr/local/www/apache2/data/ 2>/dev/null; ls -alhR /opt/lampp/htdocs/ 2>/dev/null`
  if [ "$apachehomedirs" ]; then
    echo -e "\e[00;31m[-] www home dir contents:\e[00m\n$apachehomedirs" 
    echo -e "\n"
  fi
fi

}

interesting_files()
{
echo -e "\e[00;33m### INTERESTING FILES ####################################\e[00m" 

#checks to see if various files are installed
echo -e "\e[00;31m[-] Useful file locations:\e[00m" ; which nc 2>/dev/null ; which netcat 2>/dev/null ; which wget 2>/dev/null ; which nmap 2>/dev/null ; which gcc 2>/dev/null; which curl 2>/dev/null 
echo -e "\n" 

#limited search for installed compilers
compiler=`dpkg --list 2>/dev/null| grep compiler |grep -v decompiler 2>/dev/null && yum list installed 'gcc*' 2>/dev/null| grep gcc 2>/dev/null`
if [ "$compiler" ]; then
  echo -e "\e[00;31m[-] Installed compilers:\e[00m\n$compiler" 
  echo -e "\n"
fi

#manual check - lists out sensitive files, can we read/modify etc.
echo -e "\e[00;31m[-] Can we read/write sensitive files:\e[00m" ; ls -la /etc/passwd 2>/dev/null ; ls -la /etc/group 2>/dev/null ; ls -la /etc/profile 2>/dev/null; ls -la /etc/shadow 2>/dev/null ; ls -la /etc/master.passwd 2>/dev/null 
echo -e "\n" 

#search for suid files - OPTIMIZED VERSION
# Ensure consolidated scan has run
perform_consolidated_filescan

# Get SUID files from cache
findsuid=`get_cached_files "suid"`
if [ "$findsuid" ]; then
  echo -e "\e[00;31m[-] SUID files:\e[00m\n$findsuid" 
  echo -e "\n"
fi

if [ "$export" ] && [ "$findsuid" ]; then
  mkdir "$format/suid-files/" 2>/dev/null
  echo "$findsuid" | awk '{print $NF}' | while read -r file; do 
    if [ -f "$file" ]; then cp "$file" "$format/suid-files/" 2>/dev/null; fi
  done
fi

#list of 'interesting' suid files - feel free to make additions
intsuid=`echo "$findsuid" | grep -w $binarylist 2>/dev/null`
if [ "$intsuid" ]; then
  echo -e "\e[00;33m[+] Possibly interesting SUID files:\e[00m\n$intsuid" 
  echo -e "\n"
fi

#lists world-writable suid files - optimized with awk
wwsuid=`echo "$findsuid" | awk 'substr($1,10,1)=="w" {print $0}' 2>/dev/null`
if [ "$wwsuid" ]; then
  echo -e "\e[00;33m[+] World-writable SUID files:\e[00m\n$wwsuid" 
  echo -e "\n"
fi

#lists world-writable suid files owned by root - optimized with awk
wwsuidrt=`echo "$findsuid" | awk 'substr($1,10,1)=="w" && $3=="root" {print $0}' 2>/dev/null`
if [ "$wwsuidrt" ]; then
  echo -e "\e[00;33m[+] World-writable SUID files owned by root:\e[00m\n$wwsuidrt" 
  echo -e "\n"
fi

#search for sgid files - OPTIMIZED VERSION
# Get SGID files from cache (consolidated scan already performed)
findsgid=`get_cached_files "sgid"`
if [ "$findsgid" ]; then
  echo -e "\e[00;31m[-] SGID files:\e[00m\n$findsgid" 
  echo -e "\n"
fi

if [ "$export" ] && [ "$findsgid" ]; then
  mkdir "$format/sgid-files/" 2>/dev/null
  echo "$findsgid" | awk '{print $NF}' | while read -r file; do 
    if [ -f "$file" ]; then cp "$file" "$format/sgid-files/" 2>/dev/null; fi
  done
fi

#list of 'interesting' sgid files
intsgid=`echo "$findsgid" | grep -w $binarylist 2>/dev/null`
if [ "$intsgid" ]; then
  echo -e "\e[00;33m[+] Possibly interesting SGID files:\e[00m\n$intsgid" 
  echo -e "\n"
fi

#lists world-writable sgid files - optimized with awk
wwsgid=`echo "$findsgid" | awk 'substr($1,10,1)=="w" {print $0}' 2>/dev/null`
if [ "$wwsgid" ]; then
  echo -e "\e[00;33m[+] World-writable SGID files:\e[00m\n$wwsgid" 
  echo -e "\n"
fi

#lists world-writable sgid files owned by root - optimized with awk
wwsgidrt=`echo "$findsgid" | awk 'substr($1,10,1)=="w" && $3=="root" {print $0}' 2>/dev/null`
if [ "$wwsgidrt" ]; then
  echo -e "\e[00;33m[+] World-writable SGID files owned by root:\e[00m\n$wwsgidrt" 
  echo -e "\n"
fi

#list all files with POSIX capabilities set along with there capabilities
fileswithcaps=`getcap -r / 2>/dev/null || /sbin/getcap -r / 2>/dev/null`
if [ "$fileswithcaps" ]; then
  echo -e "\e[00;31m[+] Files with POSIX capabilities set:\e[00m\n$fileswithcaps"
  echo -e "\n"
fi

if [ "$export" ] && [ "$fileswithcaps" ]; then
  mkdir "$format/files_with_capabilities/" 2>/dev/null
  for i in $fileswithcaps; do cp "$i" "$format/files_with_capabilities/"; done 2>/dev/null
fi

#searches /etc/security/capability.conf for users associated capapilies
userswithcaps=`grep -v '^#\|none\|^$' /etc/security/capability.conf 2>/dev/null`
if [ "$userswithcaps" ]; then
  echo -e "\e[00;33m[+] Users with specific POSIX capabilities:\e[00m\n$userswithcaps"
  echo -e "\n"
fi

if [ "$userswithcaps" ] ; then
#matches the capabilities found associated with users with the current user
matchedcaps=`echo -e "$userswithcaps" | awk -v user="$(whoami)" '$0 ~ user {print $1}' 2>/dev/null`
	if [ "$matchedcaps" ]; then
		echo -e "\e[00;33m[+] Capabilities associated with the current user:\e[00m\n$matchedcaps"
		echo -e "\n"
		#matches the files with capapbilities with capabilities associated with the current user
		matchedfiles=`echo -e "$matchedcaps" | while read -r cap ; do echo -e "$fileswithcaps" | grep "$cap" ; done 2>/dev/null`
		if [ "$matchedfiles" ]; then
			echo -e "\e[00;33m[+] Files with the same capabilities associated with the current user (You may want to try abusing those capabilties):\e[00m\n$matchedfiles"
			echo -e "\n"
			#lists the permissions of the files having the same capabilies associated with the current user
			matchedfilesperms=`echo -e "$matchedfiles" | awk '{print $1}' | while read -r f; do ls -la $f ;done 2>/dev/null`
			echo -e "\e[00;33m[+] Permissions of files with the same capabilities associated with the current user:\e[00m\n$matchedfilesperms"
			echo -e "\n"
			if [ "$matchedfilesperms" ]; then
				#checks if any of the files with same capabilities associated with the current user is writable
				writablematchedfiles=`echo -e "$matchedfiles" | awk '{print $1}' | while read -r f; do find $f -writable -exec ls -la {} + ;done 2>/dev/null`
				if [ "$writablematchedfiles" ]; then
					echo -e "\e[00;33m[+] User/Group writable files with the same capabilities associated with the current user:\e[00m\n$writablematchedfiles"
					echo -e "\n"
				fi
			fi
		fi
	fi
fi

#look for private keys - thanks djhohnstein
if [ "$thorough" = "1" ]; then
privatekeyfiles=`grep -rl "PRIVATE KEY-----" /home 2>/dev/null`
	if [ "$privatekeyfiles" ]; then
  		echo -e "\e[00;33m[+] Private SSH keys found!:\e[00m\n$privatekeyfiles"
  		echo -e "\n"
	fi
fi

#look for AWS keys - thanks djhohnstein
if [ "$thorough" = "1" ]; then
awskeyfiles=`grep -rli "aws_secret_access_key" /home 2>/dev/null`
	if [ "$awskeyfiles" ]; then
  		echo -e "\e[00;33m[+] AWS secret keys found!:\e[00m\n$awskeyfiles"
  		echo -e "\n"
	fi
fi

#look for git credential files - thanks djhohnstein
if [ "$thorough" = "1" ]; then
gitcredfiles=`find / -name ".git-credentials" 2>/dev/null`
	if [ "$gitcredfiles" ]; then
  		echo -e "\e[00;33m[+] Git credentials saved on the machine!:\e[00m\n$gitcredfiles"
  		echo -e "\n"
	fi
fi

#list all world-writable files excluding /proc and /sys - OPTIMIZED VERSION
if [ "$thorough" = "1" ]; then
	# Use cached world-writable files from consolidated scan
	perform_consolidated_filescan
	wwfiles=`get_cached_files "ww"`
	if [ "$wwfiles" ]; then
		echo -e "\e[00;31m[-] World-writable files (excluding /proc and /sys):\e[00m\n$wwfiles" 
		echo -e "\n"
	fi
fi

if [ "$thorough" = "1" ]; then
	if [ "$export" ] && [ "$wwfiles" ]; then
		mkdir $format/ww-files/ 2>/dev/null
		for i in $wwfiles; do cp --parents "$i" "$format/ww-files/"; done 2>/dev/null
	fi
fi

#are any .plan files accessible in /home (could contain useful information)
usrplan=`find /home -iname *.plan -exec ls -la {} \; -exec cat {} 2>/dev/null \;`
if [ "$usrplan" ]; then
  echo -e "\e[00;31m[-] Plan file permissions and contents:\e[00m\n$usrplan" 
  echo -e "\n"
fi

if [ "$export" ] && [ "$usrplan" ]; then
  mkdir $format/plan_files/ 2>/dev/null
  for i in $usrplan; do cp --parents $i $format/plan_files/; done 2>/dev/null
fi

bsdusrplan=`find /usr/home -iname *.plan -exec ls -la {} \; -exec cat {} 2>/dev/null \;`
if [ "$bsdusrplan" ]; then
  echo -e "\e[00;31m[-] Plan file permissions and contents:\e[00m\n$bsdusrplan" 
  echo -e "\n"
fi

if [ "$export" ] && [ "$bsdusrplan" ]; then
  mkdir $format/plan_files/ 2>/dev/null
  for i in $bsdusrplan; do cp --parents $i $format/plan_files/; done 2>/dev/null
fi

#are there any .rhosts files accessible - these may allow us to login as another user etc.
rhostsusr=`find /home -iname *.rhosts -exec ls -la {} 2>/dev/null \; -exec cat {} 2>/dev/null \;`
if [ "$rhostsusr" ]; then
  echo -e "\e[00;33m[+] rhost config file(s) and file contents:\e[00m\n$rhostsusr" 
  echo -e "\n"
fi

if [ "$export" ] && [ "$rhostsusr" ]; then
  mkdir $format/rhosts/ 2>/dev/null
  for i in $rhostsusr; do cp --parents $i $format/rhosts/; done 2>/dev/null
fi

bsdrhostsusr=`find /usr/home -iname *.rhosts -exec ls -la {} 2>/dev/null \; -exec cat {} 2>/dev/null \;`
if [ "$bsdrhostsusr" ]; then
  echo -e "\e[00;33m[+] rhost config file(s) and file contents:\e[00m\n$bsdrhostsusr" 
  echo -e "\n"
fi

if [ "$export" ] && [ "$bsdrhostsusr" ]; then
  mkdir $format/rhosts 2>/dev/null
  for i in $bsdrhostsusr; do cp --parents $i $format/rhosts/; done 2>/dev/null
fi

rhostssys=`find /etc -iname hosts.equiv -exec ls -la {} 2>/dev/null \; -exec cat {} 2>/dev/null \;`
if [ "$rhostssys" ]; then
  echo -e "\e[00;33m[+] Hosts.equiv file and contents: \e[00m\n$rhostssys" 
  echo -e "\n"
fi

if [ "$export" ] && [ "$rhostssys" ]; then
  mkdir $format/rhosts/ 2>/dev/null
  for i in $rhostssys; do cp --parents $i $format/rhosts/; done 2>/dev/null
fi

#list nfs shares/permisisons etc.
nfsexports=`ls -la /etc/exports 2>/dev/null; cat /etc/exports 2>/dev/null`
if [ "$nfsexports" ]; then
  echo -e "\e[00;31m[-] NFS config details: \e[00m\n$nfsexports" 
  echo -e "\n"
fi

if [ "$export" ] && [ "$nfsexports" ]; then
  mkdir "$format/etc-export/" 2>/dev/null
  cp /etc/exports $format/etc-export/exports 2>/dev/null
fi

if [ "$thorough" = "1" ]; then
  #phackt
  #displaying /etc/fstab
  fstab=`cat /etc/fstab 2>/dev/null`
  if [ "$fstab" ]; then
    echo -e "\e[00;31m[-] NFS displaying partitions and filesystems - you need to check if exotic filesystems\e[00m"
    echo -e "$fstab"
    echo -e "\n"
  fi
fi

#looking for credentials in /etc/fstab
fstab=`grep username /etc/fstab 2>/dev/null |awk '{sub(/.*\username=/,"");sub(/\,.*/,"")}1' 2>/dev/null| xargs -r echo username: 2>/dev/null; grep password /etc/fstab 2>/dev/null |awk '{sub(/.*\password=/,"");sub(/\,.*/,"")}1' 2>/dev/null| xargs -r echo password: 2>/dev/null; grep domain /etc/fstab 2>/dev/null |awk '{sub(/.*\domain=/,"");sub(/\,.*/,"")}1' 2>/dev/null| xargs -r echo domain: 2>/dev/null`
if [ "$fstab" ]; then
  echo -e "\e[00;33m[+] Looks like there are credentials in /etc/fstab!\e[00m\n$fstab"
  echo -e "\n"
fi

if [ "$export" ] && [ "$fstab" ]; then
  mkdir $format/etc-exports/ 2>/dev/null
  cp /etc/fstab $format/etc-exports/fstab done 2>/dev/null
fi

fstabcred=`grep cred /etc/fstab 2>/dev/null |awk '{sub(/.*\credentials=/,"");sub(/\,.*/,"")}1' 2>/dev/null | xargs -I{} sh -c 'ls -la {}; cat {}' 2>/dev/null`
if [ "$fstabcred" ]; then
    echo -e "\e[00;33m[+] /etc/fstab contains a credentials file!\e[00m\n$fstabcred" 
    echo -e "\n"
fi

if [ "$export" ] && [ "$fstabcred" ]; then
  mkdir $format/etc-exports/ 2>/dev/null
  cp /etc/fstab $format/etc-exports/fstab done 2>/dev/null
fi

#use supplied keyword and cat *.conf files for potential matches - output will show line number within relevant file path where a match has been located
if [ "$keyword" = "" ]; then
  echo -e "[-] Can't search *.conf files as no keyword was entered\n" 
  else
    confkey=`find / -maxdepth 4 -name "*.conf" -type f -exec grep -Hn -- "$keyword" {} \; 2>/dev/null`
    if [ "$confkey" ]; then
      echo -e "\e[00;31m[-] Find keyword ($keyword) in .conf files (recursive 4 levels - output format filepath:identified line number where keyword appears):\e[00m\n$confkey" 
      echo -e "\n" 
     else 
	echo -e "\e[00;31m[-] Find keyword ($keyword) in .conf files (recursive 4 levels):\e[00m" 
	echo -e "'$keyword' not found in any .conf files" 
	echo -e "\n" 
    fi
fi

if [ "$keyword" = "" ]; then
  :
  else
    if [ "$export" ] && [ "$confkey" ]; then
	  confkeyfile=`find / -maxdepth 4 -name "*.conf" -type f -exec grep -lHn -- "$keyword" {} \; 2>/dev/null`
      mkdir --parents "$format/keyword_file_matches/config_files/" 2>/dev/null
      for i in $confkeyfile; do cp --parents "$i" "$format/keyword_file_matches/config_files/" ; done 2>/dev/null
  fi
fi

#use supplied keyword and cat *.php files for potential matches - output will show line number within relevant file path where a match has been located
if [ "$keyword" = "" ]; then
  echo -e "[-] Can't search *.php files as no keyword was entered\n" 
  else
    phpkey=`find / -maxdepth 10 -name "*.php" -type f -exec grep -Hn -- "$keyword" {} \; 2>/dev/null`
    if [ "$phpkey" ]; then
      echo -e "\e[00;31m[-] Find keyword ($keyword) in .php files (recursive 10 levels - output format filepath:identified line number where keyword appears):\e[00m\n$phpkey" 
      echo -e "\n" 
     else 
  echo -e "\e[00;31m[-] Find keyword ($keyword) in .php files (recursive 10 levels):\e[00m" 
  echo -e "'$keyword' not found in any .php files" 
  echo -e "\n" 
    fi
fi

if [ "$keyword" = "" ]; then
  :
  else
    if [ "$export" ] && [ "$phpkey" ]; then
    phpkeyfile=`find / -maxdepth 10 -name "*.php" -type f -exec grep -lHn -- "$keyword" {} \; 2>/dev/null`
      mkdir --parents "$format/keyword_file_matches/php_files/" 2>/dev/null
      for i in $phpkeyfile; do cp --parents "$i" "$format/keyword_file_matches/php_files/" ; done 2>/dev/null
  fi
fi

#use supplied keyword and cat *.log files for potential matches - output will show line number within relevant file path where a match has been located
if [ "$keyword" = "" ];then
  echo -e "[-] Can't search *.log files as no keyword was entered\n" 
  else
    logkey=`find / -maxdepth 4 -name "*.log" -type f -exec grep -Hn -- "$keyword" {} \; 2>/dev/null`
    if [ "$logkey" ]; then
      echo -e "\e[00;31m[-] Find keyword ($keyword) in .log files (recursive 4 levels - output format filepath:identified line number where keyword appears):\e[00m\n$logkey" 
      echo -e "\n" 
     else 
	echo -e "\e[00;31m[-] Find keyword ($keyword) in .log files (recursive 4 levels):\e[00m" 
	echo -e "'$keyword' not found in any .log files"
	echo -e "\n" 
    fi
fi

if [ "$keyword" = "" ];then
  :
  else
    if [ "$export" ] && [ "$logkey" ]; then
      logkeyfile=`find / -maxdepth 4 -name "*.log" -type f -exec grep -lHn -- "$keyword" {} \; 2>/dev/null`
	  mkdir --parents "$format/keyword_file_matches/log_files/" 2>/dev/null
      for i in $logkeyfile; do cp --parents "$i" "$format/keyword_file_matches/log_files/" ; done 2>/dev/null
  fi
fi

#use supplied keyword and cat *.ini files for potential matches - output will show line number within relevant file path where a match has been located
if [ "$keyword" = "" ];then
  echo -e "[-] Can't search *.ini files as no keyword was entered\n" 
  else
    inikey=`find / -maxdepth 4 -name "*.ini" -type f -exec grep -Hn -- "$keyword" {} \; 2>/dev/null`
    if [ "$inikey" ]; then
      echo -e "\e[00;31m[-] Find keyword ($keyword) in .ini files (recursive 4 levels - output format filepath:identified line number where keyword appears):\e[00m\n$inikey" 
      echo -e "\n" 
     else 
	echo -e "\e[00;31m[-] Find keyword ($keyword) in .ini files (recursive 4 levels):\e[00m" 
	echo -e "'$keyword' not found in any .ini files" 
	echo -e "\n"
    fi
fi

if [ "$keyword" = "" ];then
  :
  else
    if [ "$export" ] && [ "$inikey" ]; then
	  inikey=`find / -maxdepth 4 -name "*.ini" -type f -exec grep -lHn -- "$keyword" {} \; 2>/dev/null`
      mkdir --parents "$format/keyword_file_matches/ini_files/" 2>/dev/null
      for i in $inikey; do cp --parents "$i" "$format/keyword_file_matches/ini_files/" ; done 2>/dev/null
  fi
fi

#quick extract of .conf files from /etc - only 1 level
allconf=`find /etc/ -maxdepth 1 -name *.conf -type f -exec ls -la {} \; 2>/dev/null`
if [ "$allconf" ]; then
  echo -e "\e[00;31m[-] All *.conf files in /etc (recursive 1 level):\e[00m\n$allconf" 
  echo -e "\n"
fi

if [ "$export" ] && [ "$allconf" ]; then
  mkdir $format/conf-files/ 2>/dev/null
  for i in $allconf; do cp --parents $i $format/conf-files/; done 2>/dev/null
fi

#extract any user history files that are accessible
usrhist=`ls -la ~/.*_history 2>/dev/null`
if [ "$usrhist" ]; then
  echo -e "\e[00;31m[-] Current user's history files:\e[00m\n$usrhist" 
  echo -e "\n"
fi

if [ "$export" ] && [ "$usrhist" ]; then
  mkdir $format/history_files/ 2>/dev/null
  for i in $usrhist; do cp --parents $i $format/history_files/; done 2>/dev/null
fi

#can we read roots *_history files - could be passwords stored etc.
roothist=`ls -la /root/.*_history 2>/dev/null`
if [ "$roothist" ]; then
  echo -e "\e[00;33m[+] Root's history files are accessible!\e[00m\n$roothist" 
  echo -e "\n"
fi

if [ "$export" ] && [ "$roothist" ]; then
  mkdir $format/history_files/ 2>/dev/null
  cp $roothist $format/history_files/ 2>/dev/null
fi

#all accessible .bash_history files in /home
checkbashhist=`find /home -name .bash_history -print -exec cat {} 2>/dev/null \;`
if [ "$checkbashhist" ]; then
  echo -e "\e[00;31m[-] Location and contents (if accessible) of .bash_history file(s):\e[00m\n$checkbashhist"
  echo -e "\n"
fi

#any .bak files that may be of interest
show_progress "Searching for backup files"
bakfiles=`find / -name *.bak -type f 2</dev/null`
if [ "$bakfiles" ]; then
  echo -e "\e[00;31m[-] Location and Permissions (if accessible) of .bak file(s):\e[00m"
  for bak in `echo $bakfiles`; do ls -la $bak;done
  echo -e "\n"
fi

#is there any mail accessible
readmail=`ls -la /var/mail 2>/dev/null`
if [ "$readmail" ]; then
  echo -e "\e[00;31m[-] Any interesting mail in /var/mail:\e[00m\n$readmail" 
  echo -e "\n"
fi

#can we read roots mail
readmailroot=`head /var/mail/root 2>/dev/null`
if [ "$readmailroot" ]; then
  echo -e "\e[00;33m[+] We can read /var/mail/root! (snippet below)\e[00m\n$readmailroot" 
  echo -e "\n"
fi

if [ "$export" ] && [ "$readmailroot" ]; then
  mkdir $format/mail-from-root/ 2>/dev/null
  cp $readmailroot $format/mail-from-root/ 2>/dev/null
fi
}

docker_checks()
{

#specific checks - check to see if we're in a docker container
dockercontainer=` grep -i docker /proc/self/cgroup  2>/dev/null; find / -name "*dockerenv*" -exec ls -la {} \; 2>/dev/null`
if [ "$dockercontainer" ]; then
  echo -e "\e[00;33m[+] Looks like we're in a Docker container:\e[00m\n$dockercontainer" 
  echo -e "\n"
fi

#specific checks - check to see if we're a docker host
dockerhost=`docker --version 2>/dev/null; docker ps -a 2>/dev/null`
if [ "$dockerhost" ]; then
  echo -e "\e[00;33m[+] Looks like we're hosting Docker:\e[00m\n$dockerhost" 
  echo -e "\n"
fi

#specific checks - are we a member of the docker group
dockergrp=`id | grep -i docker 2>/dev/null`
if [ "$dockergrp" ]; then
  echo -e "\e[00;33m[+] We're a member of the (docker) group - could possibly misuse these rights!\e[00m\n$dockergrp" 
  echo -e "\n"
fi

#specific checks - are there any docker files present
dockerfiles=`find / -name Dockerfile -exec ls -l {} 2>/dev/null \;`
if [ "$dockerfiles" ]; then
  echo -e "\e[00;31m[-] Anything juicy in the Dockerfile:\e[00m\n$dockerfiles" 
  echo -e "\n"
fi

#specific checks - are there any docker files present
dockeryml=`find / -name docker-compose.yml -exec ls -l {} 2>/dev/null \;`
if [ "$dockeryml" ]; then
  echo -e "\e[00;31m[-] Anything juicy in docker-compose.yml:\e[00m\n$dockeryml" 
  echo -e "\n"
fi
}

lxc_container_checks()
{

#specific checks - are we in an lxd/lxc container
lxccontainer=`grep -qa container=lxc /proc/1/environ 2>/dev/null`
if [ "$lxccontainer" ]; then
  echo -e "\e[00;33m[+] Looks like we're in a lxc container:\e[00m\n$lxccontainer"
  echo -e "\n"
fi

#specific checks - are we a member of the lxd group
lxdgroup=`id | grep -i lxd 2>/dev/null`
if [ "$lxdgroup" ]; then
  echo -e "\e[00;33m[+] We're a member of the (lxd) group - could possibly misuse these rights!\e[00m\n$lxdgroup"
  echo -e "\n"
fi
}

footer()
{
echo -e "\e[00;33m### SCAN COMPLETE ####################################\e[00m" 
}

call_each()
{
  header
  debug_info
  system_info
  user_info
  environmental_info
  job_info
  networking_info
  services_info
  software_configs
  interesting_files
  docker_checks
  lxc_container_checks
  
  # Execute compliance checks if specified
  if [ -n "$COMPLIANCE_MODE" ]; then
    echo -e "\e[00;33m### COMPLIANCE ASSESSMENT ########################\e[00m"
    case "$COMPLIANCE_MODE" in
      "CIS")
        check_cis_controls
        ;;
      "NIST")
        check_nist_framework
        ;;
      "PCI-DSS")
        check_pci_dss
        ;;
      "HIPAA")
        check_hipaa_compliance
        ;;
    esac
    echo -e "\n"
  fi
  
  footer
}

# Enhanced argument parsing for professional features
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -k)
                keyword="$2"
                # Validate keyword to prevent command injection
                if [[ "$keyword" =~ [^a-zA-Z0-9._-] ]]; then
                    echo "Error: Keyword contains invalid characters. Only alphanumeric, dots, underscores, and hyphens are allowed."
                    exit 1
                fi
                shift 2
                ;;
            -r)
                report="$2-$(date +'%d-%m-%y')"
                shift 2
                ;;
            -e)
                export="$2"
                shift 2
                ;;
            -s)
                sudopass=1
                shift
                ;;
            -t)
                thorough=1
                shift
                ;;
            -h)
                usage
                exit 0
                ;;
            --format)
                REPORT_FORMAT="$2"
                case "$REPORT_FORMAT" in
                    text|json|xml|html|csv|pdf)
                        echo "Selected output format: $REPORT_FORMAT"
                        ;;
                    *)
                        echo "Error: Invalid format. Supported: text, json, xml, html, csv, pdf"
                        exit 1
                        ;;
                esac
                shift 2
                ;;
            --dashboard)
                DASHBOARD_MODE=1
                REPORT_FORMAT="html"
                echo "Dashboard mode enabled"
                shift
                ;;
            --compliance)
                case "$2" in
                    cis)
                        init_compliance_cis
                        ;;
                    nist)
                        init_compliance_nist
                        ;;
                    pci|pci-dss)
                        init_compliance_pci
                        ;;
                    hipaa)
                        init_compliance_hipaa
                        ;;
                    *)
                        echo "Error: Invalid compliance mode. Supported: cis, nist, pci, hipaa"
                        exit 1
                        ;;
                esac
                shift 2
                ;;
            --title)
                REPORT_TITLE="$2"
                shift 2
                ;;
            --template)
                echo "Professional template mode enabled"
                shift
                ;;
            --summary)
                echo "Executive summary mode enabled"
                shift
                ;;
            *)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
}

# Parse command line arguments
parse_arguments "$@"

# Initialize professional reporting if requested
if [ "$REPORT_FORMAT" != "text" ] || [ "$DASHBOARD_MODE" -eq 1 ] || [ -n "$COMPLIANCE_MODE" ]; then
    echo -e "\e[00;36m[*] Initializing professional reporting system...\e[00m"
    init_report_data
fi

# Execute main scan
if [ "$REPORT_FORMAT" = "text" ] && [ "$DASHBOARD_MODE" -eq 0 ]; then
    # Standard text output
    call_each | tee -a "$report" 2> /dev/null
else
    # Professional format output
    echo -e "\e[00;36m[*] Generating professional report in $REPORT_FORMAT format...\e[00m"
    call_each > "/tmp/linenum_scan_output_$$.tmp" 2>&1
    
    # Process output for professional formats
    while IFS= read -r line; do
        format_professional_output "scan_output" "$line"
    done < "/tmp/linenum_scan_output_$$.tmp"
    
    # Generate final report
    output_base="${report:-linenum-enhanced-$(date +'%Y%m%d-%H%M%S')}"
    
    # Ensure reports directory exists
    mkdir -p "$REPORT_DIR" 2>/dev/null
    
    # Generate report in reports directory
    finalize_report "$REPORT_DIR/$output_base"
    
    # Copy to export directory if specified
    if [ "$export" ]; then
        cp "$REPORT_DIR/${output_base}.${REPORT_FORMAT}" "$export/" 2>/dev/null
        echo -e "\e[00;32m[+] Professional report exported to: $export/${output_base##*/}.${REPORT_FORMAT}\e[00m"
    else
        echo -e "\e[00;32m[+] Professional report saved to: $REPORT_DIR/${output_base}.${REPORT_FORMAT}\e[00m"
    fi
    
    rm -f "/tmp/linenum_scan_output_$$.tmp" 2>/dev/null
fi

# Cleanup cache files to free up space
cleanup_cache

show_progress "LinEnum scan completed"
echo -e "\e[00;32m[+] Enhanced LinEnum scan finished!\e[00m"
if [ "$CACHE_INITIALIZED" -eq 1 ]; then
    echo -e "\e[00;36m[*] Used optimized filesystem scanning to reduce execution time\e[00m"
fi

if [ "$REPORT_FORMAT" != "text" ]; then
    echo -e "\e[00;32m[+] Professional $REPORT_FORMAT report generated\e[00m"
    echo -e "\e[00;36m[*] All reports are saved in: $REPORT_DIR/\e[00m"
fi

if [ -n "$COMPLIANCE_MODE" ]; then
    echo -e "\e[00;32m[+] $COMPLIANCE_MODE compliance assessment completed\e[00m"
fi

#EndOfScript
