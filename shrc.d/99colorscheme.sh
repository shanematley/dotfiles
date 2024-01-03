color_scheme_alacritty_change() {
    local local_config=~/.config/alacritty.local.yml
    if [[ ! -e $local_config ]]; then
        echo "No local alacritty config present. Adding"
        cat <<-EOF > $local_config
	import:
	  - &colorscheme ~/.config/alacritty/alacritty.dark.yml
	EOF
    fi
    sed -Ee 's|(colorscheme.*/alacritty/).*(.yml)|\1'$1'\2|' $local_config > $local_config.new
    mv $local_config.new $local_config
}

color_scheme_vim_change() {
    local local_config=~/.vimrc.local
    if [[ ! -e $local_config ]]; then
        echo "No local vimrc config present. Adding"
        cat <<-EOF > $local_config
	set background=dark
	EOF
    fi
    sed -Ee 's/(set background=).*/\1'$1'/' $local_config > $local_config.new
    mv $local_config.new $local_config
}

color_scheme_tmux_change() {
    local local_config=~/.tmux.conf.local
    if [[ ! -e $local_config ]]; then
        echo "No local tmux config present. Adding"
        echo 'source-file "~/.tmux/tmux-dark.conf"' > $local_config
    fi
    sed -Ee 's#^(source-file "~/.tmux/tmux-)(dark|light)(.conf")#\1'$1'\3#' $local_config > $local_config.new
    mv $local_config.new $local_config
    tmux source-file ~/.tmux.conf
}

fzf_set_dark_color_scheme() {
    export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS_BASE} --color 'fg:#bbccdd,fg+:#ddeeff,bg:#334455,preview-bg:#223344,border:#778899'"
}

fzf_set_light_color_scheme() {
    export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS_BASE}
        --color=fg:#4d4d4c,bg:#eeeeee,hl:#d7005f
        --color=fg+:#4d4d4c,bg+:#e8e8e8,hl+:#d7005f
        --color=info:#4271ae,prompt:#8959a8,pointer:#d7005f
        --color=marker:#4271ae,spinner:#4271ae,header:#4271ae"
}

is_dark() {
    local local_config=~/.config/alacritty.local.yml
    [[ ! -e $local_config ]] || grep -v '#' $local_config | grep -q dark
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
    color_scheme_tmux_change dark
    update_colorthemes
}

light() {
    color_scheme_alacritty_change night_owlish_light
    color_scheme_vim_change light
    color_scheme_tmux_change light
    update_colorthemes
}

update_colorthemes
