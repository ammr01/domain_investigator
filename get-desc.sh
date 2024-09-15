#!/bin/bash
# Author : amr
# OS : Debian 12 x86_64
# Date : 03-Sep-2024
# Project Name : domain_investigator


script_path="$(dirname "`realpath $0`")"
source "$script_path/lib.sh"


if [ $# -lt 1 ]; then
    show_help; exit 1
fi

convert_to_arrayln_O "$1"

tmpdir="$(mktemp -d)"
tmpdir2="/tmp/domain_investigator_html"
mkdir  $tmpdir2 2>/dev/null 
for domain in "${list[@]}"; do
    if [ ! -z "$domain" ]; then
        echo "\"$domain\",\"$(timeout 2>/dev/null 100s curl  "https://$domain" -L -H "Host: $domain" -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.6478.127 Safari/537.36'  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Ch-Ua: "Not/A)Brand";v="8", "Chromium";v="126"' -H 'Sec-Ch-Ua-Platform: "Linux"' -H 'Accept-Language: en-US' -H 'Accept-Encoding: gzip, deflate, br' -H 'Priority: u=0, i'   --compressed 2>/dev/null  | tee "$tmpdir2/$domain" | tr -d '\n' | perl -nle "print \"\$1\" if /(?:name=\"description\"|property=\"og:description\")\\s*content=[\"']([^\"']*)[\"'].*(?:\\/)*>*/")\""  | tee "$tmpdir/$domain"  &
        sleep 0.1
    fi
done

wait
rm -r "$tmpdir"






