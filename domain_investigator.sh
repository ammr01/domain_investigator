#!/bin/bash
# Author : amr
# OS : Debian 12 x86_64
# Date : 02-Sep-2024
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
tmp=()
domains=()


which dos2unix 1>/dev/null || err "please install dos2unix tool before use this script, for debian based system use \"sudo apt install dos2unix\"" 3 0 38
show_help(){
    echo "Usage: $0 "
}


if [ $# -lt 1 ]; then
    show_help; exit 1
fi

while [ $# -gt 0 ]; do
    case $1 in 
    -h|--help)
        show_help; exit 0
    ;;
    
    
    -i|--input-file)
        if [ -n "$2" ]; then        
            input_file="$(realpath "$2" )"
            if [ ! -f "$input_file" ]; then
                err "input file is not found : $input_file" 3 0 15
            fi
            shift 2
            tmp0=`mktemp`
            dos2unix "$input_file" 1>/dev/null 2>/dev/null || err "dos2unix Error!" 3 0 28
            awk '$0 ~ /([a-z0-9\-]+\.)+[a-z]+/ {print $0}' "$input_file" > $tmp0
            convert_to_arrayln_O "$(cat "$tmp0")" || err "cannot convert file $$tmp0 into list." 3 0 20
            tmp=("${tmp[@]}" "${list[@]}")
        else
            err "-i option requires argument." 3 0 8
        fi
    ;;
    -o|--output-file)
        if [ -n "$2" ]; then        
            output_file="$(realpath "$2" )"
            
            if [ ! -f "$output_file" ] || 
            [ ! -s "$output_file"  ] ; then
                format "$output_file" ||   err "cannot create or write into file: $output_file, staus code: $?" 2 2 0   
            fi
            shift 2
        else
            err "-o option requires argument." 3 0 9
        fi
    ;;

    *)
        domains+=("$1")
        shift
    ;;
    esac
done

domains=("${domains[@]}" "${tmp[@]}")
domains_str="$( convert_to_str domains[@] )"




tmp1=`mktemp --suffix=.csv`
tmp2=`mktemp --suffix=.csv`

"$script_path/get-desc.sh" "$domains_str" > $tmp1 
"$script_path/get-reg.sh" "$domains_str" > $tmp2 


merged_output="$(merge "$tmp1" "$tmp2" )"


echo -e "\"Domain Name\",\"Description\",\"Registrant Organization\",\"Creation Date\",\"Registry Expiry Date\""
if [ ! -z "$output_file" ]; then 
    echo "$merged_output" | tee -a "$output_file" 
else
    echo "$merged_output" 
fi 







