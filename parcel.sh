#!/bin/bash

dependencies=("wget" "curl")

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

for dependency in "${dependencies[@]}"; do
    if ! command_exists "$dependency"; then
        echo -e "${RED}${BOLD}Error:${NC} '$dependency' is not installed. Please install it before running this script."
        exit 1
    fi
done

INSTALLDIRECTORY="$HOME/.program_files"
CFG="$HOME/.parcel_config"
REPO="https://parcel.pixspla.net"
VERSION="1.3"
VERSIONTITLE="sleepyhead"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
BLINKING='\033[5m'
REVERSE='\033[7m'
INVISIBLE='\033[8m'

function read_config() {
    if [ -f "$CFG" ]; then
        source "$CFG"
    fi
}

function check_for_updates() {
    if wget --spider "https://parcel.pixspla.net/" 2>/dev/null; then
        latest_version=$(curl -s "https://parcel.pixspla.net/version")
        if [[ "$latest_version" > "$VERSION" ]]; then
            echo -e "${YELLOW}A new version of Parcel is available: $latest_version.${NC}"
            echo -e "You can update Parcel using 'parcel update'."
        elif [[ "$latest_version" < "$VERSION" ]]; then
            echo -e "${YELLOW}Woah Development Version !! You are Using $VERSION, and the latest is $latest_version.${NC}"
            echo -e "You can update Parcel using 'parcel update' if you want lmao."
        fi
    else
        echo -e "${RED}${BOLD}Error: Cannot connect to the Parcel server. Parcel needs an internet connection to run. Try again later."
        exit 1
    fi
}

function update_parcel() {
    if wget --spider "https://parcel.pixspla.net/parcel" 2>/dev/null; then
        echo -e "Updating Parcel..."
        rm -rf "$INSTALLDIRECTORY/parcel"
        wget "https://parcel.pixspla.net/parcel" -P "$INSTALLDIRECTORY" 2> /dev/null
        chmod +x "$INSTALLDIRECTORY/parcel"
        echo -e "${GREEN}Parcel updated successfully.${NC}"
    else
        echo -e "${RED}${BOLD}Error:${NC} Cannot connect to https://parcel.pixspla.net/ to download Parcel. Try again later."
    fi
}

read_config

if [[ ! ":$PATH:" == *":$INSTALLDIRECTORY:"* ]]; then
    echo -e "${RED}Warning:${NC} $INSTALLDIRECTORY is not in your PATH. Consider adding it to your PATH."
fi

function get_packages() {
    packages=("$@")

    for package_name in "${packages[@]}"; do
        package_url="$REPO/repo/packages/$package_name"

        if [[ -f "$INSTALLDIRECTORY/$package_name" ]]; then
            echo -e "Package ${GREEN}$package_name${NC} is already installed."
        else
            if wget --spider "$package_url/$package_name" 2>/dev/null; then
                mkdir -p "$INSTALLDIRECTORY"

                echo -e "Installing package ${GREEN}$package_name${NC}"
                echo -e "Getting ${GREEN}'$package_url/$package_name'${NC}"
                wget "$package_url/$package_name" -P "$INSTALLDIRECTORY" 2> /dev/null

                if wget --spider "$package_url/$package_name-files.zip" 2>/dev/null; then
                    echo -e "Getting ${GREEN}'$package_url/$package_name-files.zip'${NC}"
                    wget "$package_url/$package_name-files.zip" -P "$INSTALLDIRECTORY" 2> /dev/null
                    unzip "$INSTALLDIRECTORY/$package_name-files.zip" -d "$INSTALLDIRECTORY/$package_name-files" > /dev/null
                    echo "Cleaning up..."
                    rm "$INSTALLDIRECTORY/$package_name-files.zip"
                fi

                chmod +x "$INSTALLDIRECTORY/$package_name"
                echo -e "Package ${GREEN}$package_name${NC} installed successfully."
            else
                echo -e "${RED}${BOLD}Error:${NC} Package ${GREEN}$package_name${NC} not found."
            fi
        fi
    done
}

