#!/bin/bash
# Author : amr
# OS : Debian 12 x86_64
# Date : 03-Sep-2024
# Project Name : domain_investigator


# License: MIT License
# 
# Copyright (c) 2024 Amro Alasmer
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# 

script_path="$(dirname "`realpath $0`")"
source "$script_path/lib.sh"
tmp=""
getcrt(){
    if [ $# -lt 1 ]; then
        err "Few arguments to getcrt() function!" 3 1 24; return $?
    elif [ $# -gt 1 ]; then
        err "Many arguments to getcrt() function!" 3 1 25; return $?
    fi
    echo  "$1"  | awk -F ': ' '$0 ~ /Creation Date/  {print  $2}' | cut -d'T' -f1 | head -n 1
}

getexp(){
    if [ $# -lt 1 ]; then
        err "Few arguments to getexp() function!" 3 1 26; return $?
    elif [ $# -gt 1 ]; then
        err "Many arguments to getexp() function!" 3 1 27; return $?
    fi
    echo "$1"  | awk -F ': ' '$0 ~ /Registry Expiry Date/  {print  $2}' | cut -d'T' -f1 | head -n 1
}

getorg(){
    if [ $# -lt 1 ]; then
        err "Few arguments to getorg() function!" 3 1 28; return $?
    elif [ $# -gt 1 ]; then
        err "Many arguments to getorg() function!" 3 1 29; return $?
    fi
    echo  "$1"  | awk -F ': ' '$0 ~ /Registrant Organization/  {print  $2}' |  head -n 1
}

getreg(){
    if [ $# -lt 1 ]; then
        err "Few arguments to getreg() function!" 3 1 28; return $?
    elif [ $# -gt 1 ]; then
        err "Many arguments to getreg() function!" 3 1 29; return $?
    fi
    whois "$1" 2> /dev/null 1> "$tmp"
    echo "\"$1\",\"$(getorg "$(cat $tmp)")\",\"$(getcrt "$(cat $tmp)")\",\"$(getexp "$(cat $tmp)")\""  

}


show_help(){
    echo "Usage: $0 "
}


if [ $# -lt 1 ]; then
    show_help; exit 1
fi




convert_to_arrayln_O "$1"

tmp=`mktemp`
tmpdir="$(mktemp -d)"
for i in "${list[@]}"; do
    getreg  "$i" > "$tmpdir/$i" || err "getreg error" 3 0 66 & 
    sleep 0.2
done
wait
cat "$tmpdir/"* | sort -k 1,1 -t ','  
rm -r "$tmpdir"

