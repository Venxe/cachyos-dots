#!/usr/bin/env bash

if [[ -f "$HOME/.config/equibop/apply-transparency.sh" ]]; then
    bash "$HOME/.config/equibop/apply-transparency.sh"
fi

hyprshade on vibrance
