#!/bin/bash
#
# This Script is Inspired from @bing0o's domains.sh script & I copied and made changes to work effectively

#Colours
bold="\e[1m"
Underlined="\e[4m"
red="\e[31m"
green="\e[32m"
blue="\e[34m"
end="\e[0m"
VERSION="SubDomz_v1.0"



    echo -e "$blue${bold}     _   __          _____       __             $end"
    echo -e "$blue${bold}    / | / /__  _  __/ ___/__  __/ /_  _____     $end"
    echo -e "$blue${bold}   /  |/ / _ \| |/_/\__ \/ / / / __ \/ ___/     $end"
echo -e "$blue${bold}   / /|  /  __/>  < ___/ / /_/ / /_/ (__  )      $end"
  echo -e "$blue${bold}   /_/ |_/\___/_/|_|/____/\____/_____/____/       $end"echo -e "$end"
echo -e "$blue${bold}        All in One Subdomain Enumeration Tool         $end"
echo -e "$blue${bold}             Made with${end} ${red}${bold}<3${end} ${blue}${bold}by V1per             $end"
echo -e "$end"

PRG=${0##*/}

#Tools
Usage(){
    while read -r line; do
        printf "%b\n" "$line"
    done <<-EOF
    \r
    \r ${bold}Options${end}:
    \r    -d ==> Domain to enumerate
    \r    -o ==> Output file to save the final results
    \r    -h ==> Display this help message and exit
    \r    -v ==> Display the version and exit

EOF
    exit 1
}

# Variables
# Add your api keys, tokens here
subfinder=~/.config/subfinder/provider-config.yaml
amass=~/.config/amass/config.ini
wordlist=Wordlist/dns.txt
GITHUB_TOKEN="TOKEN_HERE"
GITLAB_TOKEN="TOKEN_HERE"
SHODAN_APIKEY="API_KEY_HERE"
CENSYS_ID="ID_HERE"
CENSYS_SECRET="SECRET_HERE"
CHAOS_APIKEY="API_KEY_HERE"


RunEnumeration() {
    local func_name="$1"
    echo -e "\n${bold}Running $func_name...${end}\n"
}

# Tools
Subfinder() {
	RunEnumeration "Subfinder"
    subfinder -all -silent -d "$domain" -pc "$subfinder" -silent | anew "$domain"-subs.txt
}

Assetfinder() {
	RunEnumeration "Assetfinder"
    assetfinder --subs-only "$domain" | anew "$domain"-subs.txt
}

Chaos() {
	RunEnumeration "Chaos"
    chaos -silent -d "$domain" -key "$CHAOS_APIKEY" -silent | anew "$domain"-subs.txt
}

Shuffledns() {
	RunEnumeration "Shuffledns"
    shuffledns -silent -d "$domain" -w "$wordlist" -r "$resolvers" -silent | anew "$domain"-subs.txt
}

Findomain() {
RunEnumeration "Findomain"
	findomain --target $domain --quiet | anew "$domain"-subs.txt
}

Amass_Passive() {
	RunEnumeration "Amass Passive"
	amass enum -d $domain -config $amass | anew "$domain"-subs.txt
}

Gau() {
	RunEnumeration "Gau"
	gau --subs $domain | unfurl -u domains | anew "$domain"-subs.txt 
}

Waybackurls() {
	RunEnumeration "Waybackurls"
	waybackurls $domain |  unfurl -u domains | anew "$domain"-subs.txt
}

Github-Subdomains() {
	RunEnumeration "Github-Subdomains"
	github-subdomains -d $domain -t $GITHUB_TOKEN | unfurl domains | anew "$domain"-subs.txt 
}

Gitlab-Subdomains() {
	RunEnumeration "Gitlab-Subdomains"
	gitlab-subdomains -d $domain -t $GITLAB_TOKEN | unfurl domains | anew "$domain"-subs.txt 
}

Crobat() {
	RunEnumeration "Crobat"
	crobat -s $domain | anew "$domain"-subs.txt
}

Cero() {
	RunEnumeration "Cero"
	cero $domain | anew subdomz-$domain.txt
}

#Online_Services
Archive() {
	RunEnumeration "Archive"
	curl -sk "http://web.archive.org/cdx/search/cdx?url=*.$domain&output=txt&fl=original&collapse=urlkey&page=" | awk -F/ '{gsub(/:.*/, "", $3); print $3}' | sort -u | anew "$domain"-subs.txt 
}

BufferOver() {
	RunEnumeration "BufferOver"
	curl -s "https://dns.bufferover.run/dns?q=.$domain" | grep $domain | awk -F, '{gsub("\"", "", $2); print $2}' | anew "$domain"-subs.txt
}

Crt() {
	RunEnumeration "Crt"
	curl -sk "https://crt.sh/?q=%.$domain&output=json" | tr ',' '\n' | awk -F'"' '/name_value/ {gsub(/\*\./, "", $4); gsub(/\\n/,"\n",$4);print $4}' | anew "$domain"-subs.txt
}

Riddler() {
	RunEnumeration "Riddler"
	curl -sk "https://riddler.io/search/exportcsv?q=pld:$domain" | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | anew "$domain"-subs.txt
}

CertSpotter() {
	RunEnumeration "CertSpotter"
	curl -sk "https://api.certspotter.com/v1/issuances?domain=$domain&include_subdomains=true&expand=dns_names" | jq .[].dns_names | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | anew "$domain"-subs.txt
}

JLDC() {
	RunEnumeration "JLDC"
	curl -sk "https://jldc.me/anubis/subdomains/$domain" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | anew "$domain"-subs.txt
}

nMap() {
	RunEnumeration "nmap"
	nmap --script hostmap-crtsh.nse $domain | unfurl domains | anew "$domain"-subs.txt
}

HackerTarget() {
	RunEnumeration "HackerTarget"
	curl -sk "https://api.hackertarget.com/hostsearch/?q=$domain" | unfurl domains | anew "$domain"-subs.txt
}

ThreatCrowd() {
	RunEnumeration "ThreatCrowd"
	curl -sk "https://www.threatcrowd.org/searchApi/v2/domain/report/?domain=$domain" | jq -r '.subdomains' | grep -o "\w.*$domain" | anew "$domain"-subs.txt
}

Anubis() {
	RunEnumeration "Anubis"
	curl -sk "https://jldc.me/anubis/subdomains/$domain" | jq -r '.' | grep -o "\w.*$domain" | anew "$domain"-subs.txt
}

ThreatMiner() {
	RunEnumeration "ThreatMiner"
	curl -sk "https://api.threatminer.org/v2/domain.php?q=$domain&rt=5" | jq -r '.results[]' |grep -o "\w.*$domain" | sort -u   | anew "$domain"-subs.txt
}

Omnisint() {
	RunEnumeration "Omnisint"
	curl -sk "https://sonar.omnisint.io/subdomains/$domain" | cut -d "[" -f1 | cut -d "]" -f1 | cut -d "\"" -f 2 | sort -u | anew "$domain"-subs.txt
}

		
# Output
OUT() {
    local date=$(date +'%Y-%m-%d')
    local out="$domain-$date.txt"
    
    if [ -n "$1" ]; then
        out="$domain-$1.txt"
    fi
}

# Main
Main() {
    if [ -z "$domain" ]; then
        echo -e "${red}[-] Argument -d is required!$end"
        Usage
    fi

    Subfinder
    Assetfinder
    Chaos
    Shuffledns
	Findomain
	Amass_Passive
	Gau
	Waybackurls
	Github-Subdomains
	Gitlab-Subdomains
	Crobat
	Cero
	Archive
	BufferOver
	Crt
	Riddler
	CertSpotter
	JLDC
	nMap
	HackerTarget
	ThreatCrowd
	Anubis
	ThreatMiner
	Omnisint

    OUT "$out"  # Call OUT function with the output file name
}

# Parse command-line arguments
while [ -n "$1" ]; do
    case $1 in
        -d)
            domain="$2"
            shift ;;
        -o)
            out="$2"
            shift ;;
        -h | --help)
            Usage ;;
        -v)
            echo "Version: $VERSION"
            exit 0 ;;
        *)
            echo "[-] Unknown Option: $1"
            Usage ;;
    esac
    shift
done

Main
