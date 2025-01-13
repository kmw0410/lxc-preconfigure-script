#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "This script needs sudo, Please run"
    echo "  [ sudo ./preconfigure-script.sh ]"
    echo "        or"
    echo "  Switch to root -> ./preconfigure-script.sh"
    exit 1
fi

if grep -q "archive.ubuntu.com" /etc/apt/sources.list; then
    sed -i "s/archive.ubuntu.com/mirror.kakao.com/g" /etc/apt/sources.list
    echo "Changed the mirror"
    echo ""
    cat /etc/apt/sources.list | grep "mirror.kakao.com"
    
    sleep 1

    echo "Check for update.."

    sleep 1

    apt-get update && apt-get upgrade -y
else
    echo "The mirror has already been changed"
    
    sleep 1

    apt-get update && apt-get upgrade -y
fi

if ! docker -v &> /dev/null; then
    apt-get install curl git -y &> /dev/null
    echo "Docker and docker-compose are not installed."
    read -p "Do you want install it? (y/n): " answer

    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        apt-get install jq -y
        
        GET_COMPOSE="$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)"
        
        curl -L "https://github.com/docker/compose/releases/download/$GET_COMPOSE/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        
        sleep 1

        echo ""
        echo "Installation Summary"
        echo " - docker version: $(docker version --format '{{.Client.Version}}')"
        echo " - docker-compose version: $(docker-compose version --format '{{.Client.Version}}')"
        echo ""
    else
        echo "Installation is skipped"
    fi
else
    echo "Docker and docker-compose are already installed"
fi

echo "Done!"
