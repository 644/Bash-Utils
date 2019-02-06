#!/usr/bin/env -S bash -euo pipefail

# Sets display variables for notify-send
# User might vary depending on machine, check /etc/passwd
DBUS_SESSION_BUS_ADDRESS='unix:path=/run/user/1000/bus'
DISPLAY=':0'

# Below provides some information when the script exits without completing successfully
function exit_error(){
	case "${1}" in
		0)
			notify-send "${HOME}/Music directory does not exist or cannot be created"
			;;
		1)
			notify-send 'A YouTube URL could not be found in the history'
			;;
		2)
			notify-send 'No kdeconnect devices could be found'
			;;
		3)
			notify-send 'youtube-dl failed to download'
			;;
		4)
			notify-send 'Could not find file in directory'
			;;
		5)
			notify-send 'kdeconnect could not send file'
			;;
        99)
			notify-send 'Required dependencies not found in $PATH' 'Dependencies are kdeconnect, xclip, youtube-dl'
			;;
        127)
            notify-send 'Unable to copy/delete the history database. Permission error?'
            ;;
	esac
	exit 1
}

# Checks for a list of commands to see if they're installed as required by the script
# If any of the commands aren't found it will exit
command -v notify-send &>/dev/null || echo 'notify-send is not in $PATH (provides error reporting)'
command -v kdeconnect-cli &>/dev/null || exit_error 99
command -v xclip &>/dev/null || exit_error 99
command -v youtube-dl &>/dev/null || exit_error 99
command -v sqlite3 &>/dev/null || exit_error 99

# Create the Music directory in $HOME if it does not already exist and changes the current working directory to it
mkdir -p "${HOME}/Music" || exit_error 0
cd "${HOME}/Music" || exit_error 0

# Searches for a Youtube URL in the firefox cache files
while read -r cache_file; do
    video_url="$(grep -aoE 'https://www.youtube.com/watch\?v=[a-zA-Z0-9_-]{11}' "${cache_file}" | grep -oP '[\w-]{11}')" && break
    true
done < <(find "${HOME}"/.cache/mozilla/firefox/*.default/cache2/entries/ -type f -printf '%T@ %p\n' | sort -r | cut -d' ' -f2)

# If no URL was found in the cache files, it will use Firefox's history database to find one
if [[ -z "${video_url}" ]]; then
    hist_db="$(find "${HOME}/.mozilla/firefox/" -name "places.sqlite")"
    cp "${hist_db}" places-copy.sqlite || exit_error 127

    hist_query="select p.url from moz_historyvisits as h, moz_places as p where substr(h.visit_date, 0, 11) >= strftime('%s', date('now')) and p.id == h.place_id order by h.visit_date;"
    video_url="$(sqlite3 places-copy.sqlite "${hist_query}" | grep 'youtube.com' | awk -F'=|&' 'BEGIN {err=1} length($2) == 11 {err=0; print $2} END {exit err}' | tail -1)" || exit_error 1
    
    rm places-copy.sqlite
fi

# Adds a list of connected and reachable devices listed by kdeconnect to an array
# If none are found it exits
mapfile -t dev_ids < <(kdeconnect-cli -l | awk '/reachable/{print $3}')
(( ${#dev_ids[@]} == 0 )) && exit_error 2

# Downloads the video, converts to vorbis (.ogg) and attempts to find the downloaded vorbis file
youtube-dl -x --audio-format vorbis "https://www.youtube.com/watch?v=${video_url}" &>/dev/null || exit_error 3
file="$(readlink -f <<< ls ./*"${video_url}."*)" || exit_error 4

# Attempts to send the converted file to all kdeconnect devices
for dev_id in "${dev_ids[@]}"; do
	kdeconnect-cli -d "${dev_id}" --share "${file}" &>/dev/null || exit_error 5
	notify-send 'Success' "Sent ${file}\\nto ${dev_id}"
done
