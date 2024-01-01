color_scheme_alacritty_change() {
    local local_config=~/.config/alacritty.local.yml
    sed -Ee 's|(colorscheme.*/alacritty/).*(.yml)|\1'$1'\2|' $local_config > $local_config.new
    mv $local_config.new $local_config
}

color_scheme_vim_change() {
    local local_config=~/.vimrc.local
    sed -Ee 's/(set background=).*/\1'$1'/' $local_config > $local_config.new
    mv $local_config.new $local_config
}

is_dark() {
    local local_config=~/.config/alacritty.local.yml
    grep -v '#' $local_config | grep -q dark
}

update_colorthemes() {
    if is_dark; then
        export BAT_THEME="Visual Studio Dark+"
        fzf_set_dark_color_scheme
    else
        export BAT_THEME="Monokai Extended Light"
        fzf_set_light_color_scheme
    fi
}


dark() {
    color_scheme_alacritty_change alacritty.dark
    color_scheme_vim_change dark
    update_colorthemes
}

light() {
    color_scheme_alacritty_change night_owlish_light
    color_scheme_vim_change light
    update_colorthemes
}

update_colorthemes
