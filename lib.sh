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
list=()

error_flag=0
default_error_code=1

err(){
    # err [message] <type> <isexit> <exit/return code>
    #
    #   I- message (mandatory): text to print
    #
    #  II- type (optional "default is (1/note)"): 
    #      1 : note (Default)
    #      2 : warning
    #      3 : error: the text is printed into stderr, and it needs two more arguments
    #
    #
    # III- isexit (optional "default is 1"):
    #      0 : exit after printing 
    #          (set exit code in the next
    #           arg, default error code
    #           is used if error code
    #           is not set).
    #      1 : return a status code after printing 
    #          (set return code in the next
    #           arg, default return code
    #           is used if return code
    #           is not set).
    #      2 : do not exit or return
    #
    #  IV- error/return code : 
    #      to set error/return code, must be numeric, 
    #      if not numeric or not set, the default 
    #      value will be used. 
    
    local text="$1"
    local type=${2-1}
    local isexit=${3-1}
    local error_code=${4-$default_error_code}
    local typestr=""
    local fd=1
    
    if ! [[ "$type" =~ ^[0-9]+$ ]]; then
        type=1
    fi

    if ! [[ "$isexit" =~ ^[0-9]+$ ]]; then
        isexit=1
    fi

    if ! [[ "$error_code" =~ ^[0-9]+$ ]]; then
        error_code=$default_error_code
    fi
    case $type in 
    1)
        typestr="NOTE"
        fd=1 #stdout
    ;;
    2)
        typestr="WARNING"
        fd=1 #stdout
    ;; 
    3)
        typestr="ERROR"
        fd=2 #stderr
    ;;
    *)
        typestr="NOTE"
        fd=1 #stdout
    ;;
    esac
    
    if [ $error_flag -eq 0 ]; then 
        >&$fd echo -e "[$typestr:START]\n$text\n[$typestr:END]"
        if [ "$isexit" -eq 0 ]; then
            exit "$error_code"
        elif [ "$isexit" -eq 1 ]; then
            return "$error_code"
        fi

    fi
    
}


convert_to_arrayln_O() {
    # Convert to arrayln OPTIMIZED
    # Converts strings to array, each element is a line 
    # Stores the output in the global array $list
    # Returns 0 if no errors occurred
    # $1 is the string
    
    local input="$1"
    list=()

    # Temporarily change IFS to newline to handle spaces correctly
    while IFS=$'\n' read -r line; do
        list+=( "$line" )
    done <<< "$input"

    return 0
}


convert_to_str() {
    # Convert array to str
    # each element is a line 
    # prints the output into stdout 
    # Returns 0 if no errors occurred
    # $1 is the list
    local array1=("${!1}") 
    
    for i in "${array1[@]}"; do
        echo -e "$i"
    done

    return 0
}

format(){
    if [ $# -lt 1 ]; then
        err "Few arguments to format() function!" 3 1 22; return $?
    elif [ $# -gt 1 ]; then
        err "Many arguments to format() function!" 3 1 23; return $?
    fi

    echo -e "\"Domain Name\",\"Registrant Organization\",\"Creation Date\",\"Registry Expiry Date\",\"Description\"" 2>/dev/null > "$output_file" || err "cannot create or write into file: $output_file" 3 1 24; return $?


}



merge(){
    if [ $# -lt 2 ]; then
        err "Few arguments to merge() function!" 3 1 88; return $?
    elif [ $# -gt 2 ]; then
        err "Many arguments to merge() function!" 3 1 89; return $?
    fi

    file1="$1"
    file2="$2"

    if [ ! -f "$file1" ] ; then
        err "file $file1 is not found!" 3 1 90; return $?
    elif [ ! -f "$file2" ] ; then
        err "file $file2 is not found!" 3 1 91; return $?
    fi 
    sqlcommand="CREATE TABLE table1 (domain_name TEXT, description TEXT);
CREATE TABLE table2 (domain_name TEXT, owner_org TEXT, register_time TEXT, expired_time TEXT);
.mode csv
.import $file1 table1
.import $file2 table2
SELECT table2.domain_name, table2.owner_org, table2.register_time, table2.expired_time, table1.description
FROM table2
LEFT JOIN table1 ON table2.domain_name = table1.domain_name;
.quit"
    tmpdb=`mktemp --suffix=.db`
    sqlite3 "$tmpdb" <<<"$sqlcommand" 2> /dev/null|| err "sqlite3 error" 3 1 $?; return $?
    rm $tmpdb
    return 0
}


