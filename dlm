#!/bin/bash
set -e
set_display_preferences
file=
video_url=
function exit_error() {
	case "${1}" in
		0)
			notify-send "Could not get YouTube URL"
			;;
		1)
			notify-send "No devices found"
			;;
		2)
			notify-send 'youtube-dl failed to download' "$(xclip -o)"
			;;
		3)
			notify-send "Could not find file in directory"
			;;
		4)
			notify-send "kdeconnect could not send file"
			;;
	esac
	exit 1
}
mkdir -p ~/Music
cd ~/Music
video_url="$(xclip -o | awk -F"=|&" '{print $2}')"
[[ -z "${video_url}" ]] && exit_error 0
mapfile -t dev_ids < <(kdeconnect-cli -l | awk '/reachable/{print $3}')
[[ ${#dev_ids[@]} -eq 0 ]] && exit_error 1
youtube-dl -x --audio-format vorbis "https://www.youtube.com/watch?v=${video_url}" || exit_error 2
file="$(ls ./*"${video_url}."*)" || exit_error 3
for dev_id in "${dev_ids[@]}"; do
	kdeconnect-cli -d "${dev_id}" --share "${file}" || exit_error 4
	notify-send 'Success' "Sent ${file} \\nto ${dev_id}"
done
