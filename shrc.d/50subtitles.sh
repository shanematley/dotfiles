function extract-subtitles() {
    local src
    local dst_srt
    local dst_md
    src="$1"
    dst_srt="${src}.srt"
    dst_md="${src}.md"

    ffmpeg -i "$src" -map 0:s:0 -codec:s text "$dst_srt"
    # Remote timestamps and place in a different file
    echo -n "# ${src} Subtitles\n\nExtracted: $(date)\n\n" > "$dst_md"
    perl -0007pe 's/^\n*\d+\n[\d:,]+ --> [\d:,]+\n//gm' "$dst_srt" >> "$dst_md"
}
