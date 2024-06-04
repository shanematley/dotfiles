# Only enable these if we are in an interactive session
if [[ $- == *i* ]]; then
    NORMAL=$(tput sgr0)
    GREEN=$(tput setaf 2; tput bold)
    YELLOW=$(tput setaf 3)
    RED=$(tput setaf 1)

    red() {
        echo -e "$RED$*$NORMAL"
    }
    green() {
        echo -e "$GREEN$*$NORMAL"
    }
    yellow() {
        echo -e "$YELLOW$*$NORMAL"
    }

    function my_ip() # Get IP Addresses
    {
        MY_IP=$(/sbin/ifconfig eth0 | awk '/inet/ { print $2 } ' | sed -e s/addr://)
    }

    function ii()   # Get current host related info.
    {
        NETSTAT_PREFIX=""
        [[ $1 == "--sudo" ]] && NETSTAT_PREFIX="sudo"
        [[ $1 == "--dzdo" ]] && NETSTAT_PREFIX="dzdo"
        echo -e "\nYou are logged on ${RED}$HOSTNAME"
        red "\nAdditional information: " ; uname -a
        red "\nUsers logged on: " ; w -h
        red "\nCurrent date : " ; date
        red "\nMachine stats : " ; uptime
        red "\nMemory stats : " ; free
        my_ip 2>&- ;
        red "\nLocal IP Address :" ; echo "${MY_IP:-"Not connected"}"
        red "\nOpen connections : "
        [[ -z $NETSTAT_PREFIX ]] && yellow "Use --sudo to display all netstat info"
        $NETSTAT_PREFIX netstat -pan --inet;
        echo
    }

    function my_public_ip()
    {
        dig +short myip.opendns.com @resolver1.opendns.com
    }

    if command -v ipconfig >/dev/null 2>&1; then
        alias localip="ipconfig getifaddr en0"
    fi

    # Show active network interfaces
    if command -v ifconfig  >/dev/null 2>&1; then
        if command -v pcregrep >/dev/null 2>&1; then
            alias ifactive="ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'"
        fi
    fi

    # One of @janmoesen’s ProTip™s
    for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
        alias "${method}"="lwp-request -m '${method}'"
    done
fi
