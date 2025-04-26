#!/bin/bash

e() {
    echo "$1"
    exit 1
}

[[ $# -lt 2 ]] && e "Usage: $0 <src> <dst> [--max_depth N]"

src="$1"
dst="$2"
depth=""

shift 2

while [[ $# -gt 0 ]]; do
    case "$1" in
        --max_depth)
            depth="$2"
            shift 2
            ;;
        *)
            e "Unknown parameter: $1"
            ;;
    esac
done

[[ ! -d "$src" ]] && e "Source not found!"
mkdir -p "$dst"

files=$(find "$src" -type f)

while IFS= read -r f; do
    r="${f#$src/}"
    d=$(dirname "$r")
    n=$(basename "$r")

    if [[ -n "$depth" ]]; then
        IFS='/' read -r -a p <<< "$d"
        l=${#p[@]}
        if (( l >= depth )); then
            d=$(IFS='/'; echo "${p[*]:0:$((depth-1))}")
            r="$d/$n"
        fi
    fi

    t="$dst/$r"
    mkdir -p "$(dirname "$t")"

    if [[ ! -e "$t" ]]; then
        cp "$f" "$t"
    else
        b="${t%.*}"
        e="${t##*.}"
        [[ "$b" == "$e" ]] && e="" || e=".$e"
        i=1
        while [[ -e "${b}_${i}${e}" ]]; do
            ((i++))
        done
        cp "$f" "${b}_${i}${e}"
    fi
done <<< "$files"

