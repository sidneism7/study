#!/bin/bash

# Variáveis
UBUNTU_ISO_URL="https://releases.ubuntu.com/22.04/ubuntu-22.04.2-desktop-amd64.iso"
ISO_FILE="ubuntu.iso"
VM_NAME="Ubuntu_VM"

# Função para verificar se um comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Passo 1: Fazer o download da ISO do Ubuntu
echo "Baixando a ISO do Ubuntu..."
curl -L -o "${ISO_FILE}" "${UBUNTU_ISO_URL}"

# Passo 2: Instalar o VirtualBox (se necessário)
if ! command_exists vboxmanage; then
    echo "Instalando o VirtualBox..."
    if command_exists apt-get; then
        sudo apt-get update
        sudo apt-get install -y virtualbox
    elif command_exists brew; then
        brew install --cask virtualbox
    else
        echo "Gerenciador de pacotes não suportado. Instale o VirtualBox manualmente."
        exit 1
    fi
else
    echo "VirtualBox já está instalado."
fi

# Passo 3: Criar uma máquina virtual no VirtualBox
echo "Criando a máquina virtual..."
VBoxManage createvm --name "${VM_NAME}" --ostype Ubuntu_64 --register
VBoxManage modifyvm "${VM_NAME}" --memory 2048 --vram 128 --cpus 2 --nic1 nat
VBoxManage createhd --filename "${VM_NAME}.vdi" --size 25000
VBoxManage storagectl "${VM_NAME}" --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach "${VM_NAME}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${VM_NAME}.vdi"
VBoxManage storagectl "${VM_NAME}" --name "IDE Controller" --add ide
VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "${ISO_FILE}"
VBoxManage modifyvm "${VM_NAME}" --boot1 dvd --boot2 disk --boot3 none --boot4 none

# Passo 4: Iniciar a máquina virtual
echo "Iniciando a máquina virtual..."
VBoxManage startvm "${VM_NAME}"

echo "Instalação do Ubuntu iniciada na máquina virtual '${VM_NAME}'."
