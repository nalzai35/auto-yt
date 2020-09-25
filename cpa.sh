#!/bin/bash

function yellow_color()
{
    echo $(tput setaf 3)$@$(tput sgr0)
}

for (( i = 0; i < $1; i++ )); do
	NEW_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

	yellow_color "===========    MULAI   ==============="
	yellow_color "======== Regenerate Metadata ========="
	yellow_color "======================================"

	ffmpeg -i video-cpa.mp4 -map_metadata -1 -metadata title="$NEW_UUID" -c copy video-cpa/$NEW_UUID.mp4

	yellow_color "======================================"
	yellow_color "============ Upload Video ============"
	yellow_color "======================================"

	youtube-upload --title="$NEW_UUID" --description="$NEW_UUID" --privacy="unlisted" --client-secrets=client_secret.json  video-cpa/$NEW_UUID.mp4

	yellow_color "======================================"
	yellow_color "============ Hapus Video ============="
	yellow_color "======================================"

	rm -rf video-cpa/*

done
