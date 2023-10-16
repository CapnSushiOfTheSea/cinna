#!/bin/bash

PROGRAM_FILES_DIR="$HOME/.program_files"
CONFIG_FILE="$HOME/.parcel_config"
BASE_URL="https://parcel.pixspla.net"
VERSION="1.2"
VERSIONTITLE="razzmatazz"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

function read_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
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
        echo -e "${RED}Error: Cannot connect to the Parcel server. Parcel needs an internet connection to run. Try again later."
        exit 1
    fi
}

function update_parcel() {
    if wget --spider "https://parcel.pixspla.net/parcel" 2>/dev/null; then
        echo -e "Updating Parcel..."
        rm -rf "$PROGRAM_FILES_DIR/parcel"
        wget "https://parcel.pixspla.net/parcel" -P "$PROGRAM_FILES_DIR" 2> /dev/null
        chmod +x "$PROGRAM_FILES_DIR/parcel"
        echo -e "${GREEN}Parcel updated successfully.${NC}"
    else
        echo -e "${RED}Error:${NC} Cannot connect to https://parcel.pixspla.net/ to download Parcel. Try again later."
    fi
}

read_config

if [[ ! ":$PATH:" == *":$PROGRAM_FILES_DIR:"* ]]; then
    echo -e "${RED}Warning:${NC} $PROGRAM_FILES_DIR is not in your PATH. Consider adding it to your PATH."
fi

function get_package() {
    package_name="$1"
    package_url="$BASE_URL/repo/packages/$package_name"

    if [[ -f "$PROGRAM_FILES_DIR/$package_name" ]]; then
        echo -e "Package ${GREEN}$package_name${NC} is already installed."
    else
        if wget --spider "$package_url/$package_name" 2>/dev/null; then
            mkdir -p "$PROGRAM_FILES_DIR"

            echo -e "Installing package ${GREEN}$package_name${NC}"
            echo -e "Getting ${GREEN}'$package_url/$package_name'${NC}"
            wget "$package_url/$package_name" -P "$PROGRAM_FILES_DIR" 2> /dev/null

            if wget --spider "$package_url/$package_name-files.zip" 2>/dev/null; then
                echo -e "Getting ${GREEN}'$package_url/$package_name-files.zip'${NC}"
                wget "$package_url/$package_name-files.zip" -P "$PROGRAM_FILES_DIR" 2> /dev/null
                unzip "$PROGRAM_FILES_DIR/$package_name-files.zip" -d "$PROGRAM_FILES_DIR/$package_name-files" > /dev/null
                echo "Cleaning up..."
                rm "$PROGRAM_FILES_DIR/$package_name-files.zip"
            fi

            chmod +x "$PROGRAM_FILES_DIR/$package_name"
            echo -e "Package ${GREEN}$package_name${NC} installed successfully."
        else
            echo -e "${RED}Error:${NC} Package ${GREEN}$package_name${NC} not found."
        fi
    fi
}

function remove_package() {
    package_name="$1"

    if [[ -f "$PROGRAM_FILES_DIR/$package_name" ]]; then
        rm -rf "$PROGRAM_FILES_DIR:?/$package_name"
        if [[ -d "$PROGRAM_FILES_DIR/$package_name-files" ]]; then
            rm -r "$PROGRAM_FILES_DIR/$package_name-files"
        fi
        echo -e "Package ${GREEN}$package_name${NC} removed."
    else
        echo -e "${RED}Error:${NC} Package ${GREEN}$package_name${NC} is not installed."
    fi
}

function upgrade_package() {
    package_name="$1"
    package_url="$BASE_URL/repo/packages/$package_name"

    if [[ -f "$PROGRAM_FILES_DIR/$package_name" ]]; then
        if wget --spider "$package_url/$package_name" 2>/dev/null; then
            echo -e "Upgrading package ${GREEN}$package_name${NC}"
            if [[ -f "$PROGRAM_FILES_DIR/$package_name" ]]; then
                rm -rf "$PROGRAM_FILES_DIR:?/$package_name"
                if [[ -d "$PROGRAM_FILES_DIR/$package_name-files" ]]; then
                    rm -r "$PROGRAM_FILES_DIR/$package_name-files"
                fi
            fi
            echo -e "Getting ${GREEN}'$package_url/$package_name'${NC}"
            wget "$package_url/$package_name" -P "$PROGRAM_FILES_DIR" 2> /dev/null

            if wget --spider "$package_url/$package_name-files.zip" 2>/dev/null; then
                echo -e "Getting ${GREEN}'$package_url/$package_name-files.zip'${NC}"
                wget "$package_url/$package_name-files.zip" -P "$PROGRAM_FILES_DIR" 2> /dev/null
                unzip "$PROGRAM_FILES_DIR/$package_name-files.zip" -d "$PROGRAM_FILES_DIR/$package_name-files" > /dev/null
                echo "Cleaning up..."
                rm "$PROGRAM_FILES_DIR/$package_name-files.zip"
            fi

            chmod +x "$PROGRAM_FILES_DIR/$package_name"
            echo -e "Package ${GREEN}$package_name${NC} upgraded successfully."
        else
            echo -e "${RED}Error:${NC} Package ${GREEN}$package_name${NC} not found."
        fi
    else
        echo -e "${RED}Error:${NC} Package ${GREEN}$package_name${NC} is not installed."
    fi
}