function remove_packages() {
    packages=("$@")

    for package_name in "${packages[@]}"; do
        if [[ -f "$INSTALLDIRECTORY/$package_name" ]]; then
            rm -rf "$INSTALLDIRECTORY/$package_name"
            if [[ -d "$INSTALLDIRECTORY/$package_name-files" ]]; then
                rm -r "$INSTALLDIRECTORY/$package_name-files"
            fi
            echo -e "Package ${GREEN}$package_name${NC} removed."
        else
            echo -e "${RED}${BOLD}Error:${NC} Package ${GREEN}$package_name${NC} is not installed."
        fi
    done
}

function upgrade_package() {
    package_name="$1"
    package_url="$REPO/repo/packages/$package_name"

    if [[ -f "$INSTALLDIRECTORY/$package_name" ]]; then
        if wget --spider "$package_url/$package_name" 2>/dev/null; then
            echo -e "Upgrading package ${GREEN}$package_name${NC}"
            if [[ -f "$INSTALLDIRECTORY/$package_name" ]]; then
                rm -rf "$INSTALLDIRECTORY/$package_name"
                if [[ -d "$INSTALLDIRECTORY/$package_name-files" ]]; then
                    rm -r "$INSTALLDIRECTORY/$package_name-files"
                fi
            fi
            echo -e "Getting ${GREEN}'$package_url/$package_name'${NC}"
            wget "$package_url/$package_name" -P "$INSTALLDIRECTORY" 2> /dev/null

            if wget --spider "$package_url/$package_name-files.zip" 2>/dev/null; then
                echo -e "Getting ${GREEN}'$package_url/$package_name-files.zip'${NC}"
                wget "$package_url/$package_name-files.zip" -P "$INSTALLDIRECTORY" 2> /dev/null
                unzip "$INSTALLDIRECTORY/$package_name-files.zip" -d "$INSTALLDIRECTORY/$package_name-files" > /dev/null
                echo "Cleaning up..."
                rm "$INSTALLDIRECTORY/$package_name-files.zip"
            fi

            if [[ -f "$INSTALLDIRECTORY/$package_name.1" ]]; then
                rm "$INSTALLDIRECTORY/$package_name.1"
            fi
            chmod +x "$INSTALLDIRECTORY/$package_name"
            echo -e "Package ${GREEN}$package_name${NC} upgraded successfully."
        else
            echo -e "${RED}${BOLD}Error:${NC} Package ${GREEN}$package_name${NC} not found."
        fi
    else
        echo -e "${RED}${BOLD}Error:${NC} Package ${GREEN}$package_name${NC} is not installed."
    fi
}

function info_package() {
    package_name="$1"
    package_info_url="$REPO/repo/packages/$package_name/metadata"

    if wget --spider "$package_info_url" 2>/dev/null; then
        wget -N "$package_info_url" -O "$INSTALLDIRECTORY/$package_name-info.txt" 2> /dev/null

        while IFS= read -r line; do
            key=$(echo "$line" | cut -d'=' -f1 | tr -d '[:space:]')
            value=$(echo "$line" | cut -d'=' -f2- | sed 's/^ *//')
            echo -e "${YELLOW}${key}:${NC} ${PURPLE}${value}${NC}"
        done < "$INSTALLDIRECTORY/$package_name-info.txt"
        
        rm "$INSTALLDIRECTORY/$package_name-info.txt"
    else
        echo -e "${RED}${BOLD}Error:${NC} Package info for ${GREEN}$package_name${NC} not found."
    fi
}

