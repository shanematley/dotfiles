#!/bin/zsh

resize_retina_only() {
    local sips_output
    local dpi_height=0
    local dpi_width=0
    local pixel_width=0
    for f in "$@"; do
        sips_output="$(sips -g dpiHeight -g dpiWidth -g pixelWidth "$f")"
        if [[ "$sips_output" =~ "dpiHeight: ([0-9.]+)" ]]; then
            dpi_height="$match[1]"
        fi
        if [[ "$sips_output" =~ "dpiWidth: ([0-9.]+)" ]]; then
            dpi_width="$match[1]"
        fi
        if [[ "$sips_output" =~ "pixelWidth: ([0-9.]+)" ]]; then
            pixel_width="$match[1]"
        fi

        if (( $dpi_height == 144 && $dpi_width == 144 && $pixel_width != 0 )); then
            echo "File $f:"
            echo "  dpi height=$dpi_height"
            echo "  dpi width=$dpi_width"
            echo "  pixel_width=$pixel_width"

            integer new_dpi_height=$(( $dpi_height / 2 ))
            integer new_dpi_width=$(( $dpi_width / 2 ))
            integer new_pixel_width=$(( $pixel_width / 2 ))

            echo "  new dpi height=$new_dpi_height"
            echo "  new dpi width=$new_dpi_width"
            echo "  new pixel_width=$new_pixel_width"

            sips -s dpiHeight $new_dpi_height -s dpiWidth $new_dpi_width --resampleWidth $new_pixel_width "$f"
            /usr/local/bin/pngquant --ext .png --force --skip-if-larger -- "$f"
            # Yes, this looks like duplication, but it's because pngquant seems to mess the DPI up
            sips -s dpiHeight $new_dpi_height -s dpiWidth $new_dpi_width "$f"
        fi
    done
}

resize_retina_only "$@"

