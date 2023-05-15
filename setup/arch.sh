# [CHECK PHP]
php -v &> /dev/null
if [ $? -ne 0 ]; then
    sudo pacman -Syu
    sudo pacman -S npm php php-apache php-cgi php-embed php-fpm php-gd php-redis php-snmp
fi