function help_message() {
    case $1 in
        "main")
            echo -e "${GREEN}Parcel${NC}: The stupidest package manager known to mankind"
            echo ""
            echo -e "${PURPLE}Commands${NC}"
            echo -e "  ${BLUE}get${NC} ${YELLOW}<package name>${NC}     - Install a package."
            echo -e "  ${BLUE}remove${NC} ${YELLOW}<package name>${NC}  - Remove a package."
            echo -e "  ${BLUE}upgrade${NC} ${YELLOW}<package name>${NC} - Upgrade a package."
            echo -e "  ${BLUE}info${NC} ${YELLOW}<package name>${NC}    - Get package information."
            echo -e "  ${BLUE}update${NC}                 - Update Parcel."
            echo -e "  ${BLUE}config ${YELLOW}<option>${NC}        - Configure Parcel."
            echo -e "    ${YELLOW}(Use "parcel config -h" for it's help command.)${NC}"
            echo -e "  ${BLUE}credits${NC}                - Show Parcel credits."
            echo -e "  ${BLUE}list${NC}                   - Get a list of packages."
            echo ""
            echo -e "${PURPLE}Arguments${NC}"
            echo -e "  ${BLUE}--help, -h${NC}             - Show this help message."
            echo -e "  ${BLUE}--version, -v${NC}          - Show the version of Parcel."
            ;;
        "config")
            echo -e "${GREEN}Parcel${NC}: The stupidest package manager known to mankind"
            echo ""
            echo -e "${PURPLE}Config Options${NC}"
            echo -e "  ${BLUE}dir${NC} ${YELLOW}<package name>${NC}     - Set the package install directory."
            echo -e "  ${BLUE}repo${NC} ${YELLOW}<package name>${NC}    - Set the package repo you'd like to use."
            echo ""
            echo -e "${PURPLE}Arguments${NC}"
            echo -e "  ${BLUE}--help, -h${NC}             - Show this help message."
            ;;
        "get")
            echo -e "${GREEN}Parcel${NC}: The stupidest package manager known to mankind"
            echo ""
            echo -e "${PURPLE}parcel${NC} ${BLUE}get${NC} ${YELLOW}<package name>${NC}"
            echo "  Installs a package from the repo, currently set to \"${REPO}\"."
            ;;
        "remove")
            echo -e "${GREEN}Parcel${NC}: The stupidest package manager known to mankind"
            echo ""
            echo -e "${PURPLE}parcel${NC} ${BLUE}remove${NC} ${YELLOW}<package name>${NC}"
            echo "  Removes an installed package from your computer."
            ;;
        "upgrade")
            echo -e "${GREEN}Parcel${NC}: The stupidest package manager known to mankind"
            echo ""
            echo -e "${PURPLE}parcel${NC} ${BLUE}upgrade${NC} ${YELLOW}<package name>${NC}"
            echo "  Reinstalls a package, to get the latest version."
            echo "  Not to be confused with \"parcel update\""
            ;;
        "update")
            echo -e "${GREEN}Parcel${NC}: The stupidest package manager known to mankind"
            echo ""
            echo -e "${PURPLE}parcel${NC} ${BLUE}update${NC} "
            echo "  Completely reinstalls Parcel, to get the latest version."
            echo "  Not to be confused with \"parcel upgrade\""
            ;;
        "info")
            echo -e "${GREEN}Parcel${NC}: The stupidest package manager known to mankind"
            echo ""
            echo -e "${PURPLE}parcel${NC} ${BLUE}info${NC} ${YELLOW}<package name>${NC}"
            echo "  Gets package info from the repo, currently set to \"${REPO}\""
            ;;
        "list")
            echo -e "${GREEN}Parcel${NC}: The stupidest package manager known to mankind"
            echo ""
            echo -e "${PURPLE}parcel${NC} ${BLUE}list${NC}"
            echo "  Gets a list of packages from the repo, currently set to \"${REPO}\""
            ;;
        *)
            echo -e "${RED}${BOLD}Error:${NC}  Not a help command"
            ;;
        esac
}

