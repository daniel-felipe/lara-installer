#!/bin/bash
# Copyright (c) 2023 Daniel Fagundes <daniell.felipe.2017@gmail.com>
#
# This is a bash script that creates new laravel projects on Linux distros.
#
# The script triggers the laravel installer and creates a fresh laravel installation
# with some common packages as Phpstan, Pest, Sail and more.
# 
# Example:
# ./installer.sh project_name

source ./setup/inc/helpers.sh
echo $green" _                   _           _        _ _           "
echo '| | __ _ _ __ __ _  (_)_ __  ___| |_ __ _| | | ___ _ __ '
echo "| |/ _\` | '__/ _\` | | | '_ \/ __| __/ _\` | | |/ _ \ '__|"
echo '| | (_| | | | (_| | | | | | \__ \ || (_| | | |  __/ |   '
echo '|_|\__,_|_|  \__,_| |_|_| |_|___/\__\__,_|_|_|\___|_|  '$none
echo

echo "Which is your base distro"
echo "[1] :: Ubuntu"
echo "[2] :: Arch"
echo "[0] :: Exit"
read -p "> " distro

case $distro in
    1) 
        source './setup/ubuntu.sh'
        ;;
    2)
        source './setup/arch.sh'
        ;;
    *)
        echo "Bye!"; exit;
        ;;
esac

# [CHECK COMPOSER]
composer --version &> /dev/null
if [ $? -ne 0 ]; then
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    sudo mv composer.phar /usr/local/bin/composer
fi

# [CHECK LARAVEL INSTALLER]
laravel --version &> /dev/null
if [ $? -ne 0 ]; then
    composer global require laravel/installer
    export PATH="$HOME/.config/composer/vendor/bin:$PATH"
    export PATH="$HOME/.composer/vendor/bin:$PATH"
fi

# [CREATE NEW APP]
APP_NAME=$1

if [ -z "$1" ]; then 
    while [ -z "$APP_NAME" ]; do
        read -p 'Project Name> ' APP_NAME
    done
fi

if [ -f "$APP_NAME" ]; then
    echo "The app \"$APP_NAME\" already exists."
    exit 1
fi

# [CREATING NEW APP]
printf "${yellow}[+] Creating new Laravel app${none}\n";
laravel new "$APP_NAME" --pest --breeze && cd "$APP_NAME"

docker -v &> /dev/null
if [ $? -eq 0 ]; then
    printf "${yellow}[+] Installing sail${none}\n"
    composer require laravel/sail --dev &> /dev/null
    php artisan sail:install
    ./vendor/bin/sail up -d
    ./vendor/bin/sail npm install
fi

# [INSTALLING EXTRA PACKAGES]
printf "${yellow}[+] Installing extra packages${none}\n"
printf "=> Log Viewer\t"
composer require opcodesio/log-viewer &> /dev/null
php artisan log-viewer:publish &> /dev/null
check_last_task

printf "=> Larastan\t"
composer require nunomaduro/larastan:^2.0 --dev &> /dev/null && echo '//' >> phpstan.neon &> /dev/null 
check_last_task

printf "=> Debugbar\t"
composer require barryvdh/laravel-debugbar --dev &> /dev/null
check_last_task

echo "${green}Done!${none}"