function info_package() {
    package_name="$1"
    package_info_url="$BASE_URL/repo/packages/$package_name/metadata"

    if wget --spider "$package_info_url" 2>/dev/null; then
        wget -N "$package_info_url" -O "$PROGRAM_FILES_DIR/$package_name-info.txt" 2> /dev/null

        while IFS= read -r line; do
            key=$(echo "$line" | cut -d'=' -f1 | tr -d '[:space:]')
            value=$(echo "$line" | cut -d'=' -f2- | sed 's/^ *//')
            echo -e "${YELLOW}${key}:${NC} ${PURPLE}${value}${NC}"
        done < "$PROGRAM_FILES_DIR/$package_name-info.txt"
        
        rm "$PROGRAM_FILES_DIR/$package_name-info.txt"
    else
        echo -e "${RED}Error:${NC} Package info for ${GREEN}$package_name${NC} not found."
    fi
}

function help_message() {
    echo -e "${GREEN}Parcel${NC}: The stupidest package manager known to mankind"
    echo ""
    echo -e "${PURPLE}Commands${NC}"
    echo -e "  ${BLUE}get${NC} ${YELLOW}<package name>${NC}     - Install a package."
    echo -e "  ${BLUE}remove${NC} ${YELLOW}<package name>${NC}  - Remove a package."
    echo -e "  ${BLUE}upgrade${NC} ${YELLOW}<package name>${NC} - Upgrade a package."
    echo -e "  ${BLUE}info${NC} ${YELLOW}<package name>${NC}    - Get package information."
    echo -e "  ${BLUE}update${NC}                 - Update Parcel."
    echo -e "  ${BLUE}config ${YELLOW}<option>${NC}        - Configure Parcel."
    echo -e "    ${YELLOW}(Use parcel config -h for it's help command.)${NC}"
    echo -e "  ${BLUE}credits${NC}                - Show Parcel credits."
    echo ""
    echo -e "${PURPLE}Arguments${NC}"
    echo -e "  ${BLUE}--help, -h${NC}             - Show this help message."
    echo -e "  ${BLUE}--version, -v${NC}          - Show the version of Parcel."
}

function config_help_message() {
    echo -e "${GREEN}Parcel${NC}: The stupidest package manager known to mankind"
    echo ""
    echo -e "${PURPLE}Config Options${NC}"
    echo -e "  ${BLUE}dir${NC} ${YELLOW}<package name>${NC}     - Set the package install directory."
    echo -e "  ${BLUE}repo${NC} ${YELLOW}<package name>${NC}    - Set the package repo you'd like to use."
    echo ""
    echo -e "${PURPLE}Arguments${NC}"
    echo -e "  ${BLUE}--help, -h${NC}             - Show this help message."
}

case "$1" in
    "update")
        check_for_updates
        update_parcel
        ;;
    "get")
        check_for_updates
        get_package "$2"
        ;;
    "remove")
        check_for_updates
        remove_package "$2"
        ;;
    "upgrade")
        check_for_updates
        upgrade_package "$2"
        ;;
    "info")
        check_for_updates
        info_package "$2"
        ;;
    "--help" | "-h")
        help_message
        ;;
    "--version" | "-v")
        echo -e "${GREEN}Parcel${NC} ${PURPLE}v$VERSION${NC} (codename '$VERSIONTITLE')"
        echo -e "Created by ${BLUE}NoodleDX${NC}"
        ;;
    "config")
        case "$2" in
            "dir")
                if [[ -d "$3" ]]; then
                    PROGRAM_FILES_DIR="$3"
                    echo "PROGRAM_FILES_DIR=\"$PROGRAM_FILES_DIR\"" > "$CONFIG_FILE"
                    echo "Package install directory set to $PROGRAM_FILES_DIR."
                else
                    echo "Error: Directory does not exist."
                fi
                ;;
            "repo")
                echo "Running checks..."
                if wget --spider "$3" 2>/dev/null; then
                    echo "URL exists."
                else
                    echo "URL does not exist."
                    exit 1
                fi
                if wget --spider "$3/repo" 2>/dev/null; then
                    echo "Repo exists."
                else
                    echo "Repo ($3/repo) does not exist."
                    exit 1
                fi
                if wget --spider "$3/repo/packages" 2>/dev/null; then
                    echo "Packages exist."
                else
                    echo "Packages ($3/repo/packages) do not exist."
                    exit 1
                fi
                echo "Test complete. Adding URL to config..."
                BASE_URL="$3"
                echo "BASE_URL=\"$BASE_URL\"" > "$CONFIG_FILE"
                echo "Repo URL set to $BASE_URL."
                ;;
            "--help" | "-h")
                config_help_message
                ;;
            *)
                echo "Invalid option"
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
    "agony")
        echo "      __"
        echo " _   / /"
        echo "(_) | | "
        echo " _  | | "
        echo "(_) | | "
        echo "     \_\\"
        echo "\"ouhh im dying\""
        echo ""
        echo "ouhh secret doo be do be do bah"
        ;;
    "")
        help_message
        ;;
    *)
        echo -e "${RED}Error:${NC} Unknown command: $1"
        help_message
        exit 1
        ;;
esac