function list_packages() {
    packages_file="$REPO/repo/packages/packages.txt"

    if wget --spider "$packages_file" 2>/dev/null; then
        while IFS= read -r line; do
            package_name=$(echo "$line" | cut -d' ' -f1)
            package_description=$(echo "$line" | cut -d' ' -f2-)
            echo -e "${GREEN}${package_name}${NC} ${PURPLE}${package_description}${NC}"
        done < <(curl -s "$packages_file")
    else
        echo -e "${RED}${BOLD}Error:${NC} Cannot connect to $packages_file. Check your internet connection or try again later."
    fi
}

case "$1" in
    "update")
        check_for_updates
        update_parcel
        ;;
    "get")
        check_for_updates
        shift
        get_packages "$@"
        ;;
    "remove")
        check_for_updates
        shift
        remove_packages "$@"
        ;;
    "upgrade")
        check_for_updates
        upgrade_package "$2"
        ;;
    "info")
        check_for_updates
        info_package "$2"
        ;;
    "list")
        check_for_updates
        list_packages
        ;;
    "--help" | "-h")
        if [ -z "$2" ]; then
            help_message "main"
        else
            case "$2" in
                "get" | "remove" | "upgrade" | "info" | "update" | "config" | "credits" | "list")
                    help_message "$2"
                    ;;
                *)
                    echo -e "${RED}Error:${NC} Unknown command: $2"
                    ;;
            esac
        fi
        ;;
    "--version" | "-v")
        echo -e "${GREEN}Parcel${NC} ${PURPLE}v$VERSION${NC} (codename '$VERSIONTITLE')"
        echo -e "Created by ${BLUE}NoodleDX${NC}"
        ;;
    "config")
        case "$2" in
            "dir")
                if [[ -d "$3" ]]; then
                    INSTALLDIRECTORY="$3"
                    echo "INSTALLDIRECTORY=\"$INSTALLDIRECTORY\"" > "$CFG"
                    echo "Package install directory set to $INSTALLDIRECTORY."
                else
                    echo -e "${RED}${BOLD}Error:${NC} Directory does not exist."
                fi
                ;;
            "repo")
                echo "Running checks..."
                if wget --spider "$3" 2>/dev/null; then
                    echo "URL exists."
                else
                    echo -e "${RED}${BOLD}Error:${NC} URL does not exist."
                    exit 1
                fi
                if wget --spider "$3/repo" 2>/dev/null; then
                    echo "Repo exists."
                else
                    echo -e "${RED}Error:${NC} Repo ($3/repo) does not exist."
                    exit 1
                fi
                if wget --spider "$3/repo/packages" 2>/dev/null; then
                    echo "Packages exist."
                else
                    echo -e "${RED}${BOLD}Error:${NC} Packages ($3/repo/packages) do not exist."
                    exit 1
                fi
                echo "Test complete. Adding URL to config..."
                REPO="$3"
                echo "REPO=\"$REPO\"" > "$CFG"
                echo "Repo URL set to $REPO."
                ;;
            "--help" | "-h" | "")
                help_message "config"
                ;;
            *)
                echo -e "${RED}${BOLD}Error:${NC} Invalid option"
                ;;
        esac
        ;;
    "credits")
        echo "                          _ "
        echo " _ __   __ _ _ __ ___ ___| |"
        echo "| '_ \ / _\` | '__/ __/ _ \ |"
        echo "| |_) | (_| | | | (_|  __/ |"
        echo "| .__/ \__,_|_|  \___\___|_|"
        echo "|_|  \"The Stupidest Package Manager Ever\"   "
        echo ""
        sleep 1
        echo "Credits"
        echo "-------------"
        sleep 1
        echo "  NoodleDX - Creator"
        sleep 1
        echo "  BoxelLogica - Being the best boyfriend ever"
        sleep 1
        echo "  CribonGarge - The \"Not So\" Mega Man"
        sleep 1
        echo "  StackOverflow - Being a programmer's best friend"
        sleep 1
        echo "  The Dark Arts - Allowing me to use black magic to code this"
        sleep 1
        echo "  The people behind Linux - Making Bash (and linux I guess)"
        sleep 1
        echo "  And thank YOU, for using Parcel !!"
        sleep .5
        echo "  === THE END ==="
        ;;
    "debug")
        case $2 in
            "test_connection_main")
                if wget --spider "https://parcel.pixspla.net/" 2>/dev/null; then
                    echo -e "${GREEN}Successfully connected to the Parcel servers.${NC}"
                else
                    echo -e "${RED}${BOLD}Error: Cannot connect to https://parcel.pixspla.net/${NC}"
                fi
                ;;
            "test_connection_repo")
                echo "Running checks..."
                if wget --spider "$REPO" 2>/dev/null; then
                    echo "URL exists."
                else
                    echo -e "${RED}${BOLD}Error:${NC} URL does not exist."
                    exit 1
                fi
                if wget --spider "$REPO/repo" 2>/dev/null; then
                    echo "Repo exists."
                else
                    echo -e "${RED}${BOLD}Error:${NC} Repo ($REPO/repo) does not exist."
                    exit 1
                fi
                if wget --spider "$REPO/repo/packages" 2>/dev/null; then
                    echo "Packages exist."
                else
                    echo -e "${RED}${BOLD}Error:${NC} Packages ($REPO/repo/packages) do not exist."
                    exit 1
                fi
                echo -e "${GREEN}Successfully connected to the repo.${NC}"
                ;;
            "test_write")
                if echo "test" > $INSTALLDIRECTORY/test; then
                    echo -e "${GREEN}Successfully wrote a file.${NC}"
                    sleep .5
                    remove_package test >/dev/null
                else
                    echo -e "${RED}${BOLD}Error:${NC} Could not write file."
                fi
                ;;
            "test_download")
                read -p "Does the package \"cls\" exist in your repo? [y/n] " input
                if [ $input == "y" ]; then
                    if get_package "cls" >/dev/null; then
                        echo -e "${GREEN}Successfully downloaded file.${NC}"
                        sleep .5
                        remove_package cls >/dev/null
                    else
                        echo -e "${RED}${BOLD}Error:${NC} Could not download file."
                    fi
                else
                    read -p "Do you have another package for testing? [y/n] " input
                    if [ $input = y ]; then
                        read -p "What is it's name? " input
                        if get_package "$input" >/dev/null; then
                            echo -e "${GREEN}Successfully downloaded file.${NC}"
                            sleep .5
                            remove_package $input >/dev/null
                        else
                            echo -e "${RED}${BOLD}Error:${NC} Could not download file."
                        fi
                    else
                        echo "Operation cancelled."
                    fi
                fi
                ;;
            "color_test")
                echo -e "Color Test"
                echo -e "============="
                echo -e "${RED} This text is RED${NC}"
                echo -e "${GREEN} This text is GREEN${NC}"
                echo -e "${YELLOW} This text is YELLOW${NC}"
                echo -e "${BLUE} This text is BLUE${NC}"
                echo -e "${PURPLE} This text is PURPLE${NC}"
                echo -e "${NC} This text is NORMAL${NC}"
                echo -e "${BOLD} This text is BOLD${NC}"
                echo -e "${DIM} This text is DIM${NC}"
                echo -e "${ITALIC} This text is ITALIC${NC}"
                echo -e "${UNDERLINE} This text is UNDERLINED${NC}"
                echo -e "${BLINKING} This text is BLINKING${NC}"
                echo -e "${REVERSE} This text is REVERSED${NC}"
                echo -e "${INVISIBLE} This text is INVISIBLE${NC}"
                ;;
            *)
                echo -e "${RED}${BOLD}Error:${NC} Invalid option: $1"
                ;;
        esac
        ;;
    "")
        help_message "main"
        ;;
    *)
        echo -e "${RED}${BOLD}Error:${NC} Unknown command: $1"
        help_message "main"
        exit 1
        ;;
esac