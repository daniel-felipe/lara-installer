red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
none=$(tput sgr0)

check_last_task() {
    if [ $? -eq 0 ]; then
        printf "[${green}OK${none}]\n"
    else
        printf "[${red}ERROR${none}]\n"
    fi
}
