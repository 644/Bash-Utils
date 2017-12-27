#!/bin/bash
file=
video_url=
env_reference_process="$(pgrep -u $USER xfce4-session || pgrep -u $USER ciannamon-session || pgrep -u $USER gnome-session || pgrep -u $USER gnome-shell || pgrep -u $USER kdeinit)"
export DBUS_SESSION_BUS_ADDRESS="$(cat /proc/"${env_reference_process}"/environ | grep -z ^DBUS_SESSION_BUS_ADDRESS= | sed s/DBUS_SESSION_BUS_ADDRESS=//)"
export DISPLAY="$(cat /proc/"${env_reference_process}"/environ | grep -z ^DISPLAY= | sed s/DISPLAY=//)"
function exit_error() {
	case $1 in
		0)
			notify-send ~/"Music does not exist"
			;;
		1)
			notify-send "Could not get YouTube URL"
			;;
		2)
			notify-send "youtube-dl could not download file"
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
cd ~/Music || exit_error 0
video_url="$(xclip -o | awk -F"=|&" '{print $2}')"
[[ -z "${video_url}" ]] && exit_error 1
youtube-dl -x --audio-format vorbis "https://www.youtube.com/watch?v=${video_url}" || exit_error 2
file="$(ls ./*"${video_url}."*)" || exit_error 3
kdeconnect-cli -d ID --share "${file}" || exit_error 4
notify-send "Sent ${file}"
