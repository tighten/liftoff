#!/bin/sh
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/tighten/liftoff/main/tools/install.sh)"
# or via wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/tighten/liftoff/main/tools/install.sh)"
# or via fetch:
#   sh -c "$(fetch -o - https://raw.githubusercontent.com/tighten/liftoff/main/tools/install.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget https://raw.githubusercontent.com/tighten/liftoff/main/tools/install.sh
#   sh install.sh

set -e

BIN=/usr/local/bin

define_helpers() {
    # https://github.com/ohmyzsh/ohmyzsh/blob/master/tools/install.sh#L52
    command_exists() {
        command -v "$@" >/dev/null 2>&1
    }

    composer_has_package() {
        composer global show 2>/dev/null | grep "$@" >/dev/null
    }

    composer_require() {
        if composer_has_package "$@"; then
            echo "   $@ already installed; skipping."
        else
            echo "   Installing $@..."
            composer global require "$@" --quiet
            echo "   $@ installed!"
        fi
    }

    php_version() {
        php -v | grep ^PHP | cut -d' ' -f2
    }

    php_version_is_acceptable() {
        php -r 'exit((int)version_compare(PHP_VERSION, "7.0.0", "<"));'
    }

    # https://github.com/ohmyzsh/ohmyzsh/blob/master/tools/install.sh#L52
    setup_color() {
        # Only use colors if connected to a terminal
        if [ -t 1 ]; then
            RED=$(printf '\033[31m')
            GREEN=$(printf '\033[32m')
            YELLOW=$(printf '\033[33m')
            BLUE=$(printf '\033[34m')
            BOLD=$(printf '\033[1m')
            RESET=$(printf '\033[m')
        else
            RED=""
            GREEN=""
            YELLOW=""
            BLUE=""
            BOLD=""
            RESET=""
        fi
    }

    title() {
        local TITLE=$@
        echo ""
        echo "${GREEN}${TITLE}${RESET}"
        echo "============================================================"
    }

    # https://github.com/ohmyzsh/ohmyzsh/blob/master/tools/install.sh#L60
    underline() {
        echo "$(printf '\033[4m')$@$(printf '\033[24m')"
    }
}

define_actions() {
    get_os() {
        local unameOut="$(uname -s)"
        case "${unameOut}" in
            Linux*)     OS=linux;;
            Darwin*)    OS=macos;;
            *)          OS="UNKNOWN:${unameOut}" # @todo test this on WSL2; does it report differently than Linux?
        esac
    }

    install_php() {
        title "1. Install PHP"

        if command_exists php; then
            if php_version_is_acceptable; then
                echo "   We'll rely on your built-in PHP for now."
            else
                # echo "Sorry, your built-in PHP is too old. We require 7.0 and yours is $(php_version)"
                # exit
                install_phpdotenv
            fi
        else
            install_phpdotenv
            # echo "Sorry, only programmed for built-in PHP so far."
            # exit
        fi
    }

    install_phpdotenv() {
        if command_exists phpenv; then
            echo "   PHPEnv already installed; skipping."
        else
            curl -L https://raw.githubusercontent.com/phpenv/phpenv-installer/master/bin/phpenv-installer | bash
            # @todo Install a version
            # @todo Get PHP-FPM running?
        fi
    }

    # https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
    install_composer() {
        title "2. Install Composer"

        if command_exists composer; then
            echo "   Composer already installed; skipping."
        else
            echo "   Downloading Composer..."
            php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

            if command_exists curl; then
                echo "    Checking validity of the downloaded file..."

                local EXPECTED_CHECKSUM="$(curl -fsSL https://composer.github.io/installer.sig)"
                local ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

                if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
                then
                    >&2 echo "   ERROR: Invalid installer checksum from Composer"
                    rm composer-setup.php
                    exit 1
                fi
            else
                echo "   Can't check Composer's signature because your machine doesn't have curl."
            fi

            echo "   Running Composer setup script..."
            php composer-setup.php --quiet
            RESULT=$?
            rm composer-setup.php

            local TARGET_PATH="$BIN/composer"
            mv composer.phar $TARGET_PATH

            if [ $RESULT ]; then
                echo "   Composer installed!"
            else
                echo "   Error installing Composer."
                exit 1
            fi
        fi
    }

    install_laravel_installer() {
        title "3. Install the Laravel Installer"
        composer_require laravel/installer
    }

    install_takeout() {
        title "4. Install Takeout"
        composer_require tightenco/takeout
    }

    prompt_for_other_installations() {
        title "5. (optional) Install other CLI tools"
        echo "   If you'd like, you can also take this moment to install"
        echo "   other *optional* CLI tools built for Laravel developers."
        echo ""

        while true; do
            read -p "   Would you like to see your options? (Y/n) " SHOULD_INSTALL_OTHERS
            SHOULD_INSTALL_OTHERS=${SHOULD_INSTALL_OTHERS:-Y}
            case $SHOULD_INSTALL_OTHERS in
                [Yy]* ) SHOULD_INSTALL_OTHERS="Y" && break;;
                [Nn]* ) break;;
                * ) echo "   Please answer y or n";;
            esac
        done

        if [ $SHOULD_INSTALL_OTHERS = "Y" ]; then
            echo ""
            select INSTALLING in "Valet (test your sites locally)" "Lambo (the Laravel installer, supercharged)" "Done"; do
                case $INSTALLING in
                    Valet* ) install_valet;;
                    Lambo* ) install_lambo;;
                    Done ) break;;
                esac
            done
        fi
    }

    logo() {
        echo ""
        printf "$BLUE"
        cat <<-'EOF'
                   /\
                  //\\
                 //  \\
                //    \\
               //______\\
               |        |
               |        |
              /|   /\   |\
             / |   ||   | \
            /  |   ||   |  \
           /  /\   ||   /\  \
          |__/  \  ||  /  \__|
            /____\    /____\
            |    |____|    |
            |____|/--\|____|
             \||/ //\\ \||/
             /##\//##\\/##\
             \\//\\\///\\// __    _ ______        __________
              \/\\\\////\/ / /   (_) __/ /_____  / __/ __/ /
                 \\\///   / /   / / /_/ __/ __ \/ /_/ /_/ / 
                  \\//   / /___/ / __/ /_/ /_/ / __/ __/_/ 
                   \/   /_____/_/_/  \__/\____/_/ /_/ (_) 
EOF
        printf "$RESET"
    }

    # @todo: is it possible for us to manually trigger Docker installation on any machines? Assume no?
    instructions() {
        title "6. Next steps for you"
        echo "   In order for Takeout to work, you'll need to install Docker."
        echo ""
        echo "   Here are instructions for your system:"
        echo "  " $(underline "https://takeout.tighten.co/install/$OS")
        echo ""
        echo "   Once you've done that, you can run 'takeout install' to"
        echo "   install dependencies like MySQL."
    }
}

define_other_installers() {
    install_valet() {
        composer_require laravel/valet
    }

    install_lambo() {
        composer_require tightenco/lambo
    }
}

main() {
    define_helpers
    define_actions
    define_other_installers

    get_os
    setup_color

    install_php
    install_composer
    install_laravel_installer
    install_takeout

    prompt_for_other_installations

    logo
    instructions
}

main "$@"
