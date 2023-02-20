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

check_last_task() {
    if [ $? -eq 0 ]; then
        echo "OK"
    else
        echo "ERROR"
    fi
}

# [ Check dependencies ] 
php -v &> /dev/null
if [ ! $? -eq 0 ]; then
    sudo apt-get update && sudo apt-get install --no-install-recommends php8.1
    sudo apt-get install -y php8.1-{cli,common,mysql,zip,gd,mbstring,curl,xml,bcmath}
fi

composer --version &> /dev/null
if [ ! $? -eq 0 ]; then
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    sudo mv composer.phar /usr/local/bin/composer
fi

laravel --version &> /dev/null
if [ ! $? -eq 0 ]; then
    composer global require laravel/installer
fi

# [ Creating the new app ]
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

# [ Installing extra packages ]
printf "PHPSTAN :: "
composer require nunomaduro/larastan:^2.0 --dev &> /dev/null && echo '//' >> phpstan.neon &> /dev/null 
check_last_task

printf "LARAVEL DEBUGBAR :: "
composer require barryvdh/laravel-debugbar --dev &> /dev/null
check_last_task

printf "LARAVEL LOG VIEWER :: "
composer require rap2hpoutre/laravel-log-viewer &> /dev/null
check_last_task

echo 'DONE!'
