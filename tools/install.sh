#!/bin/sh
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/tighten/paddles/main/tools/install.sh)"
# or via wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/tighten/paddles/main/tools/install.sh)"
# or via fetch:
#   sh -c "$(fetch -o - https://raw.githubusercontent.com/tighten/paddles/main/tools/install.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget https://raw.githubusercontent.com/tighten/paddles/main/tools/install.sh
#   sh install.sh

set -e

BIN=/usr/local/bin

get_os() {
    OS='macos' # For now
}

command_exists() {
	command -v "$@" >/dev/null 2>&1
}

setup_php() {
    if command_exists php; then
        echo "We'll rely on your built-in PHP for now."
    else
        echo "Sorry, only programmed for built-in PHP so far."
        exit
    fi
}

# https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
setup_composer() {
    if command_exists composer; then
        echo "Composer already installed; skipping."
    else
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

        if command_exists wget; then
            local EXPECTED_CHECKSUM="$(wget -q -O - https://composer.github.io/installer.sig)"
            local ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

            if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
            then
                >&2 echo 'ERROR: Invalid installer checksum from Composer'
                rm composer-setup.php
                exit 1
            fi
        else
            echo "Can't check Composer's signature because your machine doesn't have wget."
            echo "@todo allow them to opt out? Or build a version using curl?"
        fi

        php composer-setup.php --quiet
        RESULT=$?
        rm composer-setup.php

        echo "Composer installed!" # todo check RESULT
    fi
}

setup_laravel_installer() {
    composer global require laravel/installer
}

setup_takeout() {
    composer global require tightenco/takeout

    echo "In order for Takeout to work, you'll want to set up Docker."
    echo "Here are instructions for your system:"
    echo "https://takeout.tighten.co/install/$OS"
}

main() {
    get_os

    setup_php
    setup_composer
    setup_laravel_installer
    setup_takeout

    echo "Paddles is now installed!"
}

main "$@"
