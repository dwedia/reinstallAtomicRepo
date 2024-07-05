#!/bin/bash

if [[ "1" = $(cat ./counter) ]]; then
  echo "#####################################################"
  echo "### First run, running OS upgrade, and rebooting. ###"
  echo "#####################################################"
  rpm-ostree upgrade
  sleep 2
  echo "2" > ./counter
  systemctl reboot
fi

if [[ "2" = $(cat ./counter) ]]; then
  echo "#####################################################"
  echo "### Second run, installing rpmfusion, and rebooting. ###"
  echo "#####################################################"
  rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  sleep 2
  echo "3" > ./counter
  systemctl reboot
fi

if [[ "3" = $(cat ./counter) ]]; then
  echo "#####################################################"
  echo "### Third run, Installing ansible-core, and rebooting. ###"
  echo "#####################################################"
  if [[ ! -f /usr/bin/ansible ]];
  then
    rpm-ostree install ansible-core
    sleep 2
    echo "4" > ./counter
    systemctl reboot
  else
    echo "Ansible Core already installed, skipping to step 4 without reboot"
    echo "4" > ./counter
  fi
fi

if [[ "4" = $(cat ./counter) ]]; then
  echo "#####################################################"
  echo "### fourth run, running ansible playbook, and rebooting. ###"
  echo "#####################################################"
  # install the community general flatpak module
  ansible-galaxy collection install community.general
  ansible-playbook reinstall-playbook.yml -K
  sleep 2
  # Check if username or email is empty. if not, set git username and email
  if [[ -z "$gitUserName" || -z "$gitUserEmail" ]]; then
    echo "Error: Username and email cannot be empty!"
    sleep 10
    exit 1
  else
    git config --global user.name "$gitUserName"
    git config --global user.email "$gitUserEmail"
    echo "Git username and email set successfully!"
    sleep 5
  fi
  # Set up firewall with firewalld if Distribution is Fedora
  if [ ! -f /usr/bin/firewall-cmd ];
  then
    echo "Setting firewall-cmd --set-default-zone=drop"
    sudo firewall-cmd --set-default-zone=drop
    echo "Setting firewall-cmd --runtime-to-permanent"
    sudo firewall-cmd --runtime-to-permanent
    echo "Reloading Firewall Rules"
    sudo firewall-cmd --reload
  fi
  echo "5" > ./counter
  systemctl reboot
fi