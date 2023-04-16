#!/bin/bash
# Copyright (c) 2023 Daniel Fagundes <daniell.felipe.2017@gmail.com>
#
# This is a bash script that creates new laravel projects on Ubuntu based distros.
#
# The script triggers the laravel installer and creates a fresh laravel installation
# with some common packages as Phpstan, Pest, Sail and more.
# 
# Example:
# ./installer.sh project_name

source ./setup/inc/helpers.sh

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

# [CHECK DEPENDECIES]
laravel --version &> /dev/null
if [ ! $? -eq 0 ]; then
    composer global require laravel/installer
    export PATH="$(echo ~)/.config/composer/vendor/bin:$PATH"
    export PATH="$(echo ~)/.composer/vendor/bin:$PATH"
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
    exit
fi

printf "Creating new Laravel app...\n";
laravel new "$APP_NAME" --pest --breeze && cd "$APP_NAME"
composer require laravel/sail --dev &> /dev/null
php artisan sail:install
./vendor/bin/sail up -d
./vendor/bin/sail npm install

# [INSTALLING EXTRA PACKAGES]
printf "PHPSTAN :: "
composer require nunomaduro/larastan:^2.0 --dev &> /dev/null && echo '//' >> phpstan.neon &> /dev/null 
check_last_task

printf "LARAVEL DEBUGBAR :: "
composer require barryvdh/laravel-debugbar --dev &> /dev/null
check_last_task

printf "LARAVEL LOG VIEWER :: "
composer require opcodesio/log-viewer &> /dev/null
php artisan log-viewer:publish &> /dev/null
check_last_task

echo 'DONE!'
