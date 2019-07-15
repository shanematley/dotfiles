nsdate() {
    local st=$1
    local nst=0
    #1521740309.720
    # 10 digits for seconds
    local digits=$(echo -n $1|wc -c)
    if [[ $digits -gt 10 ]]; then
        local div=$(( 10 ** ($digits - 10) ))
        st=$(( $1 / $div ))
        nst=$(( $1 % $div ))
    fi
    if [[ $(uname -s) == Darwin ]]; then
        datecmd=gdate
    else
        datecmd=date
    fi

    if ! command -v $datecmd >/dev/null 2>&1; then
        >&2 echo "Missing $datecmd. Please install $datecmd."
        return
    fi

    printf "%s.%09d\n" "$($datecmd -d @${st} +"%Y-%m-%d %H:%M:%S")" "${nst}"
}

alias jpdate="TZ='Asia/Tokyo' nsdate"
alias hkdate="TZ='Asia/Hong_Kong' nsdate"
alias audate="TZ='Australia/Sydney' nsdate"
alias utdate="TZ='UTC' nsdate"
