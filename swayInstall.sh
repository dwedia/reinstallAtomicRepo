#!/bin/env bash

# Install sway and packages
rpm ostree install -y --apply-live sway swaylock swayidle swaybg rofi-wayland rofi-themes wdisplays
