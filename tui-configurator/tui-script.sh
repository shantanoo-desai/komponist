#!/bin/bash
# Komponist - Generate Your Favourite Compose Stack With the Least Effort
#
# Copyright (C) 2023  Shantanoo "Shan" Desai <sdes.softdev@gmail.com>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published
#   by the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# tui-script.sh: bash script to render a Terminal User Interface which generates
#                configuration / credentials YAML file depending on user selection


# Available Services in Komponist as an Associative Array
declare -A available_services=(
    [grafana]="9.5.1"
    [influxdbv1]="1.8-alpine"
    [influxdbv2]="2.6-alpine"
    [mosquitto]="2.0.15"
    [nodered]="3.0.1"
    [questdb]="7.1.1"
    [timescaledb]="latest-pg15"
)


# Traefik Reverse Proxy (Default Service) as an Associative Array
declare -A reverse_proxy=(
    [traefik]="v2.9.8"
)


# Configuration YAML
CONFIG_FILE="$(pwd)/config.yml"
# Credentials YAML template files
CREDS_FILE="$(pwd)/creds.yml"


##################################################################################
##                 Helper Functions for generating YAML Key-Values              ##
##################################################################################


# function: generate_kv_str_in_file
# description: helper function to insert key-value into the to-be
#              generated YAML files as String
# Parameters: $1: key for YAML structure e.g., ".komponist.property"
#             $2: value for the key e.g. "value"
#             $3: file_name: either config.yml or creds.yml
function generate_kv_str_in_file {
    pathEnv="$1" valueEnv="$2" yq -i 'eval(strenv(pathEnv)) = strenv(valueEnv)' $3
}


# function: generate_kv_bool_in_file
# description: helper function to insert key-value into the to-be
#              generated YAML files as String as Boolean
# Parameters: $1: key for YAML structure e.g., ".komponist.property"
#             $2: value for the key e.g. "value"
#             $3: file_name: either config.yml or creds.yml
function generate_kv_bool_in_file {
    pathEnv="$1" valueEnv="$2" yq -i 'eval(strenv(pathEnv)) = env(valueEnv)' $3
}


##################################################################################
##              Initial Setup Function for generating YAML Key-Values           ##
##################################################################################


# function: init_setup
# description: initial setup function to create YAML files and add initial keys
#              to them
function init_setup {

    if [ -f "$CONFIG_FILE" ]; then 
        echo "Configuration File Exists.. Overwriting it!"
        truncate -s 0 $CONFIG_FILE
    else
        echo "Configuration File Does Not Exist.. Creating it!"
        touch $CONFIG_FILE
    fi
    
    if [ -f "$CREDS_FILE" ]; then 
        echo "Credentials File Exists.. Overwriting it!"
        truncate -s 0 $CREDS_FILE
    else
        echo "Configuration File Does Not Exist.. Creating it!"
        touch $CREDS_FILE
    fi

    # insert header comment to files
    yq -i '. head_comment="Generated via Komponist TUI.
It is recommended to control some configuration values according to your needs."' $CONFIG_FILE

    yq -i '. head_comment="Generated via Komponist TUI.
Please add the necessary credentials for the selected services.
TIP: You can encrypt this file using `ansible-vault encrypt creds.yml`."' $CREDS_FILE

    # by default add Traefik Configuration
    generate_kv_str_in_file \
        ".komponist.configuration.traefik.version" "${reverse_proxy['traefik']}" $CONFIG_FILE
}


# function: custom_core_config
# description: User Interface to ask for Project Name, Deploy Directory, Persistence
function custom_core_config {

    ## Enter Project Name for Docker Compose
    PROJECT_NAME=$(gum input --placeholder "Provide a Project Name. (default:komponist)")
    if [ "$PROJECT_NAME" == "" ]; then
        # Default Value for Project Name
        PROJECT_NAME="komponist"
    fi

    # Add project name to configuration file
    generate_kv_str_in_file ".komponist.project_name" "${PROJECT_NAME}" $CONFIG_FILE

    ## Enter Deploy Directory for generation
    DEPLOY_DIR=$(gum input --placeholder "Provide the Deployment Directory Path. (default: ./deploy)")
    if [ "$DEPLOY_DIR" == "" ]; then
        # Default Value for Deploy Directory
        DEPLOY_DIR="./deploy"
    fi

    # Add deploy directory to configuration file
    generate_kv_str_in_file ".komponist.deploy_dir" "${DEPLOY_DIR}" $CONFIG_FILE

    ## Check for User ID
    USER_ID=$(gum input --placeholder "Provide the user id for the project. (Press ENTER to skip)")
    
    if [ "$USER_ID" == "" ]; then
        # Default Value for User ID
        gum spin -s line --title "skipping user id" -- sleep 0.5
    else
    # Add user id to configuration file
    generate_kv_str_in_file ".komponist.uid" "${USER_ID}" $CONFIG_FILE

    fi
    
    ## Check for Persistence
    clear
    PERSISTENCE=false # Default value
    gum confirm --default=false "Persist Data from Stack in Docker Volumes?" && PERSISTENCE=true

    # Add persistence value to configuration file
    generate_kv_bool_in_file ".komponist.data_persistence" "${PERSISTENCE}" $CONFIG_FILE
}


