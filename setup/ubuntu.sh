# [CHECK PHP]
php -v &> /dev/null
if [ $? -ne 0 ]; then
    sudo apt-get update && sudo apt-get install --no-install-recommends php8.1
    sudo apt-get install -y php8.1-{cli,common,mysql,zip,gd,mbstring,curl,xml,bcmath}
fi
