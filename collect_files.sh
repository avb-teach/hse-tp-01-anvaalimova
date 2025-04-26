#!/bin/bash

die() {
    echo "$1"
    exit 1
}

[[ $# -lt 2 ]] && die "Usage: $0 <in_dir> <out_dir> [--max_depth N]"

in="$1"
out="$2"
depth=""

shift 2
while [[ $# -gt 0 ]]; do
    case "$1" in
        --max_depth)
            depth="$2"
            shift 2
            ;;
        *)
            die "Unknown parameter: $1"
            ;;
    esac
done

[[ ! -d "$in" ]] && die "Input dir not found!"
mkdir -p "$out"

lst=$(find "$in" -type f)

while IFS= read -r f; do
    rel="${f#$in/}"
    d=$(dirname "$rel")
    n=$(basename "$rel")

    if [[ -n "$depth" ]]; then
        IFS='/' read -r -a p <<< "$d"
        pc=${#p[@]}
        if (( pc >= depth )); then
            d=$(IFS='/'; echo "${p[*]:0:$((depth-1))}")
            rel="$d/$n"
        fi
    fi

    dst="$out/$rel"
    mkdir -p "$(dirname "$dst")"

    if [[ ! -e "$dst" ]]; then
        cp "$f" "$dst"
    else
        b="${dst%.*}"
        ext="${dst##*.}"
        [[ "$b" == "$ext" ]] && ext="" || ext=".$ext"
        i=1
        while [[ -e "${b}_${i}${ext}" ]]; do
            ((i++))
        done
        cp "$f" "${b}_${i}${ext}"
    fi

done <<< "$lst"