# function: services_configuration
# description: User Interface to Select Services and adding their respective configuration/creds
function services_configuration {
    clear
    local greeter_msg="Select all Services to be included in the Stack.
$(gum style --italic 'Traefik included by default').
Use SPACEBAR to select/de-select, ENTER to proceed.
"
    # Select Services
    gum style --border normal \
              --margin "1" \
              --padding "1 2" \
              --border-foreground 150 \
               "${greeter_msg}"

    SELECTED_SERVICES=$(gum choose --no-limit --cursor-prefix "[ ] " --selected-prefix "[✓] " ${!available_services[@]})

    if [ "$SELECTED_SERVICES" == "" ]; then
        echo "No Services Selected.. Quitting.."
        exit 1
    fi
    for service in $SELECTED_SERVICES
    do
        case "$service" in

            "grafana")

                # Add Grafana Admin Credentials Keys
                for key in admin_username admin_password
                do
                    generate_kv_str_in_file ".credentials.${service}.${key}" "<INSERT_VALUE>" $CREDS_FILE
                done
                ;;

            "influxdbv1")

                generate_kv_bool_in_file ".komponist.configuration.${service}.expose_http" "false" $CONFIG_FILE
                
                # Add InfluxDBv1 Credentials Keys
                for key in init_database admin_username admin_password readonly_user_username readonly_user_password readwrite_user_username readwrite_user_password writeonly_user_username writeonly_user_password
                do
                    generate_kv_str_in_file ".credentials.${service}.${key}" "<INSERT_VALUE>" $CREDS_FILE
                done

                # add required comments
                yq -i '(.credentials.influxdbv1 | key) line_comment="All Configurations are REQUIRED."' $CREDS_FILE
                ;;

            "influxdbv2")

                # Add InfluxDBv2 Configuration Keys
                generate_kv_bool_in_file ".komponist.configuration.${service}.expose_http" "false" $CONFIG_FILE
                generate_kv_bool_in_file ".komponist.configuration.${service}.disable_ui" "false" $CONFIG_FILE

                # Add InfluxDBv2 Credentials Keys
                for key in init_org_name init_bucket init_bucket_retention admin_username admin_password admin_token
                do
                    generate_kv_str_in_file ".credentials.${service}.${key}" "<INSERT_VALUE>" $CREDS_FILE
                done

                # Add required comments
                yq -i '.credentials.influxdbv2.admin_password line_comment="password should be min 12 chars to be acceptable"' $CREDS_FILE
                ;;

            "mosquitto")
                
                # Add Mosquitto Credentials Example
                yq -i '.credentials.mosquitto.users += 
                [
                    {
                        "username": "<INSERT_VALUE>",
                        "password": "<INSERT_VALUE>",
                        "acl": [
                            { 
                                "permissions": "readwrite", 
                                "topic": "<YOUR/TOPIC/HERE>"
                            }
                        ] 
                    }
                ]' $CREDS_FILE

                # Add comments in file
                yq -i '.credentials.mosquitto.users[].acl[].permissions line_comment="can either `readwrite`,`read`, `write`, `deny`"' $CREDS_FILE
                ;;

            "nodered")

                # Add NodeRED Configuration
                generate_kv_bool_in_file ".komponist.configuration.${service}.disable_editor" "false" $CONFIG_FILE

                # Add NodeRED Credentials Keys
                generate_kv_str_in_file ".credentials.${service}.credential_secret" "<INSERT_VALUE>" $CREDS_FILE
                
                # NodeRED Credentials Example
                yq -i '.credentials.nodered.users += 
                [
                    {
                        "username": "<INSERT_VALUE>",
                        "password": "<INSERT_VALUE>",
                        "permissions": "*"
                    }
                ]' $CREDS_FILE

                yq -i '.credentials.nodered.users[].permissions line_comment="can either `*` or `read`"' $CREDS_FILE
                ;;

            "questdb")

                # Add QuestDB related Configuration
                generate_kv_bool_in_file ".komponist.configuration.${service}.expose_http" "false" $CONFIG_FILE
                generate_kv_bool_in_file ".komponist.configuration.${service}.disable_ui" "false" $CONFIG_FILE
                ;;
            
            "timescaledb")

                # Add TimescaleDB Credentials Keys
                for key in admin_username admin_password database
                do
                    generate_kv_str_in_file ".credentials.${service}.${key}" "<INSERT_VALUE>" $CREDS_FILE
                done
                ;;

        esac
        generate_kv_str_in_file ".komponist.configuration.${service}.version" "${available_services[$service]}" $CONFIG_FILE
    done
}

# Program Entrypoint function
function main {
    # 0. Start by setting up the files and ad
    init_setup
    
    local greeter_msg="Welcome to $(gum style --foreground 1 'Komponist Configurator')

This configurator will generate the core
configuration / credentials files depending on your Selections.

$(gum style --background 0 'To skip/quit press CTRL+C / ESC.')"

    # 1. Greet
    gum style \
        --border normal \
        --margin "1" \
        --padding "1 2" \
        --border-foreground 212 \
        "${greeter_msg}"
    
    #2. Start with configuration
    custom_core_config

    #3. Services Configuration
    services_configuration

    gum style \
        --border double \
        --padding "1 5" \
        --border-foreground 200 \
        " Your Configuration File:
$(yq -C $CONFIG_FILE)"

    gum style \
        --border double \
        --padding "1 5" \
        --border-foreground 200 \
        " Your Credentials Template File:
$(yq -C $CREDS_FILE)"

}

main