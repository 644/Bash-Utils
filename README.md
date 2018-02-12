# Bash Utils
Below you will find a description, example and dependency list for all scripts in this repository.

## btt
Converts selected binary text to ascii and displays with notify-send.

##### Dependencies
- XFCE OR Gnome OR Cinnamon OR KDE
- xsel
- notify-send

##### Usage
Select binary text and run the script. It's best suited to a hotkey.

## cdomain
Adds domain to vultr instance and optionally sets proper security headers. The DNS must be pointed towards your vultr instance beforehand.

##### Dependencies
- nginx
- jq
- certbot
- vultr.com instance

##### Usage
```
# cdomain -s -d mywebsite.com
```
Run with root privileges.

## dlm
Downloads music from YouTube using youtube-dl and sends the file directly to your phone using kdeconnect. Works best with a hotkey.

##### Dependencies
- youtube-dl
- kdeconnect
- notify-send
- set_display_preferences

##### Usage
Select YouTube URL and run the script.

## format_usb
Quickly formats a USB and adds an ext4 partition. Optionally, the device can be shredded to securely erase data.

##### Dependencies
- shred

##### Usage
```
# format_usb -w
```
Run with root privileges.

## network_namespace
Automatically creates WiFi-based network namespaces. This is not for ethernet devices.

##### Dependencies
- iw
- iproute2
- netctl
- wpa_supplicant
- wpa_passphrase

##### Usage
This script takes no arguments.
Run with root privileges.

## network_test
Continuously retry pinging 8.8.8.8 until a packet is received.

##### Dependencies
- ping

##### Usage
This script takes no arguments.

## word_count
Count the amount of lines, characters and words in selected text. Works best with a hotkey.

##### Dependencies
- XFCE OR Gnome OR Cinnamon OR KDE
- xsel
- notify-send

##### Usage
Select text and run the script.
