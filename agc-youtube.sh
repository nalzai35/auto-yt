#!/bin/bash

base_dir=$HOME/$1
FONT=$HOME/font/grobold.ttf

title_case() {
    sed 's/.*/\L&/; s/[a-z]*/\u&/g' <<<"$1"    
}

random_file_music=`ls $base_dir/music | head -$((RANDOM%$(ls $base_dir/music | wc -w)+1)) | tail -1`
random_file_keyword=`ls $base_dir/keywords | head -$((RANDOM%$(ls $base_dir/keywords | wc -w)+1)) | tail -1`

file_music=$base_dir/music/$random_file_music
file_keywords=$base_dir/keywords/$random_file_keyword

path_video=$base_dir/video
path_downloads=$base_dir/downloads
path_delete=$base_dir/delete

keyword="$(head -1 $file_keywords)"
titleCase="$(title_case "$keyword")"
output_video=$path_video/${keyword// /-}.mp4

if ! grep -Fxq "$FILENAME" $file_keywords ; then
	
	echo "/usr/local/bin/googleimagesdownload --output_directory '$base_dir/downloads' --no_directory --size large --keywords \"$keyword\" --limit $((RANDOM%10+30))" | bash -
	# echo "/usr/local/bin/googleimagesdownload --output_directory '$base_dir/downloads' --no_directory --size large --keywords \"$keyword\" --limit 3" | bash -

	echo "ls $path_downloads > $path_delete/deleteimage.txt" | bash -

	while read f; do
		echo "/usr/bin/ffmpeg -y -i '$path_downloads/$f' -vf scale=\"'if(gt(a,16/9),1280,-1)':'if(gt(a,16/9),-1,720)'\" '$path_delete/delete_$f.jpg'" | bash -
	done < $path_delete/deleteimage.txt

	a=1
	for i in $path_delete/*.jpg; do
		new=$(printf "%04d.jpg" "$a")
		mv -- "$i" "$path_delete/delete_$new"
		let a=a+1
	done

	b=1
	for f in $path_delete"/"*.jpg; do
		ff=$(printf "%04d.jpg" "$b")
		echo "/usr/bin/ffmpeg -f lavfi -y -i \"color=c=black:s=1280x720\" -i "$f" -filter_complex \"overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2\" $path_delete/delete_delete_$ff" | bash -
		let b=b+1
	done

	e=1
	for ft in $path_delete"/"delete_delete_*.jpg; do
		fff=$(printf "%04d.jpg" "$e")
		echo "/usr/bin/ffmpeg -y -i \"$ft\" -vf drawtext=\"fontfile=$FONT: fontcolor=Cyan: fontsize=48: text=\"$2\": x=10:y=10: borderw=3: bordercolor=black\" $path_delete/delete_delete_delete_$fff" | bash -
		let e=e+1
	done

	c=1
	for vz in $path_delete"/"delete_delete_delete_*.jpg; do
		vzf=$(printf "%04d.mp4" "$c")
		echo "/usr/bin/ffmpeg -y -loop 1 -t 7 -i $vz -filter_complex \" fade=t=in:st=0:d=1,fade=t=out:st=6:d=1,trim=duration=7 \" $path_delete/delete_$vzf" | bash -
		let c=c+1
	done

	for f in $path_delete"/"*.mp4; do echo "file '$f'" >> $path_delete"/"delete_video.txt; done

	echo "/usr/bin/ffmpeg -f concat -safe 0 -i $path_delete"/"delete_video.txt -i $file_music -c copy -shortest $path_delete"/"slideshow.mp4" | bash -

	echo "/usr/bin/ffmpeg -y -i $base_dir/intro.mp4 -i $path_delete"/"slideshow.mp4 -i $base_dir/outro.mp4 -filter_complex '[0:v:0][0:a:0][1:v:0][1:a:0][2:v:0][2:a:0]concat=n=3:v=1:a=1[outv][outa]' -map \"[outv]\" -map \"[outa]\" -strict -2 $output_video" | bash -

	/usr/local/bin/youtube-upload --title="$titleCase" --description="$titleCase" --tags="${titleCase// /, }" --client-secrets=$base_dir/client_secret.json --credentials-file=$base_dir/credentials.json $output_video

	rm -rf $path_downloads/*
	rm -rf $path_delete/*
	rm -rf $path_video/*

	sed -i '1d' $file_keywords

	clear

fi
