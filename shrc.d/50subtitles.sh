function extract-subtitles() {
    local src
    local dst
    src="$1"
    dst="${src}.srt"

    ffmpeg -i "$src" -map 0:s:0 -codec:s text "$dst"
}
