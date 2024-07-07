#!/bin/env bash

# Install i3 and packages
rpm-ostree install -y --apply-live i3 lxpolkit volumeicon nitrogen rofi rofi-themes

# Run ansible playbook to set i3 settings.
ansible-playbook i3Install-playbook.yml -K